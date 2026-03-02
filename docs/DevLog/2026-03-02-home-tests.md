---
tags: [devlog]
date: 2026-03-02
task: "[[Tasks/2026-03-02-home-tests]]"
---

# Dev Log — Testes da Home Screen

[[Home]]

---

## O que foi feito

Cobertura de testes para o service de localizações e a Home Screen. 11 testes, todos passando.

### Arquivos criados

- `test/services/localizacao_service_test.dart` — 5 testes unitários
- `test/screens/home_screen_test.dart` — 6 testes de widget

### Arquivos modificados

- `lib/services/localizacao_service.dart` — adicionado parâmetro `{http.Client? client}` para injeção de mock HTTP com `try/finally` para fechar o client apenas quando criado internamente

### Detalhes

- Padrão de mock HTTP via `MockClient` do pacote `http/testing.dart`
- Padrão de injeção diferente do `HomeScreen`: o client é passado direto para a função (não via widget), pois o service é uma função e não um widget
- `Completer<T>` usado para testar o estado de loading antes da Future resolver
- `group()` para organizar os testes do service por contexto
