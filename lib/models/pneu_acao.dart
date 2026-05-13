import 'package:flutter/material.dart';

/// Ações que podem ser executadas ao arrastar um pneu para uma zona.
enum PneuAcao {
  estoque(
    'Estoque',
    Icons.inventory_2,
    Color(0xFF1976D2),
    bgColor: Color(0xFFDDEBFF),
    borderColor: Color(0xFF2371DE),
    asset: 'assets/estoque.svg',
  ),
  conserto(
    'Conserto',
    Icons.build,
    Color(0xFFF57C00),
    bgColor: Color(0xFFFFE6CB),
    borderColor: Color(0xFFFF8126),
    asset: 'assets/conserto.svg',
    mirrorX: true,
  ),
  recapagem(
    'Recapagem',
    Icons.autorenew,
    Color(0xFF388E3C),
    bgColor: Color(0xFFF0EEFF),
    borderColor: Color(0xFF7D00DE),
    asset: 'assets/recapagem.svg',
  ),
  sucata(
    'Sucata',
    Icons.delete_outline,
    Color(0xFFD32F2F),
    bgColor: Color(0xFFFFE2E2),
    borderColor: Color(0xFFF03E26),
    asset: 'assets/sucata.svg',
  ),
  venda(
    'Venda',
    Icons.attach_money,
    Color(0xFF7B1FA2),
    bgColor: Color(0xFFE2FBC3),
    borderColor: Color(0xFF00AF3E),
    asset: 'assets/venda.svg',
  );

  final String label;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final Color? borderColor;
  final String? asset;
  final bool mirrorX;

  const PneuAcao(
    this.label,
    this.icon,
    this.color, {
    this.bgColor,
    this.borderColor,
    this.asset,
    this.mirrorX = false,
  });
}
