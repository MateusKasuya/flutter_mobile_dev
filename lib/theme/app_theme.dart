import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0XFF028687);
  //static const Color textColor = Color(0xFF414F56);

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);
    return ThemeData(
      colorScheme: colorScheme
    );
  }
}