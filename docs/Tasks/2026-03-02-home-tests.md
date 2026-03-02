---
tags: [task]
date: 2026-03-02
status: planejada
branch: feat/home-tests
---

# Task — Testes da Home Screen (service, GridView e FAB)

[[Home]]

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

- `lib/screens/home_screen.dart` — se necessário, injetar dependência do service (mesmo padrão do `loginFn` no `LoginScreen`) para permitir mock nos testes

---

## Implementação

> **Pré-requisito:** Tasks [[Tasks/2026-03-02-localizacao-service|Service]], [[Tasks/2026-03-02-home-grid-localizacoes|GridView]] e [[Tasks/2026-03-02-home-fab-movimento|FAB Movimento]] concluídas.

### Passo 1 — Garantir injeção de dependência na HomeScreen

Verificar que `HomeScreen` aceita o service como parâmetro opcional (mesmo padrão do `LoginScreen.loginFn`):

```dart
class HomeScreen extends StatefulWidget {
  final String token;
  final Future<List<Localizacao>> Function(String token) fetchFn;

  const HomeScreen({
    super.key,
    required this.token,
    this.fetchFn = fetchLocalizacoes,
  });
}
```

### Passo 2 — Testes unitários do service

Criar `test/services/localizacao_service_test.dart`:

- Testar `Localizacao.fromJson` com JSON válido
- Testar que `fetchLocalizacoes` faz GET com header `Authorization: Bearer <token>`
- Testar parse correto da lista de localizações (mock HTTP)
- Testar que lança Exception em caso de erro HTTP

### Passo 3 — Testes de widget da Home Screen

Criar `test/screens/home_screen_test.dart`:

- **Loading:** ao abrir, exibe indicador de loading
- **GridView:** após carregar, exibe 4 cards com nomes e quantidades corretas
- **Layout 2x2:** verifica que o grid tem 2 colunas
- **Erro:** quando service falha, exibe toast de erro
- **FAB:** botão "Movimento" está visível
- **Navegação FAB:** ao tocar no FAB, navega para `MovimentoScreen`

### Passo 4 — Rodar testes e validar

```bash
flutter test
flutter analyze
```

---

## Critérios de aceite

- [ ] `Localizacao.fromJson` testado com dados válidos
- [ ] Service testado com mock HTTP (sucesso e erro)
- [ ] Home Screen exibe loading durante carregamento
- [ ] Home Screen exibe 4 cards com dados corretos
- [ ] Home Screen trata erro da API
- [ ] FAB "Movimento" visível e navegação funciona
- [ ] `flutter test` passa sem falhas
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-localizacao-service|Modelo e serviço de localizações]]
- [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]]
- [[Tasks/2026-03-02-home-fab-movimento|FAB Movimento]]
- [[DevLog/]]
