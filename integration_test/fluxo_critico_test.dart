import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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
import 'package:frota_facil_mobile/screens/pneu_lista_screen.dart';
import 'package:frota_facil_mobile/services/credential_storage.dart';
import 'package:frota_facil_mobile/theme/app_theme.dart';

// Fluxo crítico rodando com o app REAL num emulador/aparelho:
//
//   flutter test integration_test/fluxo_critico_test.dart -d <device>
//
// A diferença para os widget tests de test/screens/: aqui os PLUGINS são de
// verdade. O cenário do lembrar-me grava num SharedPreferences real e no
// Keystore real do Android (flutter_secure_storage) — exatamente a camada
// que os widget tests substituem por fakes em memória. A rede continua
// mockada por injeção de fetchFn/loginFn: E2E contra a API de verdade fica
// para quando houver ambiente de homologação.

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

/// Pneu parado em ESTOQUE — origem de uma movimentação horizontal.
const _pneuEstoque = Pneu(
  nroPneu: '7777',
  nroSerie: 'SR777777',
  marca: 'Pirelli',
  modelo: 'Modelo B',
  dimensao: '295/80R22.5',
  tipo: 'Radial',
  situacao: 'BOM',
  localEixo: '',
  codEsqEixo: '',
  localizacao: 'ESTOQUE',
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
  nroFrota: '',
  placa: '',
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

/// Mesma casca do app real (main.dart): AuthProvider, tema e locale pt-BR.
Widget _wrap(Widget screen) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider()..setToken('token-e2e'),
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

/// Espera [finder] aparecer bombeando frames reais, com timeout.
///
/// Substitui o pumpAndSettle quando há um spinner infinito na tela (ex.: a
/// HomeScreen carregando) — pumpAndSettle só retorna quando NENHUM frame
/// está agendado, o que nunca acontece com uma animação em loop.
Future<void> _aguardar(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final limite = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('widget não apareceu dentro de $timeout: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home exibe os cards e o FAB navega para o movimento',
      (tester) async {
    await tester.pumpWidget(
      _wrap(HomeScreen(fetchFn: (_) async => _localizacoes)),
    );
    await tester.pumpAndSettle();

    expect(find.text('ESTOQUE'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.text('Adicionar Movimento'));
    await tester.pumpAndSettle();

    expect(find.text('Frotas'), findsOneWidget);
    expect(find.text('Pneus'), findsOneWidget);
    expect(find.text('Abastecimento'), findsOneWidget);
  });

  testWidgets('busca por placa abre o detalhe e double-tap no pneu abre ações',
      (tester) async {
    await tester.pumpWidget(
      _wrap(FrotaBuscaScreen(fetchFn: (_, _) async => _veiculo)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'ABC1D23');
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();

    expect(find.byType(FrotaDetalheScreen), findsOneWidget);
    expect(find.text('ABC1D23 - Frota 001'), findsOneWidget);

    // Double-tap de verdade no pneu do diagrama: dois taps dentro da janela
    // de double-tap (40–300ms). Como o diagrama também tem onTap (abre a
    // sheet de detalhes), o gesto precisa ser reconhecido como duplo.
    final pneuNoDiagrama = find.text('1');
    await tester.tap(pneuNoDiagrama);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(pneuNoDiagrama);
    await tester.pumpAndSettle();

    expect(find.text('Pneu 1'), findsOneWidget);
    expect(find.text('Selecione uma opção'), findsOneWidget);
    for (final acao in ['ESTOQUE', 'CONSERTO', 'RECAPAGEM', 'SUCATA', 'VENDA']) {
      expect(find.text(acao), findsOneWidget);
    }
  });

  testWidgets(
      'movimentação horizontal: abre o formulário estoque→conserto e cancela',
      (tester) async {
    // Exercita a SHEET de movimentação no aparelho — a parte que os vídeos
    // do Test Lab não mostravam. Estoque→Conserto de propósito: é o destino
    // que não busca nada da API ao abrir (sucata/venda/recapagem buscam
    // motivos/fornecedores). Cancela em vez de confirmar: o POST real de
    // movimentação acontece dentro da sheet e mutaria dados de verdade —
    // toda a lógica de envio (payloads, combinações origem→destino) já é
    // coberta pelos widget tests das sheets.
    await tester.pumpWidget(
      _wrap(PneuListaScreen(fetchFn: (_) async => [_pneuEstoque])),
    );
    await tester.pumpAndSettle();

    // Card do pneu na lista → diálogo de ações.
    await tester.tap(find.text('Pneu #7777'));
    await tester.pumpAndSettle();
    expect(find.text('Selecione uma opção'), findsOneWidget);

    // ESTOQUE (posição atual) vem desabilitado; CONSERTO abre a sheet.
    await tester.tap(find.text('CONSERTO'));
    await tester.pumpAndSettle();

    // Formulário da movimentação horizontal na tela.
    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);

    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Sheet fechou sem enviar nada; a lista continua na tela.
    expect(find.text('Confirmar'), findsNothing);
    expect(find.byType(PneuListaScreen), findsOneWidget);
  });

  testWidgets('lembrar-me persiste credenciais nos storages reais do aparelho',
      (tester) async {
    // Este cenário usa os defaults de PRODUÇÃO do LoginScreen:
    // SharedPreferences real e SecureCredentialStorage real (Keystore).
    // Começa limpo e restaura o aparelho ao final.
    Future<void> limparStoragesReais() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await const SecureCredentialStorage().deletePassword();
    }

    await limparStoragesReais();
    addTearDown(limparStoragesReais);

    await tester.pumpWidget(
      _wrap(LoginScreen(loginFn: (_, _) async => 'token-e2e')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '07069953925');
    await tester.enterText(find.byType(TextField).last, 'senha-secreta');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    // Confirma que o tap marcou mesmo o checkbox — se falhar aqui, o
    // problema é de interação, não de storage.
    expect(
      tester.widget<Checkbox>(find.byType(Checkbox)).value,
      isTrue,
      reason: 'o tap não marcou o checkbox de lembrar-me',
    );

    await tester.tap(find.text('Entrar'));
    // O login navega para a HomeScreen com fetchFn DEFAULT, que dispara um
    // GET real com o token fake — falha inofensiva (é só leitura e o teste
    // não depende dela). Por causa do spinner dessa carga, esperamos a
    // navegação com _aguardar em vez de pumpAndSettle.
    await _aguardar(tester, find.byType(HomeScreen));

    // Diagnóstico por camada, antes de testar a UI: confere cada storage
    // diretamente, para uma falha apontar o culpado exato (na 1ª rodada do
    // Test Lab os campos não reapareceram e o erro não dizia por quê).
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool('remember_me'),
      isTrue,
      reason: 'remember_me não foi gravado no SharedPreferences',
    );
    expect(
      prefs.getString('saved_cpf'),
      '070.699.539-25',
      reason: 'saved_cpf não foi gravado no SharedPreferences',
    );
    final senhaLida = await const SecureCredentialStorage()
        .readPassword()
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => '<TIMEOUT: readPassword não respondeu em 20s>',
        );
    expect(
      senhaLida,
      'senha-secreta',
      reason: 'leitura do Keystore (flutter_secure_storage) não devolveu '
          'a senha gravada',
    );

    // "Reabre o app": primeiro DERRUBA a árvore atual de verdade. Sem isso,
    // o pumpWidget seguinte tem a mesma estrutura de tipos (Provider >
    // MaterialApp) e o Flutter REAPROVEITA o Navigator antigo — que ainda
    // está com a HomeScreen empilhada pelo login — em vez de montar um
    // LoginScreen novo ("home:" só vale para a rota inicial). Foi a causa
    // de falha em aparelhos do Firebase Test Lab enquanto passava por
    // coincidência de timing no emulador.
    await tester.pumpWidget(const SizedBox.shrink());

    // Agora sim: LoginScreen novo, com os storages reais — os campos devem
    // vir preenchidos do disco/Keystore. Espera longa: em aparelho real a
    // primeira leitura do Keystore pode demorar.
    await tester.pumpWidget(
      _wrap(LoginScreen(loginFn: (_, _) async => 'token-e2e')),
    );
    await _aguardar(
      tester,
      find.text('070.699.539-25'),
      timeout: const Duration(seconds: 30),
    );

    expect(find.text('070.699.539-25'), findsOneWidget);
    expect(find.text('senha-secreta'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });
}
