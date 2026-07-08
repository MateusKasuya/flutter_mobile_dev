import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Desenha o "X" de fechar (duas linhas diagonais) usado nos botões de
/// fechar das bottom sheets e diálogos.
///
/// [CustomPainter] é a classe do Flutter que permite desenhar diretamente
/// num [Canvas] via [CustomPaint]. Aqui traçamos as duas diagonais que
/// formam o X, com [StrokeCap.round] para as pontas arredondadas.
///
/// Os defaults ([AppColors.textMuted] / [strokeWidth] 3) cobrem o caso mais
/// comum; quem precisar de outra cor/espessura passa explicitamente.
class CloseXPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const CloseXPainter({
    this.color = AppColors.textMuted,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    // Diagonal "\": canto sup-esq → canto inf-dir
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    // Diagonal "/": canto sup-dir → canto inf-esq
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CloseXPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
