import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/utils/cpf_validator.dart';

void main() {
  group('isValidCpf', () {
    test('retorna true para CPF válido sem máscara', () {
      expect(isValidCpf('07069953925'), isTrue);
    });

    test('retorna true para CPF válido com máscara', () {
      expect(isValidCpf('070.699.539-25'), isTrue);
    });

    test('retorna false para CPF com dígitos verificadores errados', () {
      expect(isValidCpf('07069953900'), isFalse);
    });

    test('retorna false para CPF com todos dígitos iguais', () {
      expect(isValidCpf('11111111111'), isFalse);
      expect(isValidCpf('00000000000'), isFalse);
      expect(isValidCpf('99999999999'), isFalse);
    });

    test('retorna false para CPF com menos de 11 dígitos', () {
      expect(isValidCpf('1234567'), isFalse);
      expect(isValidCpf(''), isFalse);
    });

    test('retorna false para string vazia', () {
      expect(isValidCpf(''), isFalse);
    });
  });
}
