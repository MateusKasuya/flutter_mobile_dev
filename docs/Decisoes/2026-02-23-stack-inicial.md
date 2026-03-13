---
tags: [tipo/adr, dominio/infra]
date: 2026-02-23
status: aceita
---

# ADR — Stack inicial

[[Decisoes/_index|Decisões]]

---

## Contexto

Início do projeto Frota Fácil Mobile — aplicativo de gerenciamento de frotas.

## Decisão

- **Framework:** Flutter (SDK ^3.10.8)
- **Linguagem:** Dart
- **Plataformas-alvo:** Android e iOS
- **Lint:** `flutter_lints` (padrão Flutter)

## Motivação

Flutter permite um único codebase para Android e iOS com performance nativa e boa DX.

## Consequências

- Toda a UI será em widgets Flutter.
- Lógica de negócio e integrações em Dart.
- Decisões de state management, navegação e HTTP client serão registradas em ADRs separados conforme surgem.

## Status

`aceita`
