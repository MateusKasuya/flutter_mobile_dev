import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_error.dart';

/// Helper genérico para os endpoints de GET que devolvem uma lista de objetos.
///
/// Vários serviços repetiam exatamente o mesmo esqueleto (injetar/criar o
/// client, GET com header Bearer, timeout, decodificar a lista, mapear cada
/// item com `fromJson` e fechar o client). Este helper concentra esse padrão.
///
/// Conceitos novos de Dart usados aqui:
/// - `<T>` é um *generic* (tipo genérico): quem chama informa o tipo dos itens
///   da lista (ex.: `getJsonList<Fornecedor>(...)`), então o retorno já vem
///   tipado como `List<Fornecedor>` sem precisar de cast na chamada.
/// - [fromJson] é um *parâmetro de função*: recebemos a própria função de
///   desserialização do model. Na chamada dá pra passar o construtor nomeado
///   como *tear-off*, ex.: `Fornecedor.fromJson` (sem os parênteses), que é
///   uma referência à função em vez de uma chamada dela.
///
/// [client] permite injetar um cliente HTTP para testes.
Future<List<T>> getJsonList<T>(
  String path,
  String token,
  T Function(Map<String, dynamic>) fromJson, {
  required String mensagemErro,
  http.Client? client,
}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(apiBaseUrl, path);
    final response = await c.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw apiException(response, mensagemErro);
    }
  } finally {
    if (createdClient) {
      c.close();
    }
  }
}
