import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/pneu_movimentacao.dart';
import '../providers/auth_provider.dart';
import '../services/sucata_service.dart' as sucata_service;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_toast.dart';
import 'shared/form_helpers.dart';

Future<PneuMovimentacao?> showPneuMovimentacaoSheet(
  BuildContext context,
  Pneu pneu,
  PneuAcao acao,
) {
  final mq = MediaQuery.of(context);
  // Breakpoint padrão do app: ≥600pt = tablet.
  final isTablet = mq.size.width >= 600;

  if (isTablet) {
    // Tablet: modal centralizado (showDialog) com tamanho fixo por ação.
    // Sucata usa 790pt de altura por ter o campo extra de "Motivo".
    final dialogHeight = acao == PneuAcao.sucata ? 790.0 : 688.0;
    return showDialog<PneuMovimentacao>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: acao.bgColor ?? Colors.white,
        insetPadding: const EdgeInsets.all(24),
        // shape: bordas arredondadas + outline 1px na cor textHint (#C4C4C4)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.textHint, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 460,
          height: dialogHeight,
          child: _PneuMovimentacaoForm(
            pneu: pneu,
            acao: acao,
            isTablet: true,
          ),
        ),
      ),
    );
  }

  // Mobile: bottom sheet (comportamento original).
  // Folga acima do sheet: respeita o safe area (status bar/dynamic island)
  // mais uma margem visual de 60pt. Resulta em ~80pt no iPhone SE e ~119pt
  // num iPhone com notch — folga sempre visível, sem cortar conteúdo.
  final topGap = mq.padding.top + 60;
  final sheetMaxHeight = mq.size.height - topGap;

  return showModalBottomSheet<PneuMovimentacao>(
    context: context,
    isScrollControlled: true,
    backgroundColor: acao.bgColor ?? Colors.white,
    constraints: BoxConstraints(maxHeight: sheetMaxHeight),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: AppColors.textHint, width: 1),
    ),
    builder: (context) => _PneuMovimentacaoForm(pneu: pneu, acao: acao),
  );
}

class _PneuMovimentacaoForm extends StatefulWidget {
  final Pneu pneu;
  final PneuAcao acao;
  // No modo tablet o form vive dentro de um Dialog centralizado — sem drag
  // handle, sem safe-area de teclado por baixo.
  final bool isTablet;

  const _PneuMovimentacaoForm({
    required this.pneu,
    required this.acao,
    this.isTablet = false,
  });

  @override
  State<_PneuMovimentacaoForm> createState() => _PneuMovimentacaoFormState();
}

class _PneuMovimentacaoFormState extends State<_PneuMovimentacaoForm> {
  final _formKey = GlobalKey<FormState>();
  final _dataRetornoController = TextEditingController();
  final _kmSaidaController = TextEditingController();
  final _observacaoController = TextEditingController();

  MotivoSucateamento? _motivoSucateamento;

  // Lista de motivos vinda da API; permanece vazia até _carregarMotivos resolver.
  List<MotivoSucateamento> _motivos = [];
  bool _loadingMotivos = false;
  String? _erroMotivos;

  @override
  void initState() {
    super.initState();
    _dataRetornoController.text = formatDate(DateTime.now());
    if (widget.acao == PneuAcao.sucata) {
      _carregarMotivos();
    }
  }

  Future<void> _carregarMotivos() async {
    setState(() {
      _loadingMotivos = true;
      _erroMotivos = null;
    });
    try {
      final token = context.read<AuthProvider>().token;
      final motivos = await sucata_service.fetchMotivosSucateamento(token);
      if (!mounted) return;
      setState(() {
        _motivos = motivos;
        _loadingMotivos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroMotivos = e.toString().replaceFirst('Exception: ', '');
        _loadingMotivos = false;
      });
      showErrorToast(_erroMotivos!);
    }
  }

