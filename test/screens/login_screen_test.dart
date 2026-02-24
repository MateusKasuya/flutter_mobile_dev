import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frota_facil_mobile/screens/login_screen.dart';
import 'package:frota_facil_mobile/screens/home_screen.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Monta o LoginScreen dentro de um MaterialApp com a [loginFn] fornecida.
  Widget buildApp(
    Future<String> Function(String, String) loginFn, {
    SharedPreferences? prefs,
  }) {
    return MaterialApp(
      home: LoginScreen(loginFn: loginFn, prefs: prefs),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // ---------------------------------------------------------------------------
  // Testes originais
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

    await tester.pumpWidget(
      buildApp((cpf, senha) async => fakeToken),
    );

    await tester.enterText(find.byType(TextField).first, '07069953925');
    await tester.enterText(find.byType(TextField).last, 'senha123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Login realizado com sucesso!'), findsOneWidget);
    expect(find.text(fakeToken), findsOneWidget);
  });

  testWidgets('login com falha exibe mensagem de erro', (tester) async {
    const mensagemErro = 'Credenciais inválidas';

    await tester.pumpWidget(
      buildApp((_, __) async => throw Exception(mensagemErro)),
    );

    // CPF válido para passar a validação do formulário
    await tester.enterText(find.byType(TextField).first, '07069953925');
    await tester.enterText(find.byType(TextField).last, 'errada');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text(mensagemErro), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Validação de campos vazios
  // ---------------------------------------------------------------------------

  testWidgets('submeter com campos vazios exibe mensagens de validação',
      (tester) async {
    await tester.pumpWidget(buildApp((_, __) async => 'token'));

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe o CPF'), findsOneWidget);
    expect(find.text('Informe a senha'), findsOneWidget);
  });

  testWidgets('submeter CPF inválido exibe mensagem de CPF inválido',
      (tester) async {
    await tester.pumpWidget(buildApp((_, __) async => 'token'));

    await tester.enterText(find.byType(TextField).first, '12345678900');
    await tester.enterText(find.byType(TextField).last, 'senha123');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('CPF inválido'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Toggle de visibilidade da senha
  // ---------------------------------------------------------------------------

  testWidgets('ícone de visibilidade está presente no campo de senha',
      (tester) async {
    await tester.pumpWidget(buildApp((_, __) async => 'token'));

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('toque no ícone alterna visibilidade da senha', (tester) async {
    await tester.pumpWidget(buildApp((_, __) async => 'token'));

    // Toca no ícone de visibilidade
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    // Ícone deve mudar para visibility_off
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Checkbox lembrar-me
  // ---------------------------------------------------------------------------

  testWidgets('checkbox lembrar usuário e senha está presente', (tester) async {
    await tester.pumpWidget(buildApp((_, __) async => 'token'));

    expect(find.text('Lembrar usuário e senha'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);
  });

  testWidgets('campos são preenchidos automaticamente quando lembrar-me ativo',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'remember_me': true,
      'saved_cpf': '070.699.539-25',
      'saved_password': 'minhasenha',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(buildApp((_, __) async => 'token', prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.text('070.699.539-25'), findsOneWidget);
  });
}
