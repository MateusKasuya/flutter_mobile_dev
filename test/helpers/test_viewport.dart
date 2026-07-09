import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Perfil de dispositivo simulado em teste de widget.
///
/// Widget test não roda em aparelho nenhum: o Flutter renderiza numa "tela"
/// virtual cujas dimensões o teste controla. Um perfil agrupa os três knobs
/// que variam entre aparelhos reais e afetam layout:
///
/// - [tamanhoLogico]: tamanho da tela em pixels LÓGICOS (dp), a unidade em
///   que os widgets medem (um `width: 100` são 100dp);
/// - [devicePixelRatio]: quantos pixels físicos formam 1 pixel lógico
///   (3.0 em celulares de alta densidade, 2.0 em aparelhos de entrada);
/// - [escalaDeTexto]: multiplicador de fonte que o usuário configura na
///   acessibilidade do aparelho (1.3 = fonte "grande" no Android).
class DeviceProfile {
  final String nome;
  final Size tamanhoLogico;
  final double devicePixelRatio;
  final double escalaDeTexto;

  const DeviceProfile({
    required this.nome,
    required this.tamanhoLogico,
    this.devicePixelRatio = 3.0,
    this.escalaDeTexto = 1.0,
  });
}

/// O celular "de referência" dos testes (390x844 lógicos, como um iPhone).
const kCelularPadrao = DeviceProfile(
  nome: 'celular padrão',
  tamanhoLogico: Size(390, 844),
);

/// Matriz de perfis exercitada pelos testes responsivos
/// (test/screens/responsive_matrix_test.dart).
///
/// A escolha cobre os extremos reais de um parque de aparelhos: celular de
/// entrada pequeno (320dp de largura é o piso prático do Android), o
/// intermediário típico, o topo de linha grande, fonte de acessibilidade
/// ampliada nos dois extremos de tamanho, e tablet nas duas orientações
/// (largura >= 600dp cruza o kTabletBreakpoint e ativa o layout de tablet).
const kPerfisDeDispositivo = [
  DeviceProfile(
    nome: 'celular pequeno',
    tamanhoLogico: Size(320, 568),
    devicePixelRatio: 2.0,
  ),
  kCelularPadrao,
  DeviceProfile(
    nome: 'celular grande',
    tamanhoLogico: Size(428, 926),
  ),
  DeviceProfile(
    nome: 'celular pequeno, fonte grande',
    tamanhoLogico: Size(320, 568),
    devicePixelRatio: 2.0,
    escalaDeTexto: 1.3,
  ),
  DeviceProfile(
    nome: 'celular padrão, fonte grande',
    tamanhoLogico: Size(390, 844),
    escalaDeTexto: 1.3,
  ),
  // Atenção: como o app não trava a orientação e o breakpoint de tablet é
  // por LARGURA, um celular deitado (844 >= 600) cai no layout de tablet —
  // mas com só 390dp de altura. É um cenário que o usuário consegue criar
  // girando o aparelho, por isso entra na matriz.
  DeviceProfile(
    nome: 'celular paisagem',
    tamanhoLogico: Size(844, 390),
  ),
  DeviceProfile(
    nome: 'tablet retrato',
    tamanhoLogico: Size(800, 1280),
    devicePixelRatio: 2.0,
  ),
  DeviceProfile(
    nome: 'tablet paisagem',
    tamanhoLogico: Size(1280, 800),
    devicePixelRatio: 2.0,
  ),
  DeviceProfile(
    nome: 'tablet retrato, fonte grande',
    tamanhoLogico: Size(800, 1280),
    devicePixelRatio: 2.0,
    escalaDeTexto: 1.3,
  ),
];

/// Configura o viewport do teste segundo o [perfil], desfazendo tudo ao fim
/// do teste para nada vazar para os seguintes.
void useViewport(WidgetTester tester, DeviceProfile perfil) {
  // physicalSize é em pixels FÍSICOS: lógico × devicePixelRatio.
  tester.view.physicalSize = perfil.tamanhoLogico * perfil.devicePixelRatio;
  tester.view.devicePixelRatio = perfil.devicePixelRatio;
  // A escala de texto vive no platformDispatcher (é configuração do SISTEMA,
  // não da tela); o MediaQuery a entrega aos Text como um TextScaler.
  tester.platformDispatcher.textScaleFactorTestValue = perfil.escalaDeTexto;
  // addTearDown registra uma limpeza executada ao fim do teste.
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Fixa o viewport do teste no tamanho de um celular (390x844 lógicos,
/// como um iPhone).
///
/// O viewport padrão do `flutter test` é 800x600 lógicos — 800 de largura
/// passa do breakpoint de tablet (600) usado nas telas, então sem isso os
/// testes exercitariam o layout de TABLET sem querer. Chame este helper no
/// início de todo teste que asserta comportamento do layout de celular.
void usePhoneViewport(WidgetTester tester) {
  useViewport(tester, kCelularPadrao);
}
