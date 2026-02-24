import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final maskFormatter = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: {'#': RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

/// Retorna true se o CPF (com ou sem máscara) for válido.
bool isValidCpf(String cpf) {
  final digits = cpf.replaceAll(RegExp(r'[^\d]'), '');

  if (digits.length != 11) return false;

  // Rejeita CPFs com todos os dígitos iguais (ex: 111.111.111-11)
  if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;

  int calcDigit(int length) {
    int sum = 0;
    for (int i = 0; i < length; i++) {
      sum += int.parse(digits[i]) * (length + 1 - i);
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  if (calcDigit(9) != int.parse(digits[9])) return false;
  return calcDigit(10) == int.parse(digits[10]);
}
