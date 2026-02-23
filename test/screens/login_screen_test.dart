import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/screens/login_screen.dart';
import 'package:frota_facil_mobile/screens/home_screen.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Monta o LoginScreen dentro de um MaterialApp com a [loginFn] fornecida.
  Widget buildApp(Future<String> Function(String, String) loginFn) {
    return MaterialApp(
      home: LoginScreen(loginFn: loginFn),
    );
  }

  // ---------------------------------------------------------------------------
  // Testes
  // ---------------------------------------------------------------------------

  testWidgets('exibe campos CPF e Senha e botão Entrar', (tester) async {
    await tester.pumpWidget(buildApp((_, __) async => 'token'));

    expect(find.text('CPF'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('login com sucesso navega para HomeScreen com o token',
      (tester) async {
    const fakeToken = 'meu-token-de-teste';

    // loginFn falsa: sempre retorna o token sem chamar a API
    await tester.pumpWidget(
      buildApp((cpf, senha) async => fakeToken),
    );

    // Preenche CPF
    await tester.enterText(find.byType(TextField).first, '07069953925');
    // Preenche senha
    await tester.enterText(find.byType(TextField).last, '1');
    // Toca no botão
    await tester.tap(find.text('Entrar'));
    // Aguarda animações e futures
    await tester.pumpAndSettle();

    // Deve estar na HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Login realizado com sucesso!'), findsOneWidget);
    expect(find.text(fakeToken), findsOneWidget);
  });

  testWidgets('login com falha exibe mensagem de erro', (tester) async {
    const mensagemErro = 'Credenciais inválidas';

    // loginFn falsa: sempre lança exceção
    await tester.pumpWidget(
      buildApp((_, __) async => throw Exception(mensagemErro)),
    );

    await tester.enterText(find.byType(TextField).first, '00000000000');
    await tester.enterText(find.byType(TextField).last, 'errada');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Deve continuar na LoginScreen com a mensagem de erro
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text(mensagemErro), findsOneWidget);
  });
}
