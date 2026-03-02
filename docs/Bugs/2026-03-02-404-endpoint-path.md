---
tags: [bug]
date: 2026-03-02
status: resolvido
---

# Bug — 404 ao chamar endpoint de localizações

[[Home]]

---

## Sintoma

`FormatException: Unexpected character at 1` ao abrir a Home Screen.

## Causa

O `jsonDecode` recebeu uma página HTML (resposta 404 do servidor) em vez de JSON. O path do endpoint estava incorreto: `/api/frota/pneu/qlocalizacaopneus` (barra) em vez de `/api-frota/pneu/qlocalizacaopneus` (hífen).

## Como diagnosticar

Adicionar temporariamente prints antes do `if (response.statusCode == 200)`:

```dart
print('[service] status: ${response.statusCode}');
print('[service] body: ${response.body}');
```

Se o status for 404 e o body começar com `<!DOCTYPE html>`, o problema é o path da URL.

## Solução

Corrigir o path em `localizacao_service.dart`:

```dart
// Errado
final url = Uri.http(_baseUrl, '/api/frota/pneu/qlocalizacaopneus');

// Correto
final url = Uri.http(_baseUrl, '/api-frota/pneu/qlocalizacaopneus');
```

## Lição

Ao receber `Unexpected character at 1`, suspeitar imediatamente que a resposta não é JSON. Logar `statusCode` e `body` antes de qualquer `jsonDecode` para confirmar.

---

## Links relacionados

- [[Tasks/2026-03-02-home-grid-localizacoes]]
- [[DevLog/2026-03-02-home-grid-localizacoes]]
