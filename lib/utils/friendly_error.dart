import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Converte um erro capturado (o objeto do `catch`) numa mensagem curta e
/// amigável para mostrar ao usuário.
///
/// Por que existe: antes o app espalhava
/// `e.toString().replaceFirst('Exception: ', '')` em vários lugares, o que tinha
/// dois problemas. (1) `replaceFirst` troca a primeira ocorrência em QUALQUER
/// posição — para exceções tipadas como `FormatException` ou `ClientException`,
/// o texto "Exception: " aparece no meio do nome do tipo, e a mensagem saía
/// embaralhada (ex.: "FormatInvalid number..."). (2) Erros de rede vinham como
/// texto técnico em inglês. Centralizar a tradução aqui resolve os dois.
String friendlyError(Object error) {
  // Falhas de rede: sem internet, host inacessível, conexão recusada. O pacote
  // http encapsula erros de socket em ClientException.
  if (error is SocketException || error is http.ClientException) {
    return 'Sem conexão com o servidor. Verifique sua internet e tente novamente.';
  }

  // Tempo de resposta esgotado (relevante quando as chamadas HTTP passarem a
  // usar .timeout()).
  if (error is TimeoutException) {
    return 'O servidor demorou para responder. Tente novamente.';
  }

  final texto = error.toString();

  // O caso comum: Exception('mensagem'), lançada por apiException e pelas
  // validações do app. O toString() vira "Exception: mensagem"; removemos o
  // prefixo apenas quando ele está ancorado no início — por isso não usamos
  // mais o replaceFirst sem âncora.
  if (texto.startsWith('Exception: ')) {
    return texto.substring('Exception: '.length);
  }

  // Qualquer outro tipo (FormatException, TypeError, etc.) não deve vazar o
  // nome técnico para a tela — mostramos uma mensagem genérica.
  return 'Ocorreu um erro inesperado. Tente novamente.';
}
