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
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Pneu ${pneu.nroPneu}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          _InfoRow(label: 'Posição', value: pneu.localEixo),
          _InfoRow(label: 'Marca', value: pneu.marca),
          _InfoRow(label: 'Modelo', value: pneu.modelo),
          _InfoRow(label: 'Dimensão', value: pneu.dimensao),
          _InfoRow(label: 'Tipo', value: pneu.tipo),
          _InfoRow(label: 'Qtd. Vida', value: pneu.vidaPneu),
          _InfoRow(label: 'KM Rodado', value: pneu.kmRodado),
          _InfoRow(label: 'KM Ult. Vei.', value: pneu.kmAtuVei),
          _InfoRow(label: 'D. Ult. Atualização', value: pneu.dataAtzKm),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
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
    this.labelWidth,
    this.verticalPadding = 4,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLabelStyle = labelStyle ??
        TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
    final resolvedValueStyle =
        valueStyle ?? const TextStyle(fontWeight: FontWeight.w500);

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
