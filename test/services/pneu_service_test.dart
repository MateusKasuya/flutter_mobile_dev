import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frota_facil_mobile/services/pneu_service.dart';

void main() {
  group('fetchPneus', () {
    test('faz GET no endpoint e desserializa a lista de pneus', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api-frota/pneu/getpneu');
        expect(request.headers['Authorization'], 'Bearer token123');

        // JSON no contrato da API (camelCase minúsculo). Só preenchemos
        // alguns campos; os demais caem no `?? ''` de Pneu.fromJson.
        return http.Response(
          jsonEncode([
            {'nropneu': '111', 'marca': 'Michelin'},
            {'nropneu': '222', 'marca': 'Pirelli'},
          ]),
          200,
        );
      });

      final pneus = await fetchPneus('token123', client: mockClient);

      expect(pneus.length, 2);
      expect(pneus.first.nroPneu, '111');
      expect(pneus.first.marca, 'Michelin');
    });

    test('retorna lista vazia quando a API devolve []', () async {
      final mockClient = MockClient((_) async {
        return http.Response('[]', 200);
      });

      final pneus = await fetchPneus('token123', client: mockClient);

      expect(pneus, isEmpty);
    });

    test('lança exceção com a mensagem padrão quando 401 com corpo vazio',
        () async {
      final mockClient = MockClient((_) async {
        return http.Response('', 401);
      });

      expect(
        () => fetchPneus('token123', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao buscar pneus (HTTP 401)'),
          ),
        ),
      );
    });

    test('lança exceção com a mensagem padrão quando 500', () async {
      final mockClient = MockClient((_) async {
        return http.Response('', 500);
      });

      expect(
        () => fetchPneus('token123', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao buscar pneus (HTTP 500)'),
          ),
        ),
      );
    });
  });

  group('movimentarPneu', () {
    test('envia o payload no contrato da API e retorna a mensagem', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api-frota/pneu/movimentarpneu');
        expect(request.headers['Authorization'], 'Bearer token123');
        expect(request.headers['Content-Type'], contains('application/json'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['nropneu'], 12345);
        expect(body['dataentrada'], '2026-07-03T00:00:00');
        expect(body['valor'], 0);
        expect(body['localizacao'], 'CONSERTO');
        expect(body['codfil'], 1);
        expect(body['kmentrada'], '120000');
        expect(body['codmotivosucat'], isNull);
        expect(body['motivosaida'], 'Desgaste irregular');
        // Campos de montagem não usados vão como null, igual ao exemplo
        // do swagger.
        expect(body['localeixo'], isNull);
        expect(body['codesqeixo'], isNull);
        expect(body['placa'], isNull);
        expect(body['nrofrota'], isNull);
        expect(body['cgccpfforne'], isNull);

        return http.Response(
          jsonEncode({
            'sucesso': true,
            'mensagem': 'Movimentacao de Pneu executada com Sucesso!',
          }),
          200,
        );
      });

      final mensagem = await movimentarPneu(
        'token123',
        nroPneu: 12345,
        dataEntrada: DateTime(2026, 7, 3),
        codFil: 1,
        localizacao: 'CONSERTO',
        kmEntrada: '120000',
        motivoSaida: 'Desgaste irregular',
        client: mockClient,
      );

      expect(mensagem, 'Movimentacao de Pneu executada com Sucesso!');
    });

    test('envia os campos de sucateamento quando informados', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['localizacao'], 'SUCATA');
        expect(body['codmotivosucat'], 4);
        return http.Response(
          jsonEncode({'sucesso': true, 'mensagem': 'OK'}),
          200,
        );
      });

      await movimentarPneu(
        'token123',
        nroPneu: 12345,
        dataEntrada: DateTime(2026, 7, 3),
        codFil: 1,
        localizacao: 'SUCATA',
        codMotivoSucat: 4,
        client: mockClient,
      );
    });

    test('envia os campos de montagem quando informados', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        // Montagem: campos do veículo preenchidos + localizacao de ORIGEM
        // do pneu (a API exige o campo em toda movimentação).
        expect(body['localizacao'], 'ESTOQUE');
        expect(body['localeixo'], '1DE');
        expect(body['codesqeixo'], 'ESQ01');
        expect(body['placa'], 'ABC1D23');
        expect(body['nrofrota'], 77);
        expect(body['kmentrada'], '120000');
        return http.Response(
          jsonEncode({
            'sucesso': true,
            'mensagem': 'Montagem de Pneu executada com Sucesso!',
          }),
          200,
        );
      });

      final mensagem = await movimentarPneu(
        'token123',
        nroPneu: 12345,
        dataEntrada: DateTime(2026, 7, 3),
        codFil: 1,
        localizacao: 'ESTOQUE',
        localEixo: '1DE',
        codEsqEixo: 'ESQ01',
        placa: 'ABC1D23',
        nroFrota: 77,
        kmEntrada: '120000',
        client: mockClient,
      );

      expect(mensagem, 'Montagem de Pneu executada com Sucesso!');
    });

    test('envia valor decimal e fornecedor na movimentação horizontal',
        () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        // Horizontal: sem veículo envolvido (kmentrada e campos de
        // montagem nulos), com custo/preço e fornecedor.
        expect(body['localizacao'], 'RECAPAGEM');
        expect(body['valor'], 12345.67);
        expect(body['cgccpfforne'], '12345678000199');
        expect(body['kmentrada'], isNull);
        expect(body['placa'], isNull);
        return http.Response(
          jsonEncode({'sucesso': true, 'mensagem': 'OK'}),
          200,
        );
      });

      await movimentarPneu(
        'token123',
        nroPneu: 12345,
        dataEntrada: DateTime(2026, 7, 3),
        codFil: 1,
        localizacao: 'RECAPAGEM',
        valor: 12345.67,
        cgcCpfForne: '12345678000199',
        client: mockClient,
      );
    });

    test('lança exceção com a mensagem da API quando 422', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'sucesso': false,
            'mensagem': 'Erro na atualização do Pneu!',
          }),
          422,
        );
      });

      expect(
        () => movimentarPneu(
          'token123',
          nroPneu: 12345,
          dataEntrada: DateTime(2026, 7, 3),
          codFil: 1,
          client: mockClient,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro na atualização do Pneu!'),
          ),
        ),
      );
    });

    test('lança exceção quando 200 vem com sucesso=false', () async {
      // Defensivo: o contrato diz que falha vem como 422, mas se o backend
      // responder 200 com sucesso=false não podemos tratar como êxito.
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({'sucesso': false, 'mensagem': 'Pneu bloqueado'}),
          200,
        );
      });

      expect(
        () => movimentarPneu(
          'token123',
          nroPneu: 12345,
          dataEntrada: DateTime(2026, 7, 3),
          codFil: 1,
          client: mockClient,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Pneu bloqueado'),
          ),
        ),
      );
    });

    test('usa mensagem padrão quando a resposta não tem corpo no contrato',
        () async {
      // Ex.: 401 do gateway, que vem com corpo vazio.
      final mockClient = MockClient((_) async {
        return http.Response('', 401);
      });

      expect(
        () => movimentarPneu(
          'token123',
          nroPneu: 12345,
          dataEntrada: DateTime(2026, 7, 3),
          codFil: 1,
          client: mockClient,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao movimentar pneu (HTTP 401)'),
          ),
        ),
      );
    });
  });
}
