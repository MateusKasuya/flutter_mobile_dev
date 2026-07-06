import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frota_facil_mobile/services/frota_service.dart';

Map<String, dynamic> _veiculoJson() => {
      'placa': 'ABC1D23',
      'nrofrota': '001',
      'marca': 'Marca Y',
      'modelo': 'Modelo X',
      'ano': '2020',
      'anomodelo': '2021',
      'cor': 'Branco',
      'tipo': 'Caminhão',
      'pneus': [],
    };

void main() {
  group('fetchVeiculo', () {
    test('retorna Veiculo quando status 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['placa'], 'ABC1D23');
        expect(request.headers['Authorization'], 'Bearer token123');
        return http.Response(jsonEncode(_veiculoJson()), 200);
      });

      final veiculo =
          await fetchVeiculo('token123', 'ABC1D23', client: mockClient);

      expect(veiculo.placa, 'ABC1D23');
      expect(veiculo.marca, 'Marca Y');
    });

    test('lança exceção com mensagem amigável quando 404', () async {
      final mockClient = MockClient((_) async {
        return http.Response('{"detail": "Not found"}', 404);
      });

      expect(
        () => fetchVeiculo('token123', 'ZZZ0000', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Veiculo nao encontrado'),
          ),
        ),
      );
    });

    test('lança exceção com mensagem da API quando 422', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'detail': [
              {'msg': 'valor inválido'}
            ]
          }),
          422,
        );
      });

      expect(
        () => fetchVeiculo('token123', '', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('valor inválido'),
          ),
        ),
      );
    });
  });
}
