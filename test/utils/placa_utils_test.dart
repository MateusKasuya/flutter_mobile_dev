import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/utils/placa_utils.dart';

void main() {
  group('extractPlaca', () {
    test('extrai placa Mercosul simples', () {
      expect(extractPlaca('ABC1D23'), 'ABC1D23');
    });

    test('extrai placa formato antigo', () {
      expect(extractPlaca('ABC1234'), 'ABC1234');
    });

    test('ignora texto BRASIL e extrai placa Mercosul', () {
      expect(extractPlaca('ABC1D23\nBRASIL'), 'ABC1D23');
    });

    test('ignora cidade e estado', () {
      expect(extractPlaca('ABC1D23\nSÃO PAULO\nSP\nBRASIL'), 'ABC1D23');
    });

    test('extrai placa antiga com cidade e estado', () {
      expect(extractPlaca('ABC1234\nRIO DE JANEIRO\nRJ\nBRASIL'), 'ABC1234');
    });

    test('remove hífens antes de validar', () {
      expect(extractPlaca('ABC-1D23'), 'ABC1D23');
    });

    test('remove hífens da placa antiga', () {
      expect(extractPlaca('ABC-1234'), 'ABC1234');
    });

    test('funciona com letras minúsculas', () {
      expect(extractPlaca('abc1d23'), 'ABC1D23');
    });

    test('retorna null quando texto não contém placa', () {
      expect(extractPlaca('BRASIL\nSÃO PAULO\nSP'), isNull);
    });

    test('retorna null para string vazia', () {
      expect(extractPlaca(''), isNull);
    });

    test('retorna null para texto aleatório', () {
      expect(extractPlaca('HELLO WORLD 123'), isNull);
    });

    test('extrai placa quando há múltiplas linhas com ruído', () {
      expect(
        extractPlaca('   BRASIL\n  ABC1D23  \nSÃO PAULO SP'),
        'ABC1D23',
      );
    });
  });
}
