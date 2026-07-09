import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/veiculo.dart';
import 'api_error.dart';
import 'auth_http_client.dart';

/// Busca um veiculo com seus pneus pela placa.
///
/// Lanca uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<Veiculo> fetchVeiculo(String token, String placa,
    {http.Client? client}) async {
  // Sem client injetado, usa o [apiClient] compartilhado (singleton de longa
  // vida que trata o 401 global); ele nao e fechado aqui.
  final c = client ?? apiClient;
  final url = Uri.http(
    apiBaseUrl,
    '/api-frota/veiculo/getveiculo-com-pneus',
    {'placa': placa},
  );
  final response = await c.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  ).timeout(apiTimeout);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Veiculo.fromJson(data);
  } else if (response.statusCode == 404) {
    throw Exception('Veiculo nao encontrado');
  } else {
    throw apiException(response, 'Erro ao buscar veiculo');
  }
}
