import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../components/diagrama_eixos.dart';
import '../components/pneu_acoes_dialog.dart';
import '../models/eixo.dart';
import '../models/pneu.dart';
import '../models/veiculo.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/eixo_utils.dart';

class FrotaDetalheScreen extends StatefulWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  State<FrotaDetalheScreen> createState() => _FrotaDetalheScreenState();
}

class _FrotaDetalheScreenState extends State<FrotaDetalheScreen> {
  // Acima dessa largura, renderizamos o layout de tablet.
  static const double _tabletBreakpoint = 600;

  late List<Eixo> _eixos;

  @override
  void initState() {
    super.initState();
    _eixos = buildEixoLayout(widget.veiculo.pneus);
  }

  void _onPneuConfirmed(Pneu pneu) {
    setState(() {
      _eixos = _eixos.map((e) => e.withoutPneu(pneu)).toList();
    });
  }

  void _onSlotVazioConfirmed(String localEixo, Pneu pneu) {
    final eixoNumero = int.parse(localEixo[0]);
    final posicao = localEixo.substring(1);
    setState(() {
      _eixos = _eixos.map((e) {
        if (e.numero == eixoNumero) return e.withPneuAt(posicao, pneu);
        return e;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= _tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Veículo ${widget.veiculo.placa}',
          style: isTablet
              ? AppTextStyles.labelBarTablet
              : AppTextStyles.labelBar,
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: isTablet
                ? const EdgeInsets.fromLTRB(47, 30, 47, 0)
                : const EdgeInsets.fromLTRB(23, 20, 23, 0),
            child: _VeiculoCard(
              veiculo: widget.veiculo,
              isTablet: isTablet,
            ),
          ),
          Expanded(
            child: Padding(
              padding: isTablet
                  ? const EdgeInsets.fromLTRB(45, 67, 45, 0)
                  : const EdgeInsets.fromLTRB(45, 30, 45, 0),
              child: DiagramaEixos(
                eixos: _eixos,
                isTablet: isTablet,
                onPneuTap: (pneu) => _showPneuDetails(context, pneu),
                onPneuDoubleTap: (pneu) => showPneuAcoesDialog(
                  context,
                  pneu,
                  onConfirmed: _onPneuConfirmed,
                ),
                onSlotVazioDoubleTap: (localEixo) =>
                    showSlotVazioAcoesDialog(
                      context,
                      localEixo,
                      onConfirmed: _onSlotVazioConfirmed,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showPneuDetails(BuildContext context, Pneu pneu) {
  final isTablet = MediaQuery.of(context).size.width >= 600;

  if (isTablet) {
    _showPneuDetailsDialog(context, pneu);
    return;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: AppColors.textHint, width: 1),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SizedBox(
      height: 444,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 130,
              height: 5,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF9B9B9B),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(33, 0, 33, 24),
            child: _buildPneuDetailsBody(pneu),
          ),
        ],
      ),
    ),
  );
}

void _showPneuDetailsDialog(BuildContext context, Pneu pneu) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.textHint, width: 1),
      ),
      child: SizedBox(
        width: 430,
        height: 470,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(33, 41, 33, 24),
              child: _buildPneuDetailsBody(pneu, isTablet: true),
            ),
            Positioned(
              top: 20,
              left: 394,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CustomPaint(painter: _CloseIconPainter()),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPneuDetailsBody(Pneu pneu, {bool isTablet = false}) {
  final TextStyle? labelStyle = isTablet
      ? AppTextStyles.labelNumbers.copyWith(
          fontSize: 14,
          color: AppColors.textPlaceholder,
        )
      : null;
  final TextStyle? valueStyle = isTablet
      ? AppTextStyles.labelNumbers.copyWith(fontSize: 14)
      : null;
  final double labelWidth = isTablet ? 150 : 126;

  _InfoRow row(String label, String value) => _InfoRow(
        label: label,
        value: value,
        labelStyle: labelStyle,
        valueStyle: valueStyle,
        labelWidth: labelWidth,
      );

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Pneu ${pneu.nroPneu}', style: AppTextStyles.body),
      const SizedBox(height: 21),
      Container(height: 2, color: AppColors.primary),
      const SizedBox(height: 22),
      row('Posição', pneu.localEixo),
      const SizedBox(height: 17),
      row('Marca', pneu.marca),
      const SizedBox(height: 17),
      row('Modelo', pneu.modelo),
      const SizedBox(height: 17),
      row('Dimensão', pneu.dimensao),
      const SizedBox(height: 17),
      row('Tipo', pneu.tipo),
      const SizedBox(height: 17),
      row('Qtd. Vida', pneu.vidaPneu),
      const SizedBox(height: 17),
      row('KM Rodado', pneu.kmRodado),
      const SizedBox(height: 17),
      row('KM Ult. Vei.', pneu.kmAtuVei),
      const SizedBox(height: 17),
      row('D. Ult. Atualização', pneu.dataAtzKm),
      const SizedBox(height: 16),
    ],
  );
}

class _CloseIconPainter extends CustomPainter {
  const _CloseIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

_InfoRow _veiculoInfoRow(String label, String value, {bool isTablet = false}) {
  final fontSize = isTablet ? 14.0 : 12.0;
  return _InfoRow(
    label: label,
    value: value,
    labelStyle: AppTextStyles.labelNumbers.copyWith(
      color: AppColors.textPlaceholder,
      fontSize: fontSize,
    ),
    valueStyle: AppTextStyles.labelNumbers.copyWith(fontSize: fontSize),
    labelWidth: isTablet ? 56 : 66,
    verticalPadding: isTablet ? 0 : 7,
  );
}

class _VeiculoCard extends StatelessWidget {
  final Veiculo veiculo;
  final bool isTablet;

