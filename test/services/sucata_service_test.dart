import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frota_facil_mobile/services/sucata_service.dart';

void main() {
  group('fetchMotivosSucateamento', () {
    test('retorna lista de motivos quando status 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api-frota/sucata/getsucata');
        expect(request.headers['Authorization'], 'Bearer token123');
        return http.Response(
          jsonEncode([
            {'codsuc': 1, 'descricao': 'Deslocamento de Borracha'},
            {'codsuc': 4, 'descricao': 'Não recapável'},
          ]),
          200,
        );
      });

      final motivos =
          await fetchMotivosSucateamento('token123', client: mockClient);

      expect(motivos, hasLength(2));
      expect(motivos[0].codigo, 1);
      expect(motivos[0].descricao, 'Deslocamento de Borracha');
      expect(motivos[1].label, '4 - Não recapável');
    });

    test('lança exceção com mensagem da API quando 422', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'detail': [
              {'msg': 'token expirado'}
            ]
          }),
          422,
        );
      });

      expect(
        () => fetchMotivosSucateamento('token123', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('token expirado'),
          ),
        ),
      );
    });

    test('lança exceção genérica quando detail ausente', () async {
      final mockClient = MockClient((_) async {
        return http.Response('{}', 500);
      });

      expect(
        () => fetchMotivosSucateamento('token123', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao buscar motivos'),
          ),
        ),
      );
    });
  });
}
