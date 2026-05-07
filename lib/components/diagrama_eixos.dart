import 'package:flutter/material.dart';

import '../models/eixo.dart';
import '../models/pneu.dart';
import 'diagrama_eixos/base_frame.dart';
import 'diagrama_eixos/esquema_eixo.dart';
import 'diagrama_eixos/frame_moto.dart';

/// Diagrama de eixos do veículo visto de cima.
///
/// Despacha para o frame correto a partir do `codEsqEixo` do primeiro pneu da
/// lista. Esquemas desconhecidos caem no frame TOCO como fallback.
class DiagramaEixos extends StatelessWidget {
  final List<Eixo> eixos;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const DiagramaEixos({
    super.key,
    required this.eixos,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (eixos.isEmpty) return const SizedBox.shrink();

    final esquema =
        EsquemaEixo.fromCodigo(_extrairCodigo(eixos)) ?? EsquemaEixo.toco;

    switch (esquema) {
      // Caso especial: chassi único, pneus em coluna centralizada.
      case EsquemaEixo.moto:
        return FrameMoto(
          eixos: eixos,
          onPneuTap: onPneuTap,
          onPneuDoubleTap: onPneuDoubleTap,
          onSlotVazioDoubleTap: onSlotVazioDoubleTap,
        );

      // Veículos com cabine + traseira fechada (parachoque nas duas pontas).
      case EsquemaEixo.toco:
      case EsquemaEixo.passeio:
      case EsquemaEixo.bitruck:
        return BaseFrame(
          eixos: eixos,
          front: FrameTerminus.parachoque,
          rear: FrameTerminus.parachoque,
          onPneuTap: onPneuTap,
          onPneuDoubleTap: onPneuDoubleTap,
          onSlotVazioDoubleTap: onSlotVazioDoubleTap,
        );

      // Cavalos mecânicos: parachoque dianteiro + pino-rei traseiro.
      // B/O e variantes diferem só nos dados (rodado duplo vs simples),
      // que já vêm pelo localEixo. Visualmente iguais.
      case EsquemaEixo.truckG:
      case EsquemaEixo.truckB:
      case EsquemaEixo.truckO:
      case EsquemaEixo.truckD:
        return BaseFrame(
          eixos: eixos,
          front: FrameTerminus.parachoque,
          rear: FrameTerminus.pinoRei,
          onPneuTap: onPneuTap,
          onPneuDoubleTap: onPneuDoubleTap,
          onSlotVazioDoubleTap: onSlotVazioDoubleTap,
        );

      // Carretinha + carretas com eixos curtos (agrupados na traseira).
      case EsquemaEixo.carretinha:
      case EsquemaEixo.carreta1J:
      case EsquemaEixo.carreta2E:
      case EsquemaEixo.carreta3C:
        return BaseFrame(
          eixos: eixos,
          front: FrameTerminus.pinoRei,
          rear: FrameTerminus.parachoque,
          axleLayout: AxleLayout.agrupadoTraseira,
          onPneuTap: onPneuTap,
          onPneuDoubleTap: onPneuDoubleTap,
          onSlotVazioDoubleTap: onSlotVazioDoubleTap,
        );

      // Carretas com eixos alongados (espalhados pelo corpo).
      case EsquemaEixo.carreta2K:
      case EsquemaEixo.carreta3L:
      case EsquemaEixo.carreta4P:
        return BaseFrame(
          eixos: eixos,
          front: FrameTerminus.pinoRei,
          rear: FrameTerminus.parachoque,
          axleLayout: AxleLayout.espalhadoTraseira,
          onPneuTap: onPneuTap,
          onPneuDoubleTap: onPneuDoubleTap,
          onSlotVazioDoubleTap: onSlotVazioDoubleTap,
        );
    }
  }

  String _extrairCodigo(List<Eixo> eixos) {
    for (final e in eixos) {
      for (final p in [
        e.esquerdoExterno,
        e.esquerdoInterno,
        e.direitoExterno,
        e.direitoInterno,
      ]) {
        if (p != null) return p.codEsqEixo;
      }
    }
    return '';
  }
}
