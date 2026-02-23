import 'dart:convert';
import 'package:http/http.dart' as http;

// URL base da API — troque pelo endereço real do seu servidor
const String _baseUrl = 'fretefacilweb.ccmcloud.com.br:8624';

/// Faz login na API e retorna o token de autenticação.
///
/// Lança uma [Exception] com a mensagem de erro se o login falhar.
Future<String> login(String cpfusuario, String senhausuario) async {
  final url = Uri.http(_baseUrl, '/sftlogin/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'cpfusuario': cpfusuario, 'senhausuario': senhausuario}),
  );

  if (response.statusCode == 202) {
    final data = jsonDecode(response.body);
    return data['access_token'] as String;
  } else {
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Erro ao fazer login');
  }
}
