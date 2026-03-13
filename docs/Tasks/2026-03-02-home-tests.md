---
tags: [tipo/task, dominio/home]
date: 2026-03-02
status: concluída
branch: main
---

# Task — Testes da Home Screen (service, GridView e FAB)

[[Tasks/_index|Tasks]]

---

## Contexto

As tasks de localizações, GridView e FAB Movimento introduzem código novo sem cobertura de testes. Seguindo o padrão do projeto (ex: `login-fields-tests`), precisamos garantir que o serviço, a exibição dos dados e a navegação funcionem corretamente.

## Objetivo

Cobertura de testes unitários para o service e testes de widget para a Home Screen (GridView + FAB + navegação).

---

## Branch

```bash
git checkout -b feat/home-tests
```

## Arquivos a criar

- `test/services/localizacao_service_test.dart`
- `test/screens/home_screen_test.dart`

## Arquivos a modificar

- `lib/services/localizacao_service.dart` — adicionar parâmetro `client` para injeção de HTTP mock

---

## Implementação

> **Pré-requisito:** Tasks [[Tasks/2026-03-02-localizacao-service|Service]], [[Tasks/2026-03-02-home-grid-localizacoes|GridView]] e [[Tasks/2026-03-02-home-fab-movimento|FAB Movimento]] concluídas.

### Passo 1 — Adaptar `fetchLocalizacoes` para aceitar `http.Client`

Diferente do `HomeScreen` (que injeta a função via parâmetro do widget), aqui o mock é passado diretamente para a função via parâmetro opcional `client`:

```dart
Future<List<Localizacao>> fetchLocalizacoes(String token,
    {http.Client? client}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(_baseUrl, '/api-frota/pneu/qlocalizacaopneus');
    final response = await c.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data
          .map((e) => Localizacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Erro ao buscar localizações');
    }
  } finally {
    if (createdClient) c.close();
  }
}
```

**`{http.Client? client}`**

Parâmetro nomeado opcional. Em produção, nenhum `client` é passado — a função cria o seu próprio. Nos testes, passamos um `MockClient` que intercepta as requisições sem fazer chamadas reais de rede.

**`final createdClient = client == null`**

Guardamos se o client foi criado internamente antes de inicializá-lo. Precisamos dessa informação para decidir se devemos fechá-lo no `finally`.

**`final c = client ?? http.Client()`**

O operador `??` (null-coalescing): se `client` for `null`, cria um novo `http.Client()`. Caso contrário, usa o que foi injetado.

**`try/finally` com `c.close()`**

`http.Client` mantém conexões abertas para reutilização (connection pooling). Se criamos o client internamente, somos responsáveis por fechá-lo — o `finally` garante que isso ocorra mesmo se a função lançar uma exception. Se o client foi injetado externamente (nos testes), não o fechamos — quem o criou é responsável por isso.

---

### Passo 2 — Testes unitários do service

Criar `test/services/localizacao_service_test.dart`:

```dart
import 'package:http/testing.dart';

group('Localizacao.fromJson', () {
  test('parseia JSON válido corretamente', () {
    final json = {'QTLOCALIZACAO': 10, 'LOCALIZACAO': 'ESTOQUE'};
    final loc = Localizacao.fromJson(json);
    expect(loc.quantidade, 10);
    expect(loc.nome, 'ESTOQUE');
  });
});

group('fetchLocalizacoes', () {
  test('faz GET com header Authorization Bearer token', () async {
    http.Request? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(jsonEncode([]), 200,
          headers: {'content-type': 'application/json'});
    });

    await fetchLocalizacoes('meu-token', client: client);

    expect(capturedRequest!.headers['Authorization'], 'Bearer meu-token');
  });

  test('retorna lista de localizações quando status 200', () async { ... });
  test('lança Exception quando status não é 200', () async { ... });
  test('lança Exception com mensagem genérica quando detail ausente', () async { ... });
});
```

