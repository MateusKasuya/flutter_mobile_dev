import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';

Map<String, dynamic> _makePneuJson() => {
      'nropneu': '1',
      'nroserie': 'SR123456',
      'marca': 'Pirelli',
      'modelo': 'Modelo A',
      'dimensao': '295/80R22.5',
      'tipo': 'Radial',
      'situacao': 'Em uso',
      'localeixo': 'Dianteiro esquerdo',
      'codesqeixo': '1',
      'localizacao': '1',
      'nrodot': '4523',
      'indrecapagem': 'N',
      'vidapneu': '80',
      'kmrodado': '50000',
      'kmacumulador': '40000',
      'kmatuvei': '150000',
      // O 'O' maiúsculo é o formato real da API (camelCase de KMRODADO0..5).
      'kmrodadO0': '10000',
      'kmrodadO1': '10000',
      'kmrodadO2': '10000',
      'kmrodadO3': '10000',
      'kmrodadO4': '10000',
      'kmrodadO5': '0',
      'datacompra': '2023-01-15',
      'dataatzkm': '2024-06-01',
      'codfil': '01',
      'nrofrota': '001',
      'placa': 'ABC1D23',
    };

void main() {
  group('Veiculo.fromJson', () {
    test('cria Veiculo com lista de pneus a partir de JSON válido', () {
      final json = {
        'placa': 'ABC1D23',
        'nrofrota': '001',
        'marca': 'Marca Y',
        'modelo': 'Modelo X',
        'ano': '2020',
        'anomodelo': '2021',
        'cor': 'Branco',
        'tipo': 'Caminhão',
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
        'placa': 'XYZ9K88',
        'nrofrota': '002',
        'marca': 'Marca Z',
        'modelo': 'Modelo W',
        'ano': '2022',
        'anomodelo': '2023',
        'cor': 'Preto',
        'tipo': 'Van',
        'pneus': [],
      };

      final veiculo = Veiculo.fromJson(json);

      expect(veiculo.placa, 'XYZ9K88');
      expect(veiculo.pneus, isEmpty);
    });

    // 'pneus' é nullable no contrato da API.
    test('cria Veiculo com pneus ausente no JSON', () {
      final veiculo = Veiculo.fromJson({'placa': 'XYZ9K88'});

      expect(veiculo.placa, 'XYZ9K88');
      expect(veiculo.pneus, isEmpty);
    });
  });
}
