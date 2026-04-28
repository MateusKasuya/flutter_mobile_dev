import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frota_facil_mobile/services/fornecedor_service.dart';

void main() {
  group('fetchFornecedores', () {
    test('retorna lista de fornecedores quando status 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api-frota/fornecedor/getfornecedor');
        expect(request.headers['Authorization'], 'Bearer token123');
        return http.Response(
          jsonEncode([
            {
              'CGCCPFFORNE': '12.345.678/0001-90',
              'RAZAOSOCIAL': 'Recapagem Brasil LTDA',
              'NOMEFANTASIA': 'Recap BR',
            },
            {
              'CGCCPFFORNE': '98.765.432/0001-10',
              'RAZAOSOCIAL': 'Pneus do Sul S/A',
              'NOMEFANTASIA': '',
            },
          ]),
          200,
        );
      });

      final fornecedores =
          await fetchFornecedores('token123', client: mockClient);

      expect(fornecedores, hasLength(2));
      expect(fornecedores[0].cgcCpf, '12.345.678/0001-90');
      expect(fornecedores[0].razaoSocial, 'Recapagem Brasil LTDA');
      expect(fornecedores[0].nomeFantasia, 'Recap BR');
      expect(fornecedores[1].nomeFantasia, '');
    });

    test('lança exceção com mensagem da API quando 422', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'detail': [
              {'msg': 'sessão inválida'}
            ]
          }),
          422,
        );
      });

      expect(
        () => fetchFornecedores('token123', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('sessão inválida'),
          ),
        ),
      );
    });

    test('lança exceção genérica quando detail ausente', () async {
      final mockClient = MockClient((_) async {
        return http.Response('{}', 500);
      });

      expect(
        () => fetchFornecedores('token123', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao buscar fornecedores'),
          ),
        ),
      );
    });
  });
}
