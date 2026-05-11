import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frota_facil_mobile/theme/app_colors.dart';
import 'package:frota_facil_mobile/theme/app_text_styles.dart';

import 'frota_busca_screen.dart';
import 'pneu_lista_screen.dart';

class MovimentoScreen extends StatelessWidget {
  const MovimentoScreen({super.key});

  // Acima dessa largura, renderizamos o layout de tablet.
  static const double _tabletBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    // MediaQuery.of(context).size.width devolve a largura atual da tela em pixels lógicos.
    final isTablet = MediaQuery.of(context).size.width >= _tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: isTablet
            ? SvgPicture.asset(
                'assets/logo_horizontal.svg',
                height: 22,
                width: 177.17,
              )
            : Text(
                'Adicionar Movimento',
                style: AppTextStyles.labelBar,
                textAlign: TextAlign.center,
              ),
      ),
      backgroundColor: AppColors.backgroundScreen,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(30),
          children: <Widget>[
            if (isTablet) ...[
              Text(
                'Adicionar Movimento',
                style: AppTextStyles.body.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
            _MovimentoCard(
              label: 'Frotas',
              subtitle: 'Movimentações de Frota',
              svgAsset: 'assets/frota-icon.svg',
              isTablet: isTablet,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FrotaBuscaScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            _MovimentoCard(
              label: 'Pneus',
              subtitle: 'Controle de Pneus',
              svgAsset: 'assets/pneu-icon.svg',
              isTablet: isTablet,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PneuListaScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            _MovimentoCard(
              label: 'Abastecimento',
              subtitle: 'Registro de Abastecimento',
              svgAsset: 'assets/abastec-icon.svg',
              labelFontSize: 22,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }
}

class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.subtitle,
    required this.svgAsset,
    this.labelFontSize,
    this.onTap,
    this.isTablet = false,
  });

  final String label;
  final String subtitle;
  final String svgAsset;
  final double? labelFontSize;
  final VoidCallback? onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
      onTap: onTap,
      child: Container(
      height: 130,
      width: isTablet ? 450 : 320,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 15,
            spreadRadius: 0,
            color: Color(0x4D000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 35, right: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(svgAsset),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: labelFontSize != null
                            ? AppTextStyles.labelCardMovements.copyWith(fontSize: labelFontSize)
                            : AppTextStyles.labelCardMovements,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle.toUpperCase(), style: AppTextStyles.sublabelCardMovements),
                ],
              ),
            ),
            SvgPicture.asset('assets/seta-icon.svg'),
          ],
        ),
      ),
      ),
      ),
    );
  }
}
