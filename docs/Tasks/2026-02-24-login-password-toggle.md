---
tags: [task]
date: 2026-02-24
status: planejada
branch: feat/login-password-toggle
---

# Task — Toggle de visibilidade da senha

[[Home]]

---

## Contexto

O campo de senha sempre exibe o texto oculto, sem opção para o usuário verificar o que digitou. Isso é frustrante especialmente em dispositivos móveis onde erros de digitação são frequentes.

## Objetivo

- Ícone de olho no campo de senha que alterna entre mostrar e ocultar o texto
- Comportamento padrão: senha oculta

---

## Branch

```bash
git checkout -b feat/login-password-toggle
```

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `lib/screens/login_screen.dart`

---

## Implementação

> Instruções passo a passo para o agente de código (Cursor, Claude Code, etc.)

### Passo 1 — Adicionar state de visibilidade

No `_LoginScreenState`, adicionar:
```dart
bool _obscurePassword = true;
```

### Passo 2 — Adicionar suffixIcon ao campo de senha

No `InputDecoration` do campo de senha, adicionar:
```dart
suffixIcon: IconButton(
  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
)
```

### Passo 3 — Usar state no obscureText

Trocar `obscureText: true` por `obscureText: _obscurePassword`.

---

## Critérios de aceite

- [ ] Campo de senha exibe ícone de olho à direita
- [ ] Ao tocar no ícone, texto da senha fica visível e ícone muda
- [ ] Ao tocar novamente, texto volta a ficar oculto
- [ ] Estado padrão: senha oculta
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` todos passando

---

## Links relacionados

- [[Tasks/2026-02-24-login-cpf-mask|Task 2 — Máscara e validação de CPF]]
- [[Tasks/2026-02-24-login-remember-me|Task 4 — Lembrar credenciais]]
