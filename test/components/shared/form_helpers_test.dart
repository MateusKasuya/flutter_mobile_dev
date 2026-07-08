import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/components/shared/form_helpers.dart';

void main() {
  // Um TextInputFormatter transforma o texto a cada digitação: recebe o valor
  // antigo e o novo (TextEditingValue = texto + posição do cursor/seleção) e
  // devolve o valor final. Testamos chamando formatEditUpdate direto, sem
  // widget, simulando "digitar tudo de uma vez" (oldValue vazio -> newValue).
  TextEditingValue apply(TextInputFormatter formatter, String texto) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: texto),
    );
  }

  group('BrazilianCurrencyFormatter', () {
    final formatter = BrazilianCurrencyFormatter();

    test('formata dígitos tratando os dois últimos como centavos', () {
      expect(apply(formatter, '1234567').text, '12.345,67');
    });

    test('preenche zeros à esquerda em valores curtos', () {
      expect(apply(formatter, '5').text, '0,05');
    });

    test('remove zeros à esquerda dos reais', () {
      expect(apply(formatter, '001234').text, '12,34');
    });

    test('mantém texto vazio quando não há dígitos', () {
      expect(apply(formatter, '').text, '');
    });

    test('deixa o cursor colapsado no fim do texto', () {
      final result = apply(formatter, '1234567');
      expect(result.selection, TextSelection.collapsed(offset: result.text.length));
    });
  });

  group('ThousandsSeparatorFormatter', () {
    final formatter = ThousandsSeparatorFormatter();

    test('aplica separador de milhar', () {
      expect(apply(formatter, '1234567').text, '1.234.567');
    });

    test('mantém texto vazio quando não há dígitos', () {
      expect(apply(formatter, '').text, '');
    });

    test('deixa o cursor colapsado no fim do texto', () {
      final result = apply(formatter, '1234567');
      expect(result.selection, TextSelection.collapsed(offset: result.text.length));
    });
  });

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
