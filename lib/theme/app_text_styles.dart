import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto Montserrat reutilizáveis.
/// Nomes baseados no uso, não no tamanho.
class AppTextStyles {
  static TextStyle heading = GoogleFonts.montserrat(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textDark,
  );

  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.white,
  );

  static TextStyle label = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textMuted,
  );

  static TextStyle inputHint = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textHint,
  );

  static TextStyle checkboxLabel = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textMuted,
  );

  static TextStyle footer = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textMuted,
  );

  static TextStyle splashTagline = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.white,
  );

  static TextStyle body = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textBody
  );

  static TextStyle bigNumbers = GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textBody
  );

  static TextStyle labelNumbers = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textBody
  );

  static TextStyle labelFloatButton = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.white
  );

  static TextStyle labelBar = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textBody
  );

  static TextStyle labelCardMovements = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.white
  );

    static TextStyle sublabelCardMovements = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.white
  );
}