  @override
  void dispose() {
    _dataRetornoController.dispose();
    _kmSaidaController.dispose();
    _observacaoController.dispose();
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
      _dataRetornoController.text = formatDate(picked);
    }
  }

  void _confirmar() {
    // Sucateamento exige motivo carregado antes de submeter.
    if (widget.acao == PneuAcao.sucata && _motivos.isEmpty) {
      showErrorToast('Aguarde os motivos carregarem');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final movimentacao = PneuMovimentacao(
      nroPneu: widget.pneu.nroPneu,
      dataEnvio: widget.pneu.dataAtzKm,
      dataRetorno: _dataRetornoController.text,
      kmEntrada: widget.pneu.kmAtuVei,
      kmSaida: _kmSaidaController.text,
      motivoSucateamento: _motivoSucateamento,
      observacao: _observacaoController.text,
      acao: widget.acao,
    );

    Navigator.pop(context, movimentacao);
  }

  @override
  Widget build(BuildContext context) {
    final acao = widget.acao;
    final pneu = widget.pneu;

    return Padding(
      // No bottom sheet: sobe o conteúdo quando o teclado aparecer.
      // No modal de tablet: Dialog já fica centralizado pelo Flutter, não precisa.
      padding: EdgeInsets.only(
        bottom: widget.isTablet
            ? 0
            : MediaQuery.of(context).viewInsets.bottom,
      ),
      // Stack permite sobrepor o botão "X" no canto superior direito do modal
      // sem afetar o layout do Column principal (que segue do topo pra baixo).
      child: Stack(
        children: [
          _buildContent(context, acao, pneu),
          // Botão fechar — só no tablet, ancorado em (left: 410, top: 30)
          // relativo à largura do modal (460pt). Width/height 20pt, stroke 3px.
          if (widget.isTablet)
            Positioned(
              left: 410,
              top: 30,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(
                    painter: _CloseXPainter(
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
  }

  // Conteúdo principal do form (extraído pra deixar o Stack do build() limpo).
  Widget _buildContent(BuildContext context, PneuAcao acao, Pneu pneu) {
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
          // Header com ícone e título da ação.
          // Tablet: margin horizontal 40, top 46; mobile: 33 horizontal, 21 top.
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              widget.isTablet ? 40 : 33,
              widget.isTablet ? 46 : 21,
              widget.isTablet ? 40 : 33,
              0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Transform.flip(
                    flipX: acao.mirrorX,
                    child: acao.asset != null
                        ? SvgPicture.asset(
                            acao.asset!,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              acao.borderColor ?? acao.color,
                              BlendMode.srcIn,
                            ),
                          )
                        : Icon(
                            acao.icon,
                            color: acao.borderColor ?? acao.color,
                            size: 22,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  acao.label.toUpperCase(),
                  style: AppTextStyles.body,
                ),
                const SizedBox(width: 6),
                Text('—', style: AppTextStyles.body),
                const SizedBox(width: 6),
                Text(
                  'Pneu ${pneu.nroPneu}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
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
                30,
                widget.isTablet ? 40 : 33,
                0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nº do Pneu ocupa o espaço restante (Expanded);
                        // gap fixo de 30pt até a Data do envio (largura fixa).
                        Expanded(
                          child: ReadOnlyField(
                            label: 'Nº do Pneu',
                            value: pneu.nroPneu,
                          ),
                        ),
                        const SizedBox(width: 30),
                        SizedBox(
                          width: 124,
                          child: ReadOnlyField(
                            label: 'Data do envio',
                            value: normalizeDateStr(pneu.dataAtzKm),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FieldLabel('Data do retorno'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dataRetornoController,
                      readOnly: true,
                      onTap: _pickDate,
                      style: AppTextStyles.inputText,
                      decoration: formInputDecoration(
                        hint: 'DD/MM/AAAA',
                        suffix: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: acao.borderColor,
                        ),
                        borderColor: acao.borderColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ReadOnlyField(label: 'KM de entrada', value: formatKm(pneu.kmAtuVei)),
                    const SizedBox(height: 14),
                    FieldLabel('KM de saída'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _kmSaidaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorFormatter(),
                      ],
                      style: AppTextStyles.inputText,
                      decoration: formInputDecoration(
                        hint: 'Informe o KM atual',
                        borderColor: acao.borderColor,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe o KM de saída' : null,
                    ),
                    if (acao == PneuAcao.sucata) ...[
                      const SizedBox(height: 14),
                      FieldLabel('Motivo de sucateamento'),
                      const SizedBox(height: 10),
                      _buildMotivoField(),
                    ],
                    const SizedBox(height: 14),
                    FieldLabel('Observação'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _observacaoController,
                      maxLines: 3,
                      style: AppTextStyles.inputText,
                      decoration: formInputDecoration(
                        hint: 'Observações (opcional)',
                        verticalPadding: 21,
                        borderColor: acao.borderColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 144,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
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
                              onPressed: _confirmar,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Confirmar',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.buttonPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Margem inferior do form (mobile e tablet): 32pt
                    // entre a base dos botões e a borda inferior do sheet/modal.
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
    );
  }

  Widget _buildMotivoField() {
    if (_loadingMotivos) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_erroMotivos != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _erroMotivos!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: _carregarMotivos,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<MotivoSucateamento>(
      initialValue: _motivoSucateamento,
      isExpanded: true,
      style: AppTextStyles.inputText,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 24,
        color: AppColors.textMuted,
      ),
      decoration: formInputDecoration(
        hint: 'Selecione o motivo',
        borderColor: widget.acao.borderColor,
      ).copyWith(hintStyle: AppTextStyles.inputText),
      items: _motivos
          .map(
            (m) => DropdownMenuItem(
              value: m,
              child: Text(m.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _motivoSucateamento = v),
      validator: (v) =>
          v == null ? 'Selecione o motivo de sucateamento' : null,
    );
  }
}

/// Pinta um "X" com duas linhas diagonais cruzadas dentro do canvas.
/// Usado no botão de fechar do modal de tablet — stroke configurável
/// pra bater com a spec (3px) sem depender da espessura do Material Icon.
class _CloseXPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _CloseXPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    // Diagonal "\": canto sup-esq → canto inf-dir
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    // Diagonal "/": canto sup-dir → canto inf-esq
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CloseXPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}