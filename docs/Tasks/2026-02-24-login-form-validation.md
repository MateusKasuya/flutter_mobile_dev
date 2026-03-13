---
tags: [tipo/task, dominio/login]
date: 2026-02-24
status: planejada
branch: feat/login-form-validation
---

# Task — Migrar para Form com validação de campos vazios

[[Tasks/_index|Tasks]]

---

## Contexto

A tela de login atual usa `TextField` simples sem nenhuma validação de entrada. O usuário consegue submeter o formulário com campos vazios, o que gera uma chamada desnecessária à API. Migrar para `Form` + `TextFormField` é a base para todas as validações futuras (CPF, senha, etc).

## Objetivo

- Campos de CPF e Senha validados como obrigatórios antes de submeter
- Mensagens de erro inline exibidas pelo próprio `TextFormField`
- Botão "Entrar" só dispara a API se o form for válido

---

## Branch

```bash
git checkout -b feat/login-form-validation
```

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `lib/screens/login_screen.dart`
- `test/screens/login_screen_test.dart`

---

## Implementação

> Instruções passo a passo para o agente de código (Cursor, Claude Code, etc.)

### Passo 1 — Adicionar GlobalKey\<FormState\>

Criar `final _formKey = GlobalKey<FormState>();` no state `_LoginScreenState`.

### Passo 2 — Wrap com Form

Envolver a `Column` dos campos dentro de um widget `Form(key: _formKey, child: ...)`.

### Passo 3 — Trocar TextField por TextFormField

- CPF: trocar `TextField` por `TextFormField`, manter `controller` e `keyboardType`
  - Adicionar `validator`: se vazio, retornar `'Informe o CPF'`
- Senha: trocar `TextField` por `TextFormField`, manter `controller` e `obscureText`
  - Adicionar `validator`: se vazio, retornar `'Informe a senha'`

### Passo 4 — Validar no _handleLogin

No início de `_handleLogin`, adicionar:
```dart
if (!_formKey.currentState!.validate()) return;
```
Antes de setar `_isLoading = true`.

### Passo 5 — Ajustar testes existentes

- Testes existentes usam `find.byType(TextField)` — trocar para `find.byType(TextFormField)`
- Adicionar teste: submeter com campos vazios → mensagens "Informe o CPF" e "Informe a senha" aparecem
- Verificar que testes de login com sucesso e erro continuam passando

---

## Critérios de aceite

- [ ] Campos CPF e Senha usam `TextFormField` com `validator`
- [ ] Submeter com campos vazios exibe mensagens de erro inline
- [ ] Submeter com campos preenchidos continua funcionando normalmente
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` todos passando

---

## Links relacionados

- [[Tasks/2026-02-24-login-cpf-mask|Task 2 — Máscara e validação de CPF]]
- [[Tasks/2026-02-23-login-api|Task anterior — Login com autenticação via API]]
