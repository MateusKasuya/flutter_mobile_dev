import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frota_facil_mobile/services/auth_service.dart';

void main() {
  group('login', () {
    test('retorna o access_token quando a API responde 202', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/sftlogin/login');
        expect(request.headers['Content-Type'], contains('application/json'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['cpfusuario'], '07069953925');
        expect(body['senhausuario'], 'senha123');

        return http.Response(jsonEncode({'access_token': 'meu-token'}), 202);
      });

      final token = await login('07069953925', 'senha123', client: mockClient);

      expect(token, 'meu-token');
    });

    test('lança mensagem amigável no 401 de corpo vazio (senha errada)',
        () async {
      // Regressão do bug corrigido: o gateway responde 401 com corpo VAZIO;
      // o antigo jsonDecode(response.body) lançava FormatException. Agora o
      // erro precisa ser legível e trazer o código HTTP.
      final mockClient = MockClient((_) async => http.Response('', 401));

      expect(
        () => login('07069953925', 'errada', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'mensagem',
            allOf(
              contains('Verifique seu CPF e senha'),
              contains('HTTP 401'),
            ),
          ),
        ),
      );
    });

    test('usa a mensagem do corpo quando a API responde {"detail": ...}',
        () async {
      final mockClient = MockClient(
        (_) async => http.Response(jsonEncode({'detail': 'Usuário inativo'}), 422),
      );

      expect(
        () => login('07069953925', 'senha123', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'mensagem',
            contains('Usuário inativo'),
          ),
        ),
      );
    });
  });
}
