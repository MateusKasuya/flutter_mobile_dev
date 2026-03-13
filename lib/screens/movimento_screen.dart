import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frota_facil_mobile/theme/app_colors.dart';
import 'package:frota_facil_mobile/theme/app_text_styles.dart';

import 'frota_busca_screen.dart';

class MovimentoScreen extends StatelessWidget {
  const MovimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 91,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Adicionar Movimento', style: AppTextStyles.labelBar, textAlign: TextAlign.center,),
      ),
      backgroundColor: AppColors.backgroundScreen,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(30),
          children: <Widget>[
            _MovimentoCard(
              label: 'Frotas',
              subtitle: 'Movimentações de Frota',
              svgAsset: 'assets/frota-icon.svg',
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
            ),
            const SizedBox(height: 30),
            _MovimentoCard(
              label: 'Abastecimento',
              subtitle: 'Registro de Abastecimento',
              svgAsset: 'assets/abastec-icon.svg',
              labelFontSize: 22,
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
  });

  final String label;
  final String subtitle;
  final String svgAsset;
  final double? labelFontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 130,
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
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
    );
  }
}
