---
tags: [task]
date: 2026-02-24
status: planejada
branch: feat/login-cpf-mask
---

# Task — Máscara e validação de CPF

[[Home]]

---

## Contexto

O campo de CPF aceita qualquer texto numérico sem formatação visual e sem validação de dígitos verificadores. Isso prejudica a UX (usuário não sabe se digitou certo) e permite enviar CPFs inválidos à API.

## Objetivo

- Campo CPF formata automaticamente no padrão `000.000.000-00` enquanto o usuário digita
- CPFs com dígitos verificadores inválidos são rejeitados com mensagem de erro
- O CPF enviado à API continua sem máscara (apenas dígitos)

---

## Branch

```bash
git checkout -b feat/login-cpf-mask
```

## Arquivos a criar

- `lib/utils/cpf_validator.dart`

## Arquivos a modificar

- `lib/screens/login_screen.dart`

---

## Implementação

> Instruções passo a passo para o agente de código (Cursor, Claude Code, etc.)

### Passo 1 — Criar cpf_validator.dart

Criar `lib/utils/cpf_validator.dart` com função pura `bool isValidCpf(String cpf)`:
1. Remover formatação (pontos e traço), ficar com dígitos
2. Rejeitar se não tiver 11 dígitos
3. Rejeitar CPFs com todos dígitos iguais (ex: 111.111.111-11)
4. Calcular primeiro dígito verificador (pesos 10→2)
5. Calcular segundo dígito verificador (pesos 11→2)
6. Comparar com os 2 últimos dígitos

### Passo 2 — Aplicar máscara no campo CPF

No `login_screen.dart`, importar `mask_text_input_formatter` (já está no pubspec) e adicionar ao campo CPF:
```dart
inputFormatters: [MaskTextInputFormatter(mask: '###.###.###-##')]
```

> **Nota:** O `#` da máscara aceita apenas dígitos (0-9), então letras e caracteres especiais são automaticamente rejeitados pelo formatter — mesmo que o usuário cole texto ou use um teclado que permita letras. Combinado com `keyboardType: TextInputType.number` (que já existe no campo), o input fica restrito apenas a números.

### Passo 3 — Integrar validação no validator do CPF

Atualizar o `validator` do campo CPF:
- Se vazio → `'Informe o CPF'`
- Se CPF incompleto (menos de 14 chars com máscara) → `'CPF incompleto'`
- Se dígitos verificadores inválidos (`!isValidCpf(value)`) → `'CPF inválido'`

### Passo 4 — Remover máscara antes de enviar à API

No `_handleLogin`, ao passar o CPF para `loginFn`, usar:
```dart
_cpfController.text.replaceAll(RegExp(r'[.\-]'), '').trim()
```

---

## Critérios de aceite

- [ ] Digitar números no campo CPF exibe formatado como `000.000.000-00`
- [ ] CPF com dígitos verificadores inválidos exibe "CPF inválido"
- [ ] CPF incompleto exibe "CPF incompleto"
- [ ] API recebe CPF sem máscara (apenas dígitos)
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` todos passando

---

## Links relacionados

- [[Tasks/2026-02-24-login-form-validation|Task 1 — Form com validação]]
- [[Tasks/2026-02-24-login-password-toggle|Task 3 — Toggle de senha]]
