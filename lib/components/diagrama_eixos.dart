import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/eixo.dart';
import '../models/pneu.dart';
import 'diagrama_eixos/base_frame.dart';
import 'diagrama_eixos/esquema_eixo.dart';
import 'diagrama_eixos/frame_moto.dart';

/// Diagrama de eixos do veículo visto de cima.
///
/// Despacha para o frame correto a partir do `codEsqEixo` do veículo. Quando
/// esse código não vem preenchido, cai no `codEsqEixo` do primeiro pneu da
/// lista. Esquemas desconhecidos caem no frame TOCO como fallback.
class DiagramaEixos extends StatelessWidget {
  final List<Eixo> eixos;

  /// Código do esquema de eixos vindo do veículo (nível externo da API).
  /// É a fonte de verdade; o código dos pneus só é usado se este vier vazio.
  final String codEsqEixo;

  final bool isTablet;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const DiagramaEixos({
    super.key,
    required this.eixos,
    this.codEsqEixo = '',
    this.isTablet = false,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (eixos.isEmpty) return const SizedBox.shrink();

    // Prioriza o código do veículo; se vier vazio, tenta extrair de um pneu.
    final codigo = codEsqEixo.isNotEmpty ? codEsqEixo : _extrairCodigo(eixos);
    final esquema = EsquemaEixo.fromCodigo(codigo) ?? EsquemaEixo.toco;
    final frame = _buildFrame(esquema);

    // Em telas com altura suficiente, ocupa todo o espaço disponível (mantém
    // o comportamento original). Em telas apertadas, fixa uma altura mínima
    // baseada no nº de eixos e habilita scroll vertical pra evitar que o
    // diagrama fique achatado.
    return LayoutBuilder(
      builder: (context, constraints) {
        // 110px de overhead (paddings internos, indicador "Frente",
        // parachoque/pino-rei) + 130px por eixo (70 do tile + ~60 de respiro,
        // pra cada eixo ficar com um "slot" parecido com o de telas maiores).
        final minHeight = 110.0 + eixos.length * 130.0;
        final height = math.max(constraints.maxHeight, minHeight);

        return SingleChildScrollView(
          child: SizedBox(height: height, child: frame),
        );
      },
    );
  }

  Widget _buildFrame(EsquemaEixo esquema) {
    switch (esquema) {
      // Caso especial: chassi único, pneus em coluna centralizada.
      case EsquemaEixo.moto:
        return FrameMoto(
          eixos: eixos,
          isTablet: isTablet,
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
          isTablet: isTablet,
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
          isTablet: isTablet,
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
          isTablet: isTablet,
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
          isTablet: isTablet,
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
