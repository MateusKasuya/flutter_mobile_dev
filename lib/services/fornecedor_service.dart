import 'package:http/http.dart' as http;

import '../models/fornecedor.dart';
import 'http_helpers.dart';

/// Busca todos os fornecedores cadastrados.
///
/// Lança uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<List<Fornecedor>> fetchFornecedores(String token,
    {http.Client? client}) {
  return getJsonList<Fornecedor>(
    '/api-frota/fornecedor/getfornecedor',
    token,
    Fornecedor.fromJson,
    mensagemErro: 'Erro ao buscar fornecedores',
    client: client,
  );
}
