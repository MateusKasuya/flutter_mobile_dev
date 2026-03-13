---
tags: [tipo/devlog, dominio/login, dominio/infra]
date: 2026-02-27
---

# Dev Log — 27/02/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-02-26-login-modularization|Modularizar a tela de login]]

## O que foi feito

- Criado `lib/components/cpf_field.dart` — `CpfField` stateless com máscara e validação de CPF encapsuladas
- Criado `lib/components/password_field.dart` — `PasswordField` stateful com `_obscurePassword` gerenciado internamente
- Criado `lib/components/remember_me_checkbox.dart` — `RememberMeCheckbox` stateless recebendo `value` e `onChanged`
- `login_screen.dart` refatorado: substituiu os campos inline pelos 3 componentes, removeu `_obscurePassword` do state
- `LoginScreen` reduzida de ~185 para ~148 linhas, responsável apenas por: estado do form, lógica de login, credenciais salvas e navegação

## Decisões tomadas

- **`lib/components/`** no lugar de `lib/widgets/`— convenção já estabelecida no projeto com `LoadingOverlay`
- **`_obscurePassword` movido para `PasswordField`** — o toggle só afeta o campo de senha, faz sentido ser estado interno do componente, simplificando o `_LoginScreenState`
- **`RememberMeCheckbox` stateless** — o estado `_rememberMe` precisa permanecer na `LoginScreen` pois é usado na lógica de salvar credenciais (`_handleLogin`)

## Problemas encontrados

Nenhum. Todos os 15 testes passaram sem modificação — os testes operam via `TextFormField` e `CheckboxListTile` encontrados na árvore de widgets, independente de onde estão declarados.

## Aprendizados

- Extrair widgets stateful (como `PasswordField`) não requer mudanças nos testes que interagem com o widget via `find.byType` ou `find.byIcon` — o Flutter encontra o widget na árvore independente da hierarquia de classes.
- Separar estado interno de UI (toggle de visibilidade) de estado de negócio (rememberMe, loading) é um bom critério para decidir o que fica no componente vs. na tela.

## Próximos passos

- Todas as tasks planejadas estão concluídas.
- Próximas tasks a planejar: home screen, navegação, integração com APIs de frota.
