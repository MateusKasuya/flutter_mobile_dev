import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // Canário do carregamento de fontes feito em flutter_test_config.dart.
  //
  // Sem as fontes reais, o ambiente de teste renderiza com a fonte fake
  // "Ahem", em que TODO glifo é um quadrado de largura = fontSize — 'iiii'
  // a 100px mediria 400px. Na Montserrat real, 'i' é estreito (~25px em
  // 100px de corpo). Se este teste falhar, o flutter_test_config.dart parou
  // de carregar os .ttf (ex.: arquivo renomeado em assets/fonts/) e TODOS os
  // testes de layout voltam a medir texto com a fonte errada.
  testWidgets('Montserrat real está carregada no ambiente de testes',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Text(
            'iiii',
            style: GoogleFonts.montserrat(fontSize: 100),
          ),
        ),
      ),
    );

    final largura = tester.getSize(find.text('iiii')).width;
    expect(
      largura,
      lessThan(300),
      reason: 'texto medindo como a fonte fake Ahem (4 glifos × 100px); '
          'as fontes de assets/fonts/ não foram carregadas',
    );
  });
}
