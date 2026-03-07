import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/veiculo.dart';

const String _baseUrl = 'fretefacilweb.ccmcloud.com.br:8624';

/// Busca um veiculo com seus pneus pela placa.
///
/// Lanca uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<Veiculo> fetchVeiculo(String token, String placa,
    {http.Client? client}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(
      _baseUrl,
      '/api-frota/veiculo/getveiculo-com-pneus',
      {'placa': placa},
    );
    final response = await c.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Veiculo.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Veiculo nao encontrado');
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail']?[0]?['msg'] ?? 'Erro ao buscar veiculo');
    }
  } finally {
    if (createdClient) {
      c.close();
    }
  }
}
