import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frota_facil_mobile/models/localizacao.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/screens/frota_busca_screen.dart';
import 'package:frota_facil_mobile/screens/frota_detalhe_screen.dart';
import 'package:frota_facil_mobile/screens/home_screen.dart';
import 'package:frota_facil_mobile/screens/login_screen.dart';
import 'package:frota_facil_mobile/screens/movimento_screen.dart';
import 'package:frota_facil_mobile/screens/pneu_lista_screen.dart';
import 'package:frota_facil_mobile/theme/app_theme.dart';

import '../helpers/fake_credential_storage.dart';
import '../helpers/test_viewport.dart';

// Matriz responsiva: renderiza cada tela principal em cada perfil de
// dispositivo (test/helpers/test_viewport.dart) e falha se o layout quebrar.
//
// O truque é que não precisamos assertar quase nada: quando um Row/Column
// estoura o espaço disponível (as listras amarelas e pretas de
// "RenderFlex overflowed"), o Flutter reporta um erro de framework — e em
// modo de teste TODO erro de framework falha o teste automaticamente. Ou
// seja, só de montar a tela num viewport já testamos "cabe sem estourar".
// Como flutter_test_config.dart carrega a Montserrat real, a medida do texto
// é a mesma do app em produção — um vermelho aqui é um problema de verdade.
//
// A SplashScreen fica de fora: é um logo com uma linha centralizada (risco
// de layout ~zero) e o timer de 2s + storage nativo de sessão não valem o
// mock só para isso.

const _pneu = Pneu(
  nroPneu: '1',
  nroSerie: 'SR123456',
  marca: 'Pirelli',
  modelo: 'Modelo A',
  dimensao: '295/80R22.5',
  tipo: 'Radial',
  situacao: 'Em uso',
  localEixo: '1E',
  codEsqEixo: '1',
  localizacao: '1',
  nroDot: '4523',
  indRecapagem: 'N',
  vidaPneu: '80',
  kmRodado: '50000',
  kmAcumulador: '40000',
  kmAtuVei: '150000',
  kmRodado0: '10000',
  kmRodado1: '10000',
  kmRodado2: '10000',
  kmRodado3: '10000',
  kmRodado4: '10000',
  kmRodado5: '0',
  dataCompra: '2023-01-15',
  dataAtzKm: '2024-06-01',
  codFil: '01',
  nroFrota: '001',
  placa: 'ABC1D23',
);

const _veiculo = Veiculo(
  placa: 'ABC1D23',
  nroFrota: '001',
  marca: 'Marca Y',
  modelo: 'Modelo X',
  ano: '2020',
  anoModelo: '2021',
  cor: 'Branco',
  tipo: 'Caminhão',
  codEsqEixo: '1',
  pneus: [_pneu],
);

const _localizacoes = [
  Localizacao(quantidade: 5, nome: 'ESTOQUE'),
  Localizacao(quantidade: 10, nome: 'FROTA'),
  Localizacao(quantidade: 3, nome: 'SUCATA'),
  Localizacao(quantidade: 7, nome: 'VENDA'),
];

/// Embrulha a tela na mesma casca do app real (main.dart): AuthProvider,
/// tema e localização pt-BR — para a matriz medir o que produção renderiza.
Widget _wrap(Widget screen) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider()..setToken('test-token'),
    child: MaterialApp(
      theme: AppTheme.theme,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      home: screen,
    ),
  );
}

void main() {
  setUp(() {
    // O LoginScreen lê SharedPreferences (lembrar-me) no initState.
    SharedPreferences.setMockInitialValues({});
  });

  // Cada entrada monta a tela com as dependências mockadas (nenhum teste
  // aqui toca rede ou canal nativo). Builders em vez de instâncias prontas
  // porque cada perfil precisa de uma árvore de widgets nova.
  final telas = <String, Widget Function()>{
    'LoginScreen': () => LoginScreen(
          loginFn: (_, _) async => 'token',
          credentialStorage: FakeCredentialStorage(),
        ),
    'HomeScreen': () => HomeScreen(fetchFn: (_) async => _localizacoes),
    'MovimentoScreen': () => const MovimentoScreen(),
    'FrotaBuscaScreen': () =>
        FrotaBuscaScreen(fetchFn: (_, _) async => _veiculo),
    'FrotaDetalheScreen': () => const FrotaDetalheScreen(veiculo: _veiculo),
    'PneuListaScreen': () => PneuListaScreen(fetchFn: (_) async => [_pneu]),
  };

  for (final tela in telas.entries) {
    group(tela.key, () {
      for (final perfil in kPerfisDeDispositivo) {
        testWidgets('renderiza sem overflow — ${perfil.nome}', (tester) async {
          useViewport(tester, perfil);
          await tester.pumpWidget(_wrap(tela.value()));
          // pumpAndSettle avança frames até a UI estabilizar (espera os
          // fetchFn mockados resolverem e o loading sumir).
          await tester.pumpAndSettle();

          // Sanidade: a tela de fato montou (o trabalho pesado do teste é o
          // detector de overflow implícito descrito no topo do arquivo).
          expect(find.byType(Scaffold), findsWidgets);
        });
      }
    });
  }
}
