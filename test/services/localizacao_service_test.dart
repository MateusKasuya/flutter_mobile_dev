import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:frota_facil_mobile/models/localizacao.dart';
import 'package:frota_facil_mobile/services/localizacao_service.dart';

void main() {
  group('Localizacao.fromJson', () {
    test('parseia JSON válido corretamente', () {
      final json = {
        'QTLOCALIZACAO': 10,
        'LOCALIZACAO': 'ESTOQUE',
      };

      final loc = Localizacao.fromJson(json);

      expect(loc.quantidade, 10);
      expect(loc.nome, 'ESTOQUE');
    });
  });

  group('fetchLocalizacoes', () {
    test('faz GET com header Authorization Bearer token', () async {
      http.Request? capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode([]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await fetchLocalizacoes('meu-token', client: client);

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.path, contains('qlocalizacaopneus'));
      expect(capturedRequest!.headers['Authorization'], 'Bearer meu-token');
    });

    test('retorna lista de localizações quando status 200', () async {
      final body = [
        {'QTLOCALIZACAO': 5, 'LOCALIZACAO': 'FROTA'},
        {'QTLOCALIZACAO': 3, 'LOCALIZACAO': 'SUCATA'},
      ];
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final result = await fetchLocalizacoes('token', client: client);

      expect(result.length, 2);
      expect(result[0].quantidade, 5);
      expect(result[0].nome, 'FROTA');
      expect(result[1].quantidade, 3);
      expect(result[1].nome, 'SUCATA');
    });

    test('lança Exception quando status não é 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Erro da API'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      expect(
        () => fetchLocalizacoes('token', client: client),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Erro da API'),
        )),
      );
    });

    test('lança Exception com mensagem genérica quando detail ausente',
        () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({}),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      expect(
        () => fetchLocalizacoes('token', client: client),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Erro ao buscar localizações'),
        )),
      );
    });
  });
}
