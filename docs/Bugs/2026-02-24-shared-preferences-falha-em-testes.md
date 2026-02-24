---
tags: [bug, solucao]
date: 2026-02-24
resolved: true
---

# Problema — SharedPreferences.getInstance() falha em testes de widget

[[Home]]

---

## Descrição

Após adicionar `SharedPreferences` ao `LoginScreen` e chamar `SharedPreferences.getInstance()` no `initState`, os testes de widget que antes passavam começaram a falhar (exceção de platform channel não inicializado).

**Comportamento esperado:** testes passam normalmente.
**Comportamento observado:** exceção ou travamento ao executar `flutter test`.

## Contexto

`LoginScreen._loadSavedCredentials()` chamada no `initState`:

```dart
Future<void> _loadSavedCredentials() async {
  final prefs = widget.prefs ?? await SharedPreferences.getInstance();
  // ...
}
```

Nos testes, `widget.prefs` é `null` (não passado), então cai no `SharedPreferences.getInstance()`, que não tem o canal de plataforma disponível no ambiente de testes.

## Investigação

- `SharedPreferences` usa platform channels para acessar `NSUserDefaults` (iOS) ou `SharedPreferences` (Android)
- Em testes de widget (`flutter test`), os platform channels não estão inicializados por padrão
- Sem mock, a chamada falha ou retorna resultado indefinido

## Solução

```dart
// No arquivo de testes, adicionar:
setUp(() async {
  SharedPreferences.setMockInitialValues({});
});
```

E para testes que precisam de dados pré-carregados, injetar o `prefs` diretamente:

```dart
SharedPreferences.setMockInitialValues({'remember_me': true, 'saved_cpf': '070.699.539-25'});
final prefs = await SharedPreferences.getInstance();
await tester.pumpWidget(MaterialApp(home: LoginScreen(prefs: prefs, loginFn: fakeLogin)));
```

## Root cause

`SharedPreferences.getInstance()` depende de platform channels que não existem no ambiente de testes. É necessário usar `setMockInitialValues` para inicializar o mock antes de qualquer teste que instancie widgets que usem `SharedPreferences`.

## Aprendizado

> [[Aprendizados/2026-02-24-shared-preferences-em-testes]]