  const _VeiculoCard({
    required this.veiculo,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return SizedBox(
      width: isTablet ? 740 : null,
      height: isTablet ? 124 : 210,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: AppColors.textHint, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 16),
              color: AppColors.primary,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/frota-icon.svg',
                    width: 25.64,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: isTablet ? 13 : 8),
                  Text(
                    '${veiculo.placa} - Frota ${veiculo.nroFrota}',
                    style: AppTextStyles.labelFloatButton,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: isTablet
                    ? const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.textHint,
                            width: 1,
                          ),
                        ),
                      )
                    : null,
                padding: isTablet
                    ? const EdgeInsets.fromLTRB(14, 17, 16, 11)
                    : const EdgeInsets.fromLTRB(20, 17, 20, 11),
                child: isTablet
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 331,
                                child: _veiculoInfoRow(
                                  'Marca', veiculo.marca, isTablet: true),
                              ),
                              SizedBox(
                                width: 247,
                                child: _veiculoInfoRow(
                                  'Ano',
                                  veiculo.anoModelo.isEmpty
                                      ? veiculo.ano
                                      : '${veiculo.ano}/${veiculo.anoModelo}',
                                  isTablet: true,
                                ),
                              ),
                              Expanded(
                                child: _veiculoInfoRow(
                                  'Tipo', veiculo.tipo, isTablet: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              SizedBox(
                                width: 331,
                                child: _veiculoInfoRow(
                                  'Modelo', veiculo.modelo, isTablet: true),
                              ),
                              SizedBox(
                                width: 247,
                                child: _veiculoInfoRow(
                                  'Cor', veiculo.cor, isTablet: true),
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _veiculoInfoRow('Marca', veiculo.marca),
                          _veiculoInfoRow('Modelo', veiculo.modelo),
                          _veiculoInfoRow(
                            'Ano',
                            veiculo.anoModelo.isEmpty
                                ? veiculo.ano
                                : '${veiculo.ano}/${veiculo.anoModelo}',
                          ),
                          _veiculoInfoRow('Cor', veiculo.cor),
                          _veiculoInfoRow('Tipo', veiculo.tipo),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double? labelWidth;
  final double verticalPadding;

  const _InfoRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.labelWidth = 126,
    this.verticalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLabelStyle = labelStyle ??
        AppTextStyles.labelNumbers.copyWith(
          color: AppColors.textPlaceholder,
        );
    final resolvedValueStyle = valueStyle ?? AppTextStyles.labelNumbers;

    final labelText = Text(label, style: resolvedLabelStyle);
    final valueText = Text(value, style: resolvedValueStyle);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: labelWidth != null
          ? Row(
              children: [
                SizedBox(width: labelWidth, child: labelText),
                Expanded(child: valueText),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [labelText, valueText],
            ),
    );
  }
}
