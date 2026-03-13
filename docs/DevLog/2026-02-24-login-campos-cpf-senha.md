---
tags: [tipo/devlog, dominio/login]
date: 2026-02-24
---

# Dev Log — 24/02/2026

[[DevLog/_index|DevLog]]

---

## Tasks

- [[Tasks/2026-02-24-login-form-validation|Task 1 — Form com validação de campos vazios]]
- [[Tasks/2026-02-24-login-cpf-mask|Task 2 — Máscara e validação de CPF]]
- [[Tasks/2026-02-24-login-password-toggle|Task 3 — Toggle de visibilidade da senha]]
- [[Tasks/2026-02-24-login-remember-me|Task 4 — Checkbox lembrar usuário e senha]]
- [[Tasks/2026-02-24-login-fields-tests|Task 5 — Testes completos dos campos de login]]

---

## O que foi feito

- Migrado campos `TextField` para `TextFormField` com `Form` e `GlobalKey<FormState>`
- Adicionada validação de campos obrigatórios (CPF e senha) com mensagens inline
- Criado `lib/utils/cpf_validator.dart` com `maskFormatter` e função `isValidCpf` (algoritmo de dígitos verificadores)
- Aplicada máscara `###.###.###-##` no campo CPF via `MaskTextInputFormatter`
- CPF sanitizado (sem máscara) antes de enviar à API
- Adicionado toggle de visibilidade da senha com `IconButton` e ícones `visibility`/`visibility_off`
- Corrigida lógica dos ícones do toggle: `visibility_off` quando senha oculta (padrão), `visibility` quando visível — ícone reflete o estado atual do campo
- Adicionado `shared_preferences` ao projeto
- Implementado checkbox "Lembrar usuário e senha" com persistência via `SharedPreferences`
- Credenciais carregadas automaticamente no `initState` quando `remember_me = true`
- Corrigida chave de erro da resposta da API (`data['message']` → `data['detail']`)
- Criados testes unitários para `isValidCpf` em `test/utils/cpf_validator_test.dart`
- Expandido `test/screens/login_screen_test.dart` de 3 para 9 testes, cobrindo: validação vazia, CPF inválido, toggle de senha e lembrar-me
- Reorganizado histórico git retroativamente: cada task em sua própria branch (`feat/login-*`), com commits atômicos e merge limpo em `main`

---

## Decisões tomadas

- **Uma branch por task** — git flow mantido mesmo para melhorias pequenas; facilita rastreabilidade e rollback
- **`isValidCpf` em arquivo separado** (`lib/utils/cpf_validator.dart`) — facilita teste unitário isolado e reuso futuro
- **`SharedPreferences` injetável via parâmetro** — mesmo padrão do `loginFn`, permite mockar nos testes sem dependência de plataforma
- **Dev Log único por sessão** — as 5 tasks foram planejadas e executadas na mesma sessão, faz mais sentido do que 5 logs separados

---

## Problemas encontrados

- Código do usuário estava todo em `main` sem branches — reorganizado retroativamente com `git stash` + reconstrução de cada branch do zero
- `SharedPreferences.getInstance()` falha em ambiente de testes sem `setMockInitialValues` → corrigido com `setUp(() async { SharedPreferences.setMockInitialValues({}); })` nos testes
- Teste de falha de login usava CPF `00000000000` (todos iguais), que agora é rejeitado pela validação antes de chamar a API → atualizado para CPF válido

---

## Aprendizados

- `TextFormField` internamente cria um `TextField`, então `find.byType(TextField)` ainda funciona nos testes de widget após a migração
- `MaskTextInputFormatter` com `filter: {'#': RegExp(r'[0-9]')}` rejeita automaticamente qualquer caractere não-numérico, mesmo em colar/paste
- `tester.enterText()` nos testes de widget insere texto diretamente no controller, sem passar pelos `inputFormatters` — o validator deve tratar ambos os formatos (com e sem máscara)

---

## Próximos passos

- Persistir o token recebido após login (hoje só é passado por parâmetro para HomeScreen)
- Implementar logout e proteção de rotas
- Tela de Home funcional (hoje só exibe o token)
