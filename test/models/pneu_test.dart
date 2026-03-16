import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';

void main() {
  group('Pneu.fromJson', () {
    test('cria Pneu a partir de JSON válido', () {
      final json = {
        'NROPNEU': '1',
        'NROSERIE': 'SR123456',
        'MARCA': 'Pirelli',
        'MODELO': 'Modelo A',
        'DIMENSAO': '295/80R22.5',
        'TIPO': 'Radial',
        'SITUACAO': 'Em uso',
        'LOCALEIXO': 'Dianteiro esquerdo',
        'CODESQEIXO': '1',
        'LOCALIZACAO': '1',
        'NRODOT': '4523',
        'INDRECAPAGEM': 'N',
        'VIDAPNEU': '80',
        'KMRODADO': '50000',
        'KMACUMULADOR': '40000',
        'KMATUVEI': '150000',
        'KMRODADO0': '10000',
        'KMRODADO1': '10000',
        'KMRODADO2': '10000',
        'KMRODADO3': '10000',
        'KMRODADO4': '10000',
        'KMRODADO5': '0',
        'DATACOMPRA': '2023-01-15',
        'DATAATZKM': '2024-06-01',
        'CODFIL': '01',
        'NROFROTA': '001',
        'PLACA': 'ABC1D23',
      };

      final pneu = Pneu.fromJson(json);

      expect(pneu.nroPneu, '1');
      expect(pneu.marca, 'Pirelli');
      expect(pneu.dimensao, '295/80R22.5');
      expect(pneu.situacao, 'Em uso');
      expect(pneu.localEixo, 'Dianteiro esquerdo');
      expect(pneu.vidaPneu, '80');
      expect(pneu.kmRodado, '50000');
      expect(pneu.placa, 'ABC1D23');
    });

    test('usa string vazia para campos ausentes no JSON', () {
      final pneu = Pneu.fromJson({});

      expect(pneu.nroPneu, '');
      expect(pneu.marca, '');
      expect(pneu.placa, '');
    });
  });
}
