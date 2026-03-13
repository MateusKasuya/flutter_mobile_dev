---
tags: [tipo/devlog, dominio/frota]
date: 2026-03-13
---

# Dev Log — 13/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-frota-busca-placa|Tela de busca de veículo por placa]]

## O que foi feito

- Criada `FrotaBuscaScreen` com campo de placa, validação, loading inline no botão e toast de erro
- Criada `FrotaDetalheScreen` como placeholder (será preenchida nas próximas tasks)
- Adicionado `onTap` ao `_MovimentoCard` e conectada navegação do card "Frotas" para `FrotaBuscaScreen`

## Decisões tomadas

A task foi planejada antes do `auth-provider` ser implementado e previa passar o token como parâmetro via `Home → Movimento → FrotaBusca`. Como o `AuthProvider` já existe e é o padrão do projeto, `FrotaBuscaScreen` lê o token diretamente via `context.read<AuthProvider>()` — o mesmo padrão do `HomeScreen`. Nenhuma mudança de assinatura foi necessária em `HomeScreen` ou `MovimentoScreen`.

## Problemas encontrados

Nenhum.

## Aprendizados

Nenhum conceito novo — padrões já conhecidos (StatefulWidget, Form, Provider, navegação).

## Próximos passos

- [[Tasks/2026-03-05-frota-veiculo-card|Card de dados do veículo]]
