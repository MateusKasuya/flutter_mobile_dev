import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/veiculo.dart';
import '../providers/auth_provider.dart';
import '../services/pneu_service.dart' as pneu_service;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_toast.dart';
import '../utils/friendly_error.dart';
import 'shared/close_x_painter.dart';
import 'shared/form_helpers.dart';

/// Abre o formulário de montagem do [pneu] na posição [localEixo] do
/// [veiculo]. O POST /pneu/movimentarpneu acontece no Confirmar do próprio
/// form; o Future só resolve com valor não-nulo se a API confirmou.
Future<bool?> showPneuEntradaSheet(
  BuildContext context,
  Pneu pneu,
  Veiculo veiculo,
  String localEixo,
  String codEsqEixo,
  PneuAcao origem, {
  http.Client? client,
}) {
  final mq = MediaQuery.of(context);
  // Breakpoint padrão do app: ≥600pt = tablet.
  final isTablet = mq.size.width >= 600;

  if (isTablet) {
    // Tablet: modal centralizado (showDialog) com tamanho fixo.
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: origem.bgColor ?? Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.textHint, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 460,
          height: 660,
          child: _PneuEntradaForm(
            pneu: pneu,
            veiculo: veiculo,
            localEixo: localEixo,
            codEsqEixo: codEsqEixo,
            origem: origem,
            isTablet: true,
            client: client,
          ),
        ),
      ),
    );
  }

  // Mobile: bottom sheet com altura fixa de 658pt (spec do Figma — no
  // iPhone X-class, 812 - 658 = top 154pt, mesmo offset do design).
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: origem.bgColor ?? Colors.white,
    constraints: const BoxConstraints(maxHeight: 658, minHeight: 658),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: AppColors.textHint, width: 1),
    ),
    builder: (context) => _PneuEntradaForm(
      pneu: pneu,
      veiculo: veiculo,
      localEixo: localEixo,
      codEsqEixo: codEsqEixo,
      origem: origem,
      client: client,
    ),
  );
}

class _PneuEntradaForm extends StatefulWidget {
  final Pneu pneu;
  final Veiculo veiculo;
  final String localEixo;
  final String codEsqEixo;
  final PneuAcao origem;
  // No modo tablet o form vive dentro de um Dialog centralizado — sem drag
  // handle, sem safe-area de teclado por baixo.
  final bool isTablet;
  // Injetável nos testes (MockClient); em produção os serviços criam o próprio.
  final http.Client? client;

  const _PneuEntradaForm({
    required this.pneu,
    required this.veiculo,
    required this.localEixo,
    required this.codEsqEixo,
    required this.origem,
    this.isTablet = false,
    this.client,
  });

  @override
  State<_PneuEntradaForm> createState() => _PneuEntradaFormState();
}

class _PneuEntradaFormState extends State<_PneuEntradaForm> {
  final _formKey = GlobalKey<FormState>();
  final _dataEnvioController = TextEditingController();
  final _kmEntradaController = TextEditingController();

