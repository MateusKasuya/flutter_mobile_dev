import 'package:flutter/material.dart';

/// Ações que podem ser executadas ao arrastar um pneu para uma zona.
enum PneuAcao {
  estoque('Estoque', Icons.inventory_2, Color(0xFF1976D2)),
  conserto('Conserto', Icons.build, Color(0xFFF57C00)),
  recapagem('Recapagem', Icons.autorenew, Color(0xFF388E3C)),
  sucata('Sucata', Icons.delete_outline, Color(0xFFD32F2F)),
  venda('Venda', Icons.attach_money, Color(0xFF7B1FA2));

  final String label;
  final IconData icon;
  final Color color;

  const PneuAcao(this.label, this.icon, this.color);
}
