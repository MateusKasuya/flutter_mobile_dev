import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/pneu_entrada_veiculo.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'shared/form_helpers.dart';

Future<PneuEntradaVeiculo?> showPneuEntradaSheet(
  BuildContext context,
  Pneu pneu,
  String localEixo,
  String codEsqEixo,
  PneuAcao origem,
) {
  final mq = MediaQuery.of(context);
  // Breakpoint padrão do app: ≥600pt = tablet.
  final isTablet = mq.size.width >= 600;

  if (isTablet) {
    // Tablet: modal centralizado (showDialog) com tamanho fixo.
    return showDialog<PneuEntradaVeiculo>(
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
            localEixo: localEixo,
            codEsqEixo: codEsqEixo,
            origem: origem,
            isTablet: true,
          ),
        ),
      ),
    );
  }

  // Mobile: bottom sheet com altura fixa de 658pt (spec do Figma — no
  // iPhone X-class, 812 - 658 = top 154pt, mesmo offset do design).
  return showModalBottomSheet<PneuEntradaVeiculo>(
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
      localEixo: localEixo,
      codEsqEixo: codEsqEixo,
      origem: origem,
    ),
  );
}

class _PneuEntradaForm extends StatefulWidget {
  final Pneu pneu;
  final String localEixo;
  final String codEsqEixo;
  final PneuAcao origem;
  // No modo tablet o form vive dentro de um Dialog centralizado — sem drag
  // handle, sem safe-area de teclado por baixo.
  final bool isTablet;

  const _PneuEntradaForm({
    required this.pneu,
    required this.localEixo,
    required this.codEsqEixo,
    required this.origem,
    this.isTablet = false,
  });

  @override
  State<_PneuEntradaForm> createState() => _PneuEntradaFormState();
}

class _PneuEntradaFormState extends State<_PneuEntradaForm> {
  final _formKey = GlobalKey<FormState>();
  final _dataEnvioController = TextEditingController();
  final _kmEntradaController = TextEditingController();

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

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final entrada = PneuEntradaVeiculo(
      nroPneu: widget.pneu.nroPneu,
      codEsqEixo: widget.codEsqEixo,
      localEixo: widget.localEixo,
      dataEnvio: _dataEnvioController.text,
      kmEntradaVeiculo: _kmEntradaController.text,
      origem: widget.origem,
    );

    Navigator.pop(context, entrada);
  }

  @override
  Widget build(BuildContext context) {
    final origem = widget.origem;
    final pneu = widget.pneu;

    return Padding(
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
              Text(
                'Posição ${widget.localEixo}',
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

/// Pinta um "X" com duas linhas diagonais cruzadas — usado no botão de
/// fechar do modal de tablet, com stroke configurável pra bater com a spec.
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
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CloseXPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
