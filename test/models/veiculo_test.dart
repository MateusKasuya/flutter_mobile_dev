import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';

Map<String, dynamic> _makePneuJson() => {
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

void main() {
  group('Veiculo.fromJson', () {
    test('cria Veiculo com lista de pneus a partir de JSON válido', () {
      final json = {
        'PLACA': 'ABC1D23',
        'NROFROTA': '001',
        'MARCA': 'Marca Y',
        'MODELO': 'Modelo X',
        'ANO': '2020',
        'ANOMODELO': '2021',
        'COR': 'Branco',
        'TIPO': 'Caminhão',
        'pneus': [_makePneuJson()],
      };

      final veiculo = Veiculo.fromJson(json);

      expect(veiculo.placa, 'ABC1D23');
      expect(veiculo.nroFrota, '001');
      expect(veiculo.marca, 'Marca Y');
      expect(veiculo.modelo, 'Modelo X');
      expect(veiculo.ano, '2020');
      expect(veiculo.anoModelo, '2021');
      expect(veiculo.cor, 'Branco');
      expect(veiculo.tipo, 'Caminhão');
      expect(veiculo.pneus, hasLength(1));
      expect(veiculo.pneus.first, isA<Pneu>());
      expect(veiculo.pneus.first.marca, 'Pirelli');
    });

    test('cria Veiculo com lista de pneus vazia', () {
      final json = {
        'PLACA': 'XYZ9K88',
        'NROFROTA': '002',
        'MARCA': 'Marca Z',
        'MODELO': 'Modelo W',
        'ANO': '2022',
        'ANOMODELO': '2023',
        'COR': 'Preto',
        'TIPO': 'Van',
        'pneus': [],
      };

      final veiculo = Veiculo.fromJson(json);

      expect(veiculo.placa, 'XYZ9K88');
      expect(veiculo.pneus, isEmpty);
    });
  });
}
