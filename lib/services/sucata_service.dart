import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pneu_movimentacao.dart';

/// Busca todos os motivos de sucateamento cadastrados.
///
/// Lança uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<List<MotivoSucateamento>> fetchMotivosSucateamento(String token,
    {http.Client? client}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(apiBaseUrl, '/api-frota/sucata/getsucata');
    final response = await c.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => MotivoSucateamento.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail']?[0]?['msg'] ??
          'Erro ao buscar motivos de sucateamento');
    }
  } finally {
    if (createdClient) {
      c.close();
    }
  }
}
