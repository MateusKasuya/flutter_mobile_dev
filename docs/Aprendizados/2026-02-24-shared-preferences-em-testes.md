---
tags: [aprendizado]
date: 2026-02-24
topic: Flutter / Testes
---

# SharedPreferences em testes de widget

[[Home]]

---

## O que aprendi

`SharedPreferences.getInstance()` usa um canal de plataforma (platform channel) que não está disponível no ambiente de testes Flutter. Chamar esse método em `initState` sem preparação adequada causa falha silenciosa ou exceção nos testes.

A solução é inicializar valores mockados antes de cada teste com `SharedPreferences.setMockInitialValues({})`.

## Por que importa

Qualquer widget que use `SharedPreferences` no `initState` vai quebrar os testes existentes se esse setup não for feito. É um erro fácil de cometer ao adicionar persistência a um widget já testado.

## Exemplo prático

```dart
// No arquivo de testes, adicionar setUp:
setUp(() async {
  SharedPreferences.setMockInitialValues({});
});

// Para testar com dados pré-carregados:
testWidgets('campos preenchidos quando remember_me ativo', (tester) async {
  SharedPreferences.setMockInitialValues({
    'remember_me': true,
    'saved_cpf': '070.699.539-25',
    'saved_password': 'minhasenha',
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    MaterialApp(home: LoginScreen(loginFn: fakeLogin, prefs: prefs)),
  );
  await tester.pumpAndSettle();

  expect(find.text('070.699.539-25'), findsOneWidget);
});
```

## Padrão de injeção para testabilidade

Para que o `SharedPreferences` seja mockável nos testes, o widget deve aceitá-lo como parâmetro opcional:

```dart
class LoginScreen extends StatefulWidget {
  final SharedPreferences? prefs; // null = usa getInstance() em produção

  const LoginScreen({super.key, this.prefs});
}

// No widget:
Future<void> _loadSavedCredentials() async {
  final prefs = widget.prefs ?? await SharedPreferences.getInstance();
  // ...
}
```

Esse é o mesmo padrão usado para `loginFn` — injetar dependências externas via parâmetro para facilitar testes.

## Referências

- [[Aprendizados/2026-02-23-injecao-de-dependencia]]

## Links relacionados

- [[Bugs/2026-02-24-shared-preferences-falha-em-testes]]
- [[DevLog/2026-02-24-login-campos-cpf-senha]]