**`MockClient` do pacote `http/testing.dart`**

`MockClient` recebe uma função que simula o servidor: toda chamada HTTP feita por ele executa essa função em vez de ir para a rede. Retornamos um `http.Response` com o body e status que quisermos testar.

**`http.Request? capturedRequest`**

Variável declarada fora da função do mock para capturar a requisição que chegou. Permite inspecionar headers, URL, método após a chamada — útil para verificar que o header `Authorization` foi enviado corretamente.

**`group(...)`**

Agrupa testes relacionados logicamente. No output do `flutter test`, os testes aparecem como `Localizacao.fromJson > parseia JSON válido`, facilitando a leitura dos resultados.

---

### Passo 3 — Testes de widget da Home Screen

Criar `test/screens/home_screen_test.dart`:

```dart
Widget buildApp(Future<List<Localizacao>> Function(String) fetchFn) {
  return MaterialApp(
    home: HomeScreen(token: 'test-token', fetchFn: fetchFn),
  );
}

final mockLocalizacoes = [
  const Localizacao(quantidade: 5, nome: 'ESTOQUE'),
  const Localizacao(quantidade: 10, nome: 'FROTA'),
  const Localizacao(quantidade: 3, nome: 'SUCATA'),
  const Localizacao(quantidade: 7, nome: 'VENDA'),
];
```

**Helper `buildApp`**

Função local que envolve a `HomeScreen` em um `MaterialApp`. Testes de widget precisam de um app ao redor para que o `Navigator`, o `Theme` e outros recursos do framework funcionem. Extrair como helper evita repetir esse código em cada teste.

**Testes implementados:**

```dart
// Loading: usa Completer para controlar quando a Future resolve
testWidgets('exibe indicador de loading ao abrir', (tester) async {
  final completer = Completer<List<Localizacao>>();
  await tester.pumpWidget(buildApp((_) => completer.future));
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  completer.complete(mockLocalizacoes);
  await tester.pumpAndSettle();
});

// Grid 2x2: inspeciona o SliverGridDelegate diretamente
testWidgets('grid tem 2 colunas', (tester) async { ... });

// Navegação: toca no FAB e verifica que MovimentoScreen aparece
testWidgets('ao tocar no FAB navega para MovimentoScreen', (tester) async {
  await tester.tap(find.text('Movimento'));
  await tester.pumpAndSettle();
  expect(find.byType(MovimentoScreen), findsOneWidget);
});
```

**`Completer<T>`**

Permite controlar manualmente quando uma `Future` resolve. Usado no teste de loading: criamos a Future sem resolver, verificamos que o loading aparece, depois resolvemos com `completer.complete(...)`. Sem o `Completer`, a Future resolveria imediatamente e nunca veríamos o estado de loading.

**`tester.pumpAndSettle()`**

`pump()` avança um frame. `pumpAndSettle()` avança frames repetidamente até que não haja mais animações ou timers pendentes — equivale a "esperar a tela estabilizar". Necessário após navegação e após futures resolverem.

---

### Passo 4 — Rodar testes e validar

```bash
flutter test
flutter analyze
```

---

## Critérios de aceite

- [x] `Localizacao.fromJson` testado com dados válidos
- [x] Service testado com mock HTTP (header, sucesso, erro com detail, erro sem detail)
- [x] Home Screen exibe loading durante carregamento
- [x] Home Screen exibe 4 cards com dados corretos
- [x] Grid verificado com 2 colunas
- [x] Home Screen permanece na tela quando service falha
- [x] FAB "Movimento" visível com ícone `swap_horiz`
- [x] Navegação para `MovimentoScreen` ao tocar no FAB
- [x] `flutter test` — 11/11 testes passando
- [x] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-localizacao-service|Modelo e serviço de localizações]]
- [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]]
- [[Tasks/2026-03-02-home-fab-movimento|FAB Movimento]]
- [[DevLog/2026-03-02-home-tests]]
