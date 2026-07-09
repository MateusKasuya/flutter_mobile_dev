import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    // ColorScheme.fromSeed gera uma paleta harmônica a partir da cor semente,
    // mas ajusta tonalmente o próprio primary. Com copyWith fixamos o primary
    // exatamente em AppColors.primary para não termos "dois teais" no app.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ).copyWith(primary: AppColors.primary);
    return ThemeData(colorScheme: colorScheme);
  }
}