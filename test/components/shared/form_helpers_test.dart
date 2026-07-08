import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/components/shared/form_helpers.dart';

void main() {
  group('parseDate', () {
    test('converte DD/MM/AAAA em DateTime', () {
      expect(parseDate('03/07/2026'), DateTime(2026, 7, 3));
    });

    test('retorna null para formato inválido', () {
      expect(parseDate(''), isNull);
      expect(parseDate('2026-07-03'), isNull);
      expect(parseDate('aa/bb/cccc'), isNull);
    });
  });

  group('parseCurrency', () {
    test('converte o formato da máscara de moeda em double', () {
      expect(parseCurrency('12.345,67'), 12345.67);
      expect(parseCurrency('0,50'), 0.50);
      expect(parseCurrency('150,00'), 150.0);
    });

    test('retorna null para string vazia ou inválida', () {
      expect(parseCurrency(''), isNull);
      expect(parseCurrency('abc'), isNull);
    });
  });

  group('parseKm', () {
    test('extrai o número de valores com e sem separador de milhar', () {
      expect(parseKm('12.345'), 12345);
      expect(parseKm('80000'), 80000);
      expect(parseKm('1.234.567'), 1234567);
    });

    test('retorna null quando não há dígitos', () {
      expect(parseKm(''), isNull);
      expect(parseKm('—'), isNull);
      expect(parseKm('abc'), isNull);
    });
  });

  group('parseApiDate', () {
    test('aceita ISO com e sem componente de hora', () {
      expect(parseApiDate('2026-07-03'), DateTime(2026, 7, 3));
      expect(parseApiDate('2026-07-03T14:25:00'), DateTime(2026, 7, 3));
    });

    test('aceita DD/MM/AAAA', () {
      expect(parseApiDate('03/07/2026'), DateTime(2026, 7, 3));
    });

    test('retorna null para vazio ou formato desconhecido', () {
      expect(parseApiDate(''), isNull);
      expect(parseApiDate('sem data'), isNull);
    });
  });
}
