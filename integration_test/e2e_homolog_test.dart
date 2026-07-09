import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frota_facil_mobile/main.dart' as app;
import 'package:frota_facil_mobile/screens/frota_detalhe_screen.dart';
import 'package:frota_facil_mobile/screens/home_screen.dart';
import 'package:frota_facil_mobile/screens/login_screen.dart';
import 'package:frota_facil_mobile/services/credential_storage.dart';
import 'package:frota_facil_mobile/services/token_storage.dart';

// E2E contra o ambiente REAL (homologação): diferente dos outros arquivos de
// integration_test, aqui NADA é mockado — o teste sobe o app inteiro pelo
// main() de produção (splash inclusa) e o login/fetches batem na API de
// verdade. Somente LEITURA: nenhum POST de movimentação é disparado.
//
// As credenciais entram por dart-define, para nunca irem ao repositório:
//
//   flutter test integration_test/e2e_homolog_test.dart -d <device> \
//     --dart-define=E2E_CPF=00000000000 \
//     --dart-define=E2E_SENHA=minhasenha \
//     --dart-define=E2E_PLACA=ABC1234        # opcional: busca de veículo
//
// Sem E2E_CPF/E2E_SENHA o teste é PULADO (skip) — assim o arquivo convive no
// repo e `flutter test integration_test` continua verde sem credenciais.

const _cpf = String.fromEnvironment('E2E_CPF');
const _senha = String.fromEnvironment('E2E_SENHA');
const _placa = String.fromEnvironment('E2E_PLACA');

/// Espera [finder] aparecer bombeando frames reais, com timeout — necessário
/// no lugar de pumpAndSettle porque as telas com fetch real exibem um spinner
/// em loop (pumpAndSettle só retorna quando nenhum frame está agendado).
Future<void> _aguardar(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
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

  testWidgets('login e navegação reais contra a homologação', (tester) async {
    // Sessão ou lembrar-me deixados por execuções anteriores fariam a splash
    // pular o login; começa e termina com o aparelho limpo.
    Future<void> limparEstadoPersistido() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await const SecureCredentialStorage().deletePassword();
      await const SecureTokenStorage().deleteToken();
    }

    await limparEstadoPersistido();
    addTearDown(limparEstadoPersistido);

    // O app real, do zero — o mesmo main() que roda no aparelho do usuário.
    app.main();

    // Splash segura 2s antes de decidir a rota; sem token salvo, cai no login.
    await _aguardar(tester, find.byType(LoginScreen), timeout: const Duration(seconds: 15));

    await tester.enterText(find.byType(TextField).first, _cpf);
    await tester.enterText(find.byType(TextField).last, _senha);
    await tester.tap(find.text('Entrar'));

    // Login real → Home real: os cards só aparecem quando o GET de
    // localizações respondeu com o token recém-emitido.
    await _aguardar(tester, find.byType(HomeScreen));
    await _aguardar(tester, find.byType(GridView));
    expect(find.text('Tentar novamente'), findsNothing);

    // Busca de veículo real, só quando uma placa de homologação for passada.
    if (_placa.isEmpty) return;

    await tester.tap(find.text('Adicionar Movimento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Frotas'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), _placa);
    await tester.tap(find.text('Buscar'));
    await _aguardar(tester, find.byType(FrotaDetalheScreen));
    expect(find.textContaining(_placa.toUpperCase()), findsWidgets);
  }, skip: _cpf.isEmpty || _senha.isEmpty);
}
