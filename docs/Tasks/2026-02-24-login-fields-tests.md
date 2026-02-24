---
tags: [task]
date: 2026-02-24
status: planejada
branch: feat/login-fields-tests
---

# Task — Testes completos dos campos de login

[[Home]]

---

## Contexto

Após implementar as 4 tasks anteriores (Form validation, máscara CPF, toggle senha, lembrar-me), é necessário garantir cobertura de testes para todas as funcionalidades novas e manter os testes existentes funcionando.

## Objetivo

- Cobertura de testes para todas as features dos campos de login
- Testes unitários isolados para validação de CPF
- Testes de widget para interações de UI

---

## Branch

```bash
git checkout -b feat/login-fields-tests
```

## Arquivos a criar

- `test/utils/cpf_validator_test.dart`

## Arquivos a modificar

- `test/screens/login_screen_test.dart`

---

## Implementação

> Instruções passo a passo para o agente de código (Cursor, Claude Code, etc.)

### Passo 1 — Testes unitários do cpf_validator

Criar `test/utils/cpf_validator_test.dart` com:
- CPF válido retorna `true`
- CPF com dígitos errados retorna `false`
- CPF com todos dígitos iguais retorna `false`
- CPF com menos de 11 dígitos retorna `false`
- CPF com formatação (pontos e traço) funciona corretamente
- String vazia retorna `false`

### Passo 2 — Testes de validação de campos vazios

Em `login_screen_test.dart`:
- Submeter com ambos campos vazios → exibe "Informe o CPF" e "Informe a senha"
- Submeter com CPF vazio e senha preenchida → exibe apenas "Informe o CPF"
- Submeter com CPF preenchido e senha vazia → exibe apenas "Informe a senha"

### Passo 3 — Testes da máscara de CPF

- Digitar "07069953925" → campo exibe "070.699.539-25"
- Digitar CPF inválido e submeter → exibe "CPF inválido"

### Passo 4 — Testes do toggle de senha

- Verificar que ícone `visibility` está presente
- Tocar no ícone → campo de senha fica visível (verificar via `obscureText`)
- Tocar novamente → campo volta a ocultar

### Passo 5 — Testes do lembrar-me

- Verificar que checkbox "Lembrar usuário e senha" está presente
- Marcar checkbox → state `_rememberMe` muda
- Mock de `SharedPreferences` com credenciais salvas → campos preenchidos no init
- Login com checkbox marcado → credenciais salvas no `SharedPreferences`

### Passo 6 — Verificar testes existentes

- Garantir que os 3 testes originais continuam passando
- Ajustar se necessário (ex: `TextField` → `TextFormField`)

---

## Critérios de aceite

- [ ] Todos os testes unitários do cpf_validator passando
- [ ] Todos os testes de widget dos campos de login passando
- [ ] Testes existentes (login sucesso, login erro, UI elements) continuam passando
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` 100% passando

---

## Links relacionados

- [[Tasks/2026-02-24-login-form-validation|Task 1 — Form com validação]]
- [[Tasks/2026-02-24-login-cpf-mask|Task 2 — Máscara e validação de CPF]]
- [[Tasks/2026-02-24-login-password-toggle|Task 3 — Toggle de senha]]
- [[Tasks/2026-02-24-login-remember-me|Task 4 — Lembrar credenciais]]
