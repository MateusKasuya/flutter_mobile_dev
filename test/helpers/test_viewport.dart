import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixa o viewport do teste no tamanho de um celular (390x844 lógicos,
/// como um iPhone).
///
/// O viewport padrão do `flutter test` é 800x600 lógicos — 800 de largura
/// passa do breakpoint de tablet (600) usado nas telas, então sem isso os
/// testes exercitariam o layout de TABLET sem querer. Chame este helper no
/// início de todo teste que asserta comportamento do layout de celular.
///
/// `physicalSize` é em pixels físicos; o tamanho lógico é
/// physicalSize / devicePixelRatio (aqui 1170x2532 / 3 = 390x844).
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  // addTearDown registra uma limpeza executada ao fim do teste; reset()
  // devolve o viewport padrão para não vazar para os testes seguintes.
  addTearDown(tester.view.reset);
}
