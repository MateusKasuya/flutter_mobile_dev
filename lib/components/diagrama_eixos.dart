import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/eixo.dart';
import '../models/pneu.dart';
import '../theme/app_colors.dart';

/// Diagrama esquemático de eixos do veículo visto de cima.
///
/// Exibe os eixos como linhas horizontais, os pneus como retângulos
/// arrastáveis e o chassis como linhas verticais conectando os eixos.
///
/// Interações:
/// - Toque rápido no pneu → [onPneuTap]
/// - Segurar + arrastar → [LongPressDraggable] com dado [Pneu]
class DiagramaEixos extends StatelessWidget {
  final List<Eixo> eixos;
  final void Function(Pneu pneu)? onPneuTap;

  const DiagramaEixos({
    super.key,
    required this.eixos,
    this.onPneuTap,
  });

  @override
  Widget build(BuildContext context) {
    if (eixos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const _DirecaoIndicator(),
          const SizedBox(height: 16),
          for (int i = 0; i < eixos.length; i++) ...[
            _EixoRow(eixo: eixos[i], onPneuTap: onPneuTap),
            if (i < eixos.length - 1) const _ChassisConnector(),
          ],
        ],
      ),
    );
  }
}

/// Seta indicando a frente do veículo.
class _DirecaoIndicator extends StatelessWidget {
  const _DirecaoIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_upward, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          'Frente',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

/// Uma linha de eixo: pneus à esquerda, linha horizontal, pneus à direita.
class _EixoRow extends StatelessWidget {
  final Eixo eixo;
  final void Function(Pneu pneu)? onPneuTap;

  const _EixoRow({required this.eixo, this.onPneuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Linha do eixo (fundo, largura total)
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Pneus posicionados nas extremidades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLado(
                externo: eixo.esquerdoExterno,
                interno: eixo.esquerdoInterno,
              ),
              // Label do eixo no centro
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'E${eixo.numero}',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              _buildLado(
                externo: eixo.direitoExterno,
                interno: eixo.direitoInterno,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLado({Pneu? externo, Pneu? interno}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PneuTile(pneu: externo, onTap: onPneuTap),
        if (interno != null) ...[
          const SizedBox(width: 4),
          _PneuTile(pneu: interno, onTap: onPneuTap),
        ],
      ],
    );
  }
}

/// Linhas verticais conectando eixos, representando o chassis.
class _ChassisConnector extends StatelessWidget {
  const _ChassisConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Retângulo que representa um pneu individual.
///
/// Duas interações:
/// - **Toque rápido** → chama [onTap]
/// - **Segurar + arrastar** → [LongPressDraggable] com dado [Pneu]
class _PneuTile extends StatelessWidget {
  final Pneu? pneu;
  final void Function(Pneu pneu)? onTap;

  const _PneuTile({this.pneu, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (pneu == null) {
      return const SizedBox(width: 52, height: 28);
    }

    return LongPressDraggable<Pneu>(
      data: pneu,
      feedback: Material(
        color: Colors.transparent,
        child: _buildContent(dragging: true),
      ),
      childWhenDragging: Container(
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: () => onTap?.call(pneu!),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent({bool dragging = false}) {
    return Container(
      width: 52,
      height: 28,
      decoration: BoxDecoration(
        color: dragging ? AppColors.primary : const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: dragging ? AppColors.primary : Colors.grey.shade600,
          width: 1,
        ),
        boxShadow: dragging
            ? const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          pneu!.nroPneu,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
