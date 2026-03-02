---
tags: [devlog]
date: 2026-03-02
task: "[[Tasks/2026-03-02-home-grid-localizacoes]]"
---

# Dev Log — Home Screen com GridView de localizações

[[Home]]

---

## O que foi feito

Substituída a Home Screen placeholder pela tela funcional com GridView 2x2 exibindo as localizações de pneus.

### Arquivos modificados

- `lib/screens/home_screen.dart` — reescrito como `StatefulWidget` com carregamento assíncrono e GridView
- `lib/services/localizacao_service.dart` — corrigido path do endpoint (`/api-frota/...`)

### Decisões

- `childAspectRatio: 1.5` no GridView para deixar os cards mais largos que altos
- Quantidade em `headlineMedium` bold com cor primária; nome em `titleMedium` com cor secundária — ambos vindos do `AppTheme`, sem hardcode
- `fetchFn` injetável seguindo o mesmo padrão do `loginFn` no `LoginScreen`

## Problema encontrado

404 com HTML ao chamar o endpoint — path estava errado (`/api/frota/...` vs `/api-frota/...`). Diagnosticado via `print` do status e body. Ver [[Bugs/2026-03-02-404-endpoint-path]].

## Próximo passo

[[Tasks/2026-03-02-home-fab-movimento|FloatingActionButton Movimento na Home]]
