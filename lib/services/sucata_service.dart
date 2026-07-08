import 'package:http/http.dart' as http;

import '../models/pneu_movimentacao.dart';
import 'http_helpers.dart';

/// Busca todos os motivos de sucateamento cadastrados.
///
/// Lança uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<List<MotivoSucateamento>> fetchMotivosSucateamento(String token,
    {http.Client? client}) {
  return getJsonList<MotivoSucateamento>(
    '/api-frota/sucata/getsucata',
    token,
    MotivoSucateamento.fromJson,
    mensagemErro: 'Erro ao buscar motivos de sucateamento',
    client: client,
  );
}
