import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pneu.dart';
import 'api_error.dart';

/// Busca todos os pneus.
///
/// Lança uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<List<Pneu>> fetchPneus(String token, {http.Client? client}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(apiBaseUrl, '/api-frota/pneu/getpneu');
    final response = await c.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Pneu.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw apiException(response, 'Erro ao buscar pneus');
    }
  } finally {
    if (createdClient) {
      c.close();
    }
  }
}
