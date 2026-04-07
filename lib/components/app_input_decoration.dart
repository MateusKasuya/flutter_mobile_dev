import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Decoração padrão para campos de entrada (CpfField, PasswordField, etc.).
InputDecoration appInputDecoration({
  required String hintText,
  Widget? suffixIcon,
}) {
  const borderRadius = BorderRadius.all(Radius.circular(10));
  const border = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(width: 2, color: AppColors.primaryBorder),
  );

  return InputDecoration(
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    hintText: hintText,
    hintStyle: AppTextStyles.inputHint,
    suffixIcon: suffixIcon,
  );
}