  // true enquanto o POST de montagem está em andamento — desabilita os
  // botões (evita envio duplicado) e troca o texto do Confirmar por um spinner.
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _dataEnvioController.text = formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dataEnvioController.dispose();
    _kmEntradaController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dataEnvioController.text = formatDate(picked);
    }
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) return;

    // A API espera nropneu/codfil/nrofrota como int, mas o GET os devolve como
    // string (e o model faz default '' quando a API omite). int.parse('')
    // lançaria FormatException e travaria a montagem para sempre; validamos com
    // tryParse ANTES de entrar no estado "enviando" para dar um erro claro.
    final nroPneu = int.tryParse(widget.pneu.nroPneu);
    final codFil = int.tryParse(widget.pneu.codFil);
    final nroFrota = int.tryParse(widget.veiculo.nroFrota);
    if (nroPneu == null || codFil == null) {
      showErrorToast('Pneu sem número ou filial válidos para montar.');
      return;
    }
    if (nroFrota == null) {
      showErrorToast('Veículo sem número de frota válido para montar.');
      return;
    }

    setState(() => _enviando = true);
    try {
      final token = context.read<AuthProvider>().token;
      final mensagem = await pneu_service.movimentarPneu(
        token,
        // A API espera números onde o GET devolve strings
        // (nropneu, codfil, nrofrota).
        nroPneu: nroPneu,
        // Data em que o pneu entra no veículo = Data do Envio do form
        // (DD/MM/AAAA → DateTime, meia-noite).
        dataEntrada: parseDate(_dataEnvioController.text) ?? DateTime.now(),
        codFil: codFil,
        // Montagem é identificada pelo backend por estes campos preenchidos;
        // localizacao vai nula (o pneu deixa de estar numa localização,
        // igual aos pneus montados que o GET devolve sem localizacao).
        localEixo: widget.localEixo,
        codEsqEixo: widget.codEsqEixo.isEmpty ? null : widget.codEsqEixo,
        placa: widget.veiculo.placa,
        nroFrota: nroFrota,
        // KM do veículo no momento da montagem, sem o separador de milhar
        // aplicado pelo form.
        kmEntrada: _kmEntradaController.text.replaceAll('.', ''),
        client: widget.client,
      );
      if (!mounted) return;
      showSuccessToast(
        mensagem.isNotEmpty
            ? mensagem
            : 'Pneu ${widget.pneu.nroPneu} montado na posição '
                '${widget.localEixo}',
      );
      // Sinaliza sucesso ao chamador (contrato `pop != null` = confirmado);
      // cancelar/fechar continuam passando null implícito.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      // Mantém o sheet aberto para o usuário corrigir/tentar de novo
      // sem perder o que já digitou.
      setState(() => _enviando = false);
      showErrorToast(friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final origem = widget.origem;
    final pneu = widget.pneu;

    final content = Padding(
      // Sobe o conteúdo quando o teclado aparece (só no bottom sheet mobile).
      padding: EdgeInsets.only(
        bottom: widget.isTablet
            ? 0
            : MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        children: [
          _buildContent(context, origem, pneu),
          // Botão fechar só no tablet (mobile fecha pelo drag/swipe).
          if (widget.isTablet)
            Positioned(
              left: 410,
              top: 30,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Desabilita o "X" durante o envio (mesma intenção do Cancelar).
                onTap: _enviando ? null : () => Navigator.pop(context),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(
                    painter: CloseXPainter(
                      color: AppColors.textMuted,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Bloqueia fechar a sheet (back/swipe/toque fora) enquanto envia — senão a
    // requisição continua e o `if (!mounted) return` engole o sucesso, deixando
    // a UI desatualizada. Navigator.pop explícito (sucesso/X) segue funcionando.
    return PopScope(canPop: !_enviando, child: content);
  }

  Widget _buildContent(BuildContext context, PneuAcao origem, Pneu pneu) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle (só no bottom sheet — modal de tablet não arrasta).
        if (!widget.isTablet)
          Container(
            width: 130,
            height: 5,
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF9B9B9B),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        // Header com ícone e label da origem.
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            widget.isTablet ? 40 : 33,
            widget.isTablet ? 36 : 24,
            widget.isTablet ? 40 : 33,
            0,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Transform.flip(
                  flipX: origem.mirrorX,
                  child: origem.asset != null
                      ? SvgPicture.asset(
                          origem.asset!,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            origem.borderColor ?? origem.color,
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          origem.icon,
                          color: origem.borderColor ?? origem.color,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                origem.label.toUpperCase(),
                style: AppTextStyles.body,
              ),
              const SizedBox(width: 6),
              Text('—', style: AppTextStyles.body),
              const SizedBox(width: 6),
              // Flexible + ellipsis: a posição do eixo é de tamanho variável e
              // pode estourar o header em telas estreitas.
              Flexible(
                child: Text(
                  'Posição ${widget.localEixo}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Formulário
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              widget.isTablet ? 40 : 33,
              widget.isTablet ? 30 : 27,
              widget.isTablet ? 40 : 33,
              0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadOnlyField(label: 'Nº do Pneu', value: pneu.nroPneu),
                  const SizedBox(height: 20),
                  ReadOnlyField(
                    label: 'Esquema de Eixo',
                    value: widget.codEsqEixo,
                  ),
                  const SizedBox(height: 20),
                  ReadOnlyField(
                    label: 'Localização Eixo',
                    value: widget.localEixo,
                  ),
                  const SizedBox(height: 20),
                  FieldLabel('Data do Envio'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _dataEnvioController,
                    readOnly: true,
                    onTap: _pickDate,
                    style: AppTextStyles.inputText,
                    decoration: formInputDecoration(
                      hint: 'DD/MM/AAAA',
                      suffix: Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: origem.borderColor,
                      ),
                      borderColor: origem.borderColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FieldLabel('KM Entrada Veículo'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _kmEntradaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorFormatter(),
                    ],
                    style: AppTextStyles.inputText,
                    decoration: formInputDecoration(
                      hint: 'Informe o KM do veículo',
                      borderColor: origem.borderColor,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe o KM de entrada' : null,
                  ),
                  SizedBox(height: widget.isTablet ? 40 : 43),
                  // Botões
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 144,
                        height: 56,
                        child: OutlinedButton(
                          // Durante o envio, cancelar fecharia o sheet com a
                          // requisição ainda em andamento — melhor bloquear.
                          onPressed: _enviando
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.textPlaceholder,
                              width: 2,
                            ),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.buttonSecondary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 144,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                offset: Offset(0, 2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: FilledButton(
                            onPressed: _enviando ? null : _confirmar,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              // Mantém a cor cheia enquanto desabilitado no
                              // envio, para o spinner não ficar sobre cinza.
                              disabledBackgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _enviando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Confirmar',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.buttonPrimary,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
