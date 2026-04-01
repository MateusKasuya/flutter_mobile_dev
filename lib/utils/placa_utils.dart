/// Regex para placa no formato antigo: ABC1234
final _oldFormat = RegExp(r'^[A-Z]{3}[0-9]{4}$');

/// Regex para placa no formato Mercosul: ABC1D23
final _mercosulFormat = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

/// Extrai uma placa válida do texto bruto retornado pelo OCR.
///
/// O OCR pode retornar textos extras como "BRASIL", nome da cidade
/// e sigla do estado. Este helper quebra o texto em tokens, limpa
/// cada um e retorna o primeiro que corresponde a um formato de
/// placa brasileira (antiga ou Mercosul).
///
/// Retorna `null` se nenhum token válido for encontrado.
String? extractPlaca(String ocrText) {
  final tokens = ocrText
      .toUpperCase()
      .split(RegExp(r'[\s\n]+'))
      .map((t) => t.replaceAll(RegExp(r'[^A-Z0-9]'), ''))
      .where((t) => t.isNotEmpty);

  for (final token in tokens) {
    if (_mercosulFormat.hasMatch(token) || _oldFormat.hasMatch(token)) {
      return token;
    }
  }
  return null;
}
