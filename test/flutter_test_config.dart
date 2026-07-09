import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Configuração global dos testes.
///
/// O `flutter_test` procura por um arquivo chamado `flutter_test_config.dart`
/// na pasta de testes e, se existir, chama `testExecutable` passando o `main`
/// de cada arquivo de teste. Ou seja: tudo que fizermos aqui roda ANTES de
/// todo teste do projeto — é o lugar certo para setup global.
///
/// Usamos isso para carregar a fonte Montserrat REAL nos testes. Por padrão o
/// ambiente de teste renderiza todo texto com uma fonte fake ("Ahem"), em que
/// cada glifo é um quadrado — mais LARGO que a Montserrat. Isso gerava falsos
/// positivos de overflow: layouts que cabem no aparelho real "estouravam" só
/// no teste (ver os handlers de supressão nos testes das bottom sheets).
/// Com a fonte real carregada, a medida do texto no teste é a mesma do app,
/// e um overflow reportado passa a ser um problema de verdade.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Necessário antes de usar rootBundle (carregar assets) fora de um teste.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Espelha o main.dart: o app empacota os .ttf em assets/fonts/ e nunca
  // baixa fontes da internet.
  GoogleFonts.config.allowRuntimeFetching = false;

  // O google_fonts registra cada peso como uma FAMÍLIA própria, com o nome
  // no formato '<Família>_<variante>' (ex.: GoogleFonts.montserrat(
  // fontWeight: FontWeight.w600) usa a família 'Montserrat_600'). Para o
  // texto dos testes resolver para a fonte real, carregamos cada .ttf sob o
  // nome interno correspondente.
  const fontesPorFamilia = {
    'Montserrat_regular': 'Montserrat-Regular.ttf',
    'Montserrat_500': 'Montserrat-Medium.ttf',
    'Montserrat_600': 'Montserrat-SemiBold.ttf',
    'Montserrat_700': 'Montserrat-Bold.ttf',
  };
  for (final entry in fontesPorFamilia.entries) {
    // FontLoader registra uma fonte no motor de renderização em tempo de
    // execução — o mesmo mecanismo que o google_fonts usa no app real.
    final loader = FontLoader(entry.key)
      ..addFont(rootBundle.load('assets/fonts/${entry.value}'));
    await loader.load();
  }

  // Os TextStyles do google_fonts declaram 'Montserrat' como fallback;
  // registramos a família genérica com todos os pesos por completude.
  final montserrat = FontLoader('Montserrat');
  for (final arquivo in fontesPorFamilia.values) {
    montserrat.addFont(rootBundle.load('assets/fonts/$arquivo'));
  }
  await montserrat.load();

  await testMain();
}
