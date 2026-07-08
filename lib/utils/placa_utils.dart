/// Regex para placa no formato antigo: ABC1234
final _oldFormat = RegExp(r'^[A-Z]{3}[0-9]{4}$');

/// Regex para placa no formato Mercosul: ABC1D23
final _mercosulFormat = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

/// Extrai uma placa válida do texto bruto retornado pelo OCR.
///
/// O OCR pode retornar textos extras como "BRASIL", nome da cidade
/// e sigla do estado. Este helper quebra o texto em linhas, limpa
/// cada uma e retorna a primeira que corresponde a um formato de
/// placa brasileira (antiga ou Mercosul).
///
/// Dividimos SOMENTE por quebra de linha (`\n`), e não por qualquer
/// espaço em branco. Motivo: o OCR às vezes insere um espaço no meio
/// da placa (ex.: "ABC 1D23"). Se dividíssemos por espaço, esse token
/// viraria dois pedaços e nenhum casaria a regex ancorada. Ao dividir
/// só por `\n` e depois remover tudo que não for A-Z0-9 de cada linha,
/// o espaço interno some e a placa volta a casar. A separação por
/// linha continua evitando fundir a placa com cidade/estado.
///
/// Retorna `null` se nenhuma linha válida for encontrada.
String? extractPlaca(String ocrText) {
  final linhas = ocrText
      .toUpperCase()
      .split('\n')
      .map((t) => t.replaceAll(RegExp(r'[^A-Z0-9]'), ''))
      .where((t) => t.isNotEmpty);

  for (final linha in linhas) {
    if (_mercosulFormat.hasMatch(linha) || _oldFormat.hasMatch(linha)) {
      return linha;
    }
  }
  return null;
}
