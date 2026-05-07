import 'package:flutter/material.dart';

import '../../models/eixo.dart';
import '../../models/pneu.dart';
import 'primitives.dart';

/// Frame da MOTO (esquema M).
///
/// Diferenças do [BaseFrame]:
/// - Sem 2 longarinas (chassi de moto é uma "espinha" central única).
/// - Sem parachoques.
/// - Pneus em coluna centralizada (não há distinção esquerdo/direito).
class FrameMoto extends StatelessWidget {
  final List<Eixo> eixos;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const FrameMoto({
    super.key,
    required this.eixos,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DirecaoIndicator(),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Espinha central (1 longarina única, no eixo do veículo)
                Center(
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final eixo in eixos)
                      _MotoEixoRow(
                        eixo: eixo,
                        onPneuTap: onPneuTap,
                        onPneuDoubleTap: onPneuDoubleTap,
                        onSlotVazioDoubleTap: onSlotVazioDoubleTap,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha de eixo da moto: 1 pneu centralizado.
/// O backend pode usar 'D' ou 'E' por convenção; pegamos o primeiro preenchido.
class _MotoEixoRow extends StatelessWidget {
  final Eixo eixo;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const _MotoEixoRow({
    required this.eixo,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final pneu = eixo.direitoExterno ?? eixo.esquerdoExterno;
    // Posição default para slot vazio: assume 'D' (direito) por convenção.
    final posicaoVazia = '${eixo.numero}D';

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Barra curta do eixo (atrás do pneu, faz o link com a espinha)
          Positioned(
            top: tireCenterFromTop - 2,
            child: Container(
              width: 36,
              height: 3,
              color: Colors.grey.shade400,
            ),
          ),
          PneuTile(
            pneu: pneu,
            onTap: onPneuTap,
            onDoubleTap: onPneuDoubleTap,
            onEmptyDoubleTap: pneu == null
                ? () => onSlotVazioDoubleTap?.call(posicaoVazia)
                : null,
          ),
        ],
      ),
    );
  }
}
