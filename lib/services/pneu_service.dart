import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pneu.dart';
import 'api_error.dart';
import 'auth_http_client.dart';
import 'http_helpers.dart';

/// Busca todos os pneus.
///
/// Lança uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<List<Pneu>> fetchPneus(String token, {http.Client? client}) {
  return getJsonList<Pneu>(
    '/api-frota/pneu/getpneu',
    token,
    Pneu.fromJson,
    mensagemErro: 'Erro ao buscar pneus',
    client: client,
  );
}

/// Formata um [DateTime] como `AAAA-MM-DDTHH:MM:SS`, o formato date-time
/// que a API espera. Não usamos [DateTime.toIso8601String] porque ele
/// acrescenta milissegundos (`.000`), que não constam no contrato.
String _formatDataEntrada(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${data.year.toString().padLeft(4, '0')}-'
      '${dois(data.month)}-${dois(data.day)}T'
      '${dois(data.hour)}:${dois(data.minute)}:${dois(data.second)}';
}

/// Executa uma movimentação de pneu (POST /pneu/movimentarpneu).
///
/// O endpoint é único para todos os tipos de movimentação — o backend decide
/// o que fazer pelos campos preenchidos:
/// - montagem no veículo: [localEixo], [codEsqEixo], [placa] e [nroFrota];
/// - movimentação para uma localização (estoque, conserto, recapagem,
///   sucata, venda): [localizacao] com o nome dela em maiúsculas;
/// - sucateamento: [codMotivoSucat] com o código do motivo.
///
/// Retorna a mensagem de sucesso da API. Em caso de falha lança uma
/// [Exception] com a mensagem retornada (ou uma mensagem padrão).
/// [client] permite injetar um cliente HTTP para testes.
Future<String> movimentarPneu(
  String token, {
  required int nroPneu,
  required DateTime dataEntrada,
  required int codFil,
  double valor = 0,
  String? localizacao,
  String? kmEntrada,
  String? localEixo,
  String? codEsqEixo,
  String? placa,
  int? nroFrota,
  int? codMotivoSucat,
  String? cgcCpfForne,
  String? motivoSaida,
  http.Client? client,
}) async {
  // Sem client injetado, usa o [apiClient] compartilhado (singleton de longa
  // vida que trata o 401 global); ele não é fechado aqui.
  final c = client ?? apiClient;
  final url = Uri.http(apiBaseUrl, '/api-frota/pneu/movimentarpneu');
  final response = await c.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    // As chaves seguem o contrato atual da API (camelCase minúsculo),
    // documentado em /api-frota/swagger/v1/swagger.json. Campos não usados
    // pelo tipo de movimentação vão como null, igual ao exemplo do swagger.
    body: jsonEncode({
      'nropneu': nroPneu,
      'dataentrada': _formatDataEntrada(dataEntrada),
      'valor': valor,
      'localizacao': localizacao,
      'codfil': codFil,
      'kmentrada': kmEntrada,
      'localeixo': localEixo,
      'codesqeixo': codEsqEixo,
      'placa': placa,
      'nrofrota': nroFrota,
      'codmotivosucat': codMotivoSucat,
      'cgccpfforne': cgcCpfForne,
      'motivosaida': motivoSaida,
    }),
  ).timeout(apiTimeout);

  // Tanto o 200 quanto o 422 respondem {"sucesso": bool, "mensagem": str},
  // um formato diferente do {"detail": ...} tratado por apiException — por
  // isso o parse é feito aqui, e apiException fica de fallback para
  // respostas fora do contrato (ex.: 401 do gateway, com corpo vazio).
  Map<String, dynamic>? corpo;
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) corpo = decoded;
  } catch (_) {
    // Corpo vazio ou não-JSON: segue para o fallback abaixo.
  }

  final mensagem = corpo?['mensagem'];
  final mensagemStr = mensagem is String ? mensagem : '';

  if (response.statusCode == 200 && corpo?['sucesso'] == true) {
    return mensagemStr;
  }
  if (mensagemStr.isNotEmpty) {
    throw Exception(mensagemStr);
  }
  throw apiException(response, 'Erro ao movimentar pneu');
}
