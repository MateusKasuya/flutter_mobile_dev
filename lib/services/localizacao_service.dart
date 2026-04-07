import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/localizacao.dart';

/// Busca as localizações de pneus com suas quantidades.
///
/// Lança uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<List<Localizacao>> fetchLocalizacoes(String token,
    {http.Client? client}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(apiBaseUrl, '/api-frota/pneu/qlocalizacaopneus');
    final response = await c.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data
          .map((e) => Localizacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Erro ao buscar localizações');
    }
  } finally {
    if (createdClient) {
      c.close();
    }
  }
}
