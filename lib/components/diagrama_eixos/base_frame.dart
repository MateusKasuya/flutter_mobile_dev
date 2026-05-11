import 'package:flutter/material.dart';

import '../../models/eixo.dart';
import '../../models/pneu.dart';
import 'primitives.dart';

/// Tipo de extremidade do frame (dianteira ou traseira).
enum FrameTerminus {
  /// Parachoque sólido (caminhões, carros — ponta fechada).
  parachoque,

  /// Pino-rei / quinta-roda (cavalos no traseiro, carretas no dianteiro).
  pinoRei,

  /// Sem ponta visual (motos, ou quando a extremidade fica aberta).
  nenhum,
}

/// Distribuição vertical dos eixos dentro do corpo do veículo.
enum AxleLayout {
  /// Distribui os eixos uniformemente pelo corpo.
  /// Usado por TOCO, passeio, bitruck/ônibus, cavalos.
  espacado,

  /// Eixos agrupados na traseira, próximos uns dos outros.
  /// Usado por carretinha, carreta 1 eixo e carretas "curtas" (E, C).
  agrupadoTraseira,

  /// Eixos espalhados na traseira mas com gap maior entre eles.
  /// Usado por carretas "alongadas" (K, L) e carreta 4 eixos (P).
  espalhadoTraseira,
}

/// Frame genérico parametrizável: chassi com 2 longarinas, dois extremos
/// configuráveis (parachoque/pino-rei/nenhum) e os eixos no meio.
///
/// Cobre TOCO, PASSEIO, BITRUCK/ÔNIBUS, TRUCK/CAVALO e CARRETAs.
/// MOTO usa frame próprio ([FrameMoto]) por ter geometria diferente
/// (sem longarinas, pneus em coluna centrada).
class BaseFrame extends StatelessWidget {
  final List<Eixo> eixos;
  final FrameTerminus front;
  final FrameTerminus rear;
  final AxleLayout axleLayout;
  final bool isTablet;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const BaseFrame({
    super.key,
    required this.eixos,
    required this.front,
    required this.rear,
    this.axleLayout = AxleLayout.espacado,
    this.isTablet = false,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirecaoIndicator(isTablet: isTablet),
          SizedBox(height: isTablet ? 12 : 10),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: ChassisRails(isTablet: isTablet)),
                Column(
                  children: [
                    _terminus(front),
                    Expanded(child: _buildEixos()),
                    _terminus(rear),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _terminus(FrameTerminus type) {
    switch (type) {
      case FrameTerminus.parachoque:
        return Parachoque(isTablet: isTablet);
      case FrameTerminus.pinoRei:
        return const PinoRei();
      case FrameTerminus.nenhum:
        return const SizedBox(height: 14);
    }
  }

  Widget _buildEixos() {
    final rows = [
      for (final eixo in eixos)
        EixoRow(
          eixo: eixo,
          isTablet: isTablet,
          onPneuTap: onPneuTap,
          onPneuDoubleTap: onPneuDoubleTap,
          onSlotVazioDoubleTap: onSlotVazioDoubleTap,
        ),
    ];

    switch (axleLayout) {
      case AxleLayout.espacado:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rows,
        );
      case AxleLayout.agrupadoTraseira:
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _interleaveGap(rows, 6),
        );
      case AxleLayout.espalhadoTraseira:
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _interleaveGap(rows, 28),
        );
    }
  }

  List<Widget> _interleaveGap(List<Widget> rows, double gap) {
    final result = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      result.add(rows[i]);
      if (i < rows.length - 1) result.add(SizedBox(height: gap));
    }
    return result;
  }
}
