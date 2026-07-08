import 'package:http/http.dart' as http;

import '../models/localizacao.dart';
import 'http_helpers.dart';

/// Busca as localizações de pneus com suas quantidades.
///
/// Lança uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<List<Localizacao>> fetchLocalizacoes(String token,
    {http.Client? client}) {
  return getJsonList<Localizacao>(
    '/api-frota/pneu/qlocalizacaopneus',
    token,
    Localizacao.fromJson,
    mensagemErro: 'Erro ao buscar localizações',
    client: client,
  );
}
