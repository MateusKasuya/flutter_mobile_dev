import 'dart:convert';
import 'package:http/http.dart' as http;

/// Monta a [Exception] para uma resposta de erro da API.
///
/// Tenta extrair a mensagem do corpo JSON, que pode vir em dois formatos:
/// `{"detail": "mensagem"}` ou `{"detail": [{"msg": "mensagem"}]}` (erros
/// de validação). Nem todo erro tem corpo JSON — o 401 do gateway, por
/// exemplo, vem com corpo vazio — então qualquer falha no parse cai na
/// [mensagemPadrao], com o código HTTP anexado para facilitar o diagnóstico.
Exception apiException(http.Response response, String mensagemPadrao) {
  try {
    final data = jsonDecode(response.body);
    final detail = data is Map ? data['detail'] : null;
    if (detail is String && detail.isNotEmpty) {
      return Exception(detail);
    }
    if (detail is List && detail.isNotEmpty) {
      final msg = detail.first['msg'];
      if (msg is String && msg.isNotEmpty) {
        return Exception(msg);
      }
    }
  } catch (_) {
    // Corpo vazio, não-JSON ou em formato inesperado: usa a mensagem padrão.
  }
  return Exception('$mensagemPadrao (HTTP ${response.statusCode})');
}
