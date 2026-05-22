import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Adiciona separador de milhar (ponto) em uma string de dígitos.
String addThousandSeparator(String digits) {
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Formata um valor de KM (string da API) com separador de milhar.
String formatKm(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
  return addThousandSeparator(digits);
}

/// Formatter que aplica separador de milhar ao digitar.
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    final formatted = addThousandSeparator(digits);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter de moeda brasileira (R$): preenche da direita para a esquerda,
/// separando centavos com vírgula e milhar com ponto.
///
/// Exemplo: digitar "1234567" exibe "12.345,67".
class BrazilianCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Trata os dois últimos dígitos como centavos.
    final padded = digits.padLeft(3, '0');
    final centavos = padded.substring(padded.length - 2);
    final reaisRaw = padded.substring(0, padded.length - 2);

    // Remove zeros à esquerda e aplica separador de milhar.
    final reaisInt = int.tryParse(reaisRaw) ?? 0;
    final reaisStr = reaisInt.toString();
    final reaisFormatted = addThousandSeparator(reaisStr);

    final formatted = '$reaisFormatted,$centavos';
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formata um [DateTime] como DD/MM/AAAA.
String formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

/// Tenta converter uma string de data de formatos comuns da API para DD/MM/AAAA.
/// Suporta ISO (YYYY-MM-DD, YYYY-MM-DDTHH:MM:SS) e DD/MM/AAAA.
/// Retorna a string original se não conseguir parsear.
String normalizeDateStr(String raw) {
  if (raw.isEmpty) return raw;

  // Tenta ISO: YYYY-MM-DD ou YYYY-MM-DDTHH:MM:SS
  final iso = DateTime.tryParse(raw);
  if (iso != null) return formatDate(iso);

  // Já está em DD/MM/AAAA
  final parts = raw.split('/');
  if (parts.length == 3 && parts[0].length == 2 && parts[2].length == 4) {
    return raw;
  }

  return raw;
}

InputDecoration formInputDecoration({
  required String hint,
  Widget? suffix,
  double verticalPadding = 15,
  Color? borderColor,
}) {
  const borderRadius = BorderRadius.all(Radius.circular(10));
  final border = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(
      width: 2,
      color: borderColor ?? AppColors.primaryBorder,
    ),
  );
  return InputDecoration(
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(width: 2, color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(width: 2, color: Colors.red),
    ),
    hintText: hint,
    hintStyle: AppTextStyles.formInputHint,
    suffixIcon: suffix,
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: verticalPadding),
    filled: true,
    fillColor: Colors.white,
  );
}

/// Campo somente leitura com fundo cinza claro.
class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 7),
        TextFormField(
          initialValue: value.isEmpty ? '—' : value,
          readOnly: true,
          decoration: formInputDecoration(hint: '').copyWith(
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(width: 1, color: Colors.grey.shade300),
            ),
          ),
          style: AppTextStyles.inputText,
        ),
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.fieldLabel);
  }
}
