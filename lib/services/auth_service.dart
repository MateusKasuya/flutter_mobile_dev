import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Faz login na API e retorna o token de autenticação.
///
/// Lança uma [Exception] com a mensagem de erro se o login falhar.
Future<String> login(String cpfusuario, String senhausuario) async {
  final url = Uri.http(apiBaseUrl, '/sftlogin/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'cpfusuario': cpfusuario, 'senhausuario': senhausuario}),
  );

  //print(response.statusCode);

  if (response.statusCode == 202) {
    final data = jsonDecode(response.body);
    return data['access_token'] as String;
  }
  // else if (response.statusCode == 422) {
  //   final data = jsonDecode(response.body);
  //   throw Exception(data['detail'][0]['msg']);
  // }
   else {
    final data = jsonDecode(response.body);
    throw Exception(data['detail'] ?? 'Erro ao fazer login');
  }
}
