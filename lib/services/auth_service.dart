import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_error.dart';

/// Faz login na API e retorna o token de autenticação.
///
/// Lança uma [Exception] com uma mensagem amigável se o login falhar.
/// [client] permite injetar um cliente HTTP nos testes; em produção criamos um
/// cliente próprio e o fechamos ao final (padrão create-or-close, igual aos
/// demais serviços).
Future<String> login(
  String cpfusuario,
  String senhausuario, {
  http.Client? client,
}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(apiBaseUrl, '/sftlogin/login');
    final response = await c.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cpfusuario': cpfusuario,
        'senhausuario': senhausuario,
      }),
    );

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['access_token'] as String;
    }

    // Falha no login. O 401 do gateway (senha errada — o caso mais comum) chega
    // com o corpo VAZIO, então não dá para fazer jsonDecode direto: isso lançava
    // um FormatException que chegava embaralhado na tela. apiException já trata
    // corpo vazio/não-JSON e cai numa mensagem padrão com o código HTTP.
    throw apiException(
      response,
      'Não foi possível entrar. Verifique seu CPF e senha.',
    );
  } finally {
    if (createdClient) {
      c.close();
    }
  }
}
