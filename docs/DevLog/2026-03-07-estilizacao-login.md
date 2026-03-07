---
tags: [dev-log]
date: 2026-03-07
---

# Dev Log — 07/03/2026

[[Home]]

---

## Task

[[Tasks/2026-03-05-estilizacao-login|Estilização do Login]]

## O que foi feito

- Removido `AppBar` do `Scaffold`, adicionado `SafeArea`
- Container de 180px no topo com gradiente `#CEFCF1 → #FFFFFF`
- Logo SVG e título "Entre na sua conta\nFrota!" (fontSize 26, color `#003156`) dentro do container
- `CpfField` e `PasswordField` atualizados com `BorderRadius.circular(10)`
- Botão "Entrar" com width 300, height 56, `borderRadius: 56` (pill shape), fontSize 20
- Rodapé "por transportefacil.com.br" (fontSize 10) fixado no fundo via coluna
- `flutter analyze` sem erros — 26 testes passando

## Decisões tomadas

- Nenhuma nova

## Problemas encontrados

- `const InputDecoration` no `CpfField` quebrou ao adicionar `BorderRadius.circular` (não é const). Removido o `const`.

## Aprendizados

- Nenhum novo

## Próximos passos

- [[Tasks/2026-03-05-estilizacao-home|Estilização da Home]]
