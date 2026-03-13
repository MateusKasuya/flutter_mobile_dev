---
tags: [tipo/devlog, dominio/infra]
date: 2026-03-06
---

# Dev Log — 06/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-06-auth-provider|Migrar token para Provider]]

## O que foi feito

- Adicionado pacote `provider` ao `pubspec.yaml`
- Criado `lib/providers/auth_provider.dart` com `ChangeNotifier`, getter `token` e `setToken`
- `ChangeNotifierProvider` envolve o `MaterialApp` no `main.dart`
- `LoginScreen` seta token no provider após login (`context.read<AuthProvider>().setToken`)
- `HomeScreen` lê token do provider — removido `token` do construtor
- `MovimentoScreen` não recebe mais token (sem mudanças no arquivo)
- Testes adaptados com `ChangeNotifierProvider` na árvore
- `flutter analyze` e `flutter test` sem erros — 26 testes passando

## Decisões tomadas

- Services continuam recebendo token como parâmetro (funções puras) — provider apenas na camada de UI
- `context.read` usado nos callbacks/initState; `context.watch` reservado para rebuilds reativos no `build`

## Problemas encontrados

- Nenhum

## Aprendizados

- Nenhum novo

## Próximos passos

- [[Tasks/2026-03-05-frota-busca-placa|Tela de busca de veículo por placa]]
