---
tags: [aprendizado]
date: 2026-02-24
topic: Flutter / Testes
---

# TextFormField em testes de widget

[[Home]]

---

## O que aprendi

Dois comportamentos importantes ao testar widgets com `TextFormField`:

### 1. `find.byType(TextField)` ainda funciona

`TextFormField` **não é** subclasse de `TextField` — é uma subclasse de `FormField`. Mas internamente ele constrói um `TextField` no seu método `build`. Por isso, `find.byType(TextField)` encontra o `TextField` interno na árvore de widgets.

Na prática: migrar de `TextField` para `TextFormField` **não quebra** testes que usam `find.byType(TextField)`.

### 2. `tester.enterText()` bypassa `inputFormatters`

`tester.enterText()` insere texto diretamente no `TextEditingController`, sem passar pelos `inputFormatters`. Então, se o campo tem uma máscara de CPF, digitar `07069953925` no teste não formata o valor — o controller fica com `07069953925`, não `070.699.539-25`.

Consequência: os validators precisam lidar com os dois formatos (com e sem máscara), ou o teste deve usar o texto já formatado.

## Por que importa

Entender esses dois comportamentos evita:
- Reescrever testes desnecessariamente ao migrar para `TextFormField`
- Validators que só funcionam com o texto mascarado e quebram nos testes

## Exemplo prático

```dart
// Funciona mesmo com TextFormField:
await tester.enterText(find.byType(TextField).first, '07069953925');

// Validator robusto — funciona com ou sem máscara:
validator: (value) {
  if (value == null || value.isEmpty) return 'Informe o CPF';
  final digits = value.replaceAll(RegExp(r'[^\d]'), ''); // remove máscara se houver
  if (digits.length < 11) return 'CPF incompleto';
  if (!isValidCpf(value)) return 'CPF inválido';
  return null;
},
```

## Referências

- Documentação Flutter: `TextFormField`, `InputFormatter`

## Links relacionados

- [[Tasks/2026-02-24-login-cpf-mask]]
- [[DevLog/2026-02-24-login-campos-cpf-senha]]
