---
tags: [tipo/task, dominio/infra]
date: 2026-03-13
status: concluída
branch: main
---

# Task — Remoção de SVGs redundantes

[[Tasks/_index|Tasks]]

---

## Contexto

O projeto acumulou arquivos SVG em `assets/` que replicam visualmente ícones já disponíveis via `Icons.*` (Material Icons). Esses SVGs não estavam sendo referenciados no código Dart — os `Icons.*` já estavam em uso nas telas. A manutenção de arquivos mortos aumenta o tamanho do bundle e gera ruído no repositório.

## Objetivo

Remover todos os SVGs de ícones genéricos de `assets/`, mantendo apenas os SVGs de identidade visual (logos). Confirmar que o código não quebra e os testes passam.

---

## Branch

```bash
# executado direto na main (mudança puramente de assets, sem código Dart)
```

## Arquivos a criar

- `docs/Tasks/2026-03-13-remocao-svgs-redundantes.md`
- `docs/DevLog/2026-03-13-remocao-svgs-redundantes.md`

## Arquivos a modificar

- nenhum arquivo Dart modificado

## Arquivos removidos

- `assets/estoque.svg` → `Icons.warehouse`
- `assets/frota.svg` → `Icons.local_shipping`
- `assets/sucata.svg` → `Icons.recycling`
- `assets/venda.svg` → `Icons.attach_money`
- `assets/conserto.svg` → `Icons.build`
- `assets/recapagem.svg` → `Icons.settings`
- `assets/frota-icon.svg` → `Icons.local_shipping`
- `assets/pneu-icon.svg` → `Icons.tire_repair`
- `assets/abastec-icon.svg` → `Icons.local_gas_station`
- `assets/seta-icon.svg` → `Icons.arrow_forward_ios`
- `assets/mais-icon.svg` → `Icons.add_circle`

## SVGs mantidos (identidade visual)

- `assets/logo_frota_branco.svg` — splash screen
- `assets/logo_horizontal.svg` — AppBar da home
- `assets/icone_Frota.svg` — ícone do app

---

## Implementação

### Passo 1 — Confirmar que nenhum SVG é referenciado no código Dart

```bash
grep -r "estoque.svg\|frota.svg\|sucata.svg\|venda.svg\|conserto.svg\|recapagem.svg\|frota-icon\|pneu-icon\|abastec-icon\|seta-icon\|mais-icon" lib/
# resultado esperado: nenhum match
```

### Passo 2 — Remover os arquivos SVG redundantes

```bash
rm assets/estoque.svg assets/frota.svg assets/sucata.svg assets/venda.svg \
   assets/conserto.svg assets/recapagem.svg assets/frota-icon.svg \
   assets/pneu-icon.svg assets/abastec-icon.svg assets/seta-icon.svg \
   assets/mais-icon.svg
```

### Passo 3 — Verificar

```bash
flutter analyze   # sem erros
flutter test      # testes existentes passam
```

---

## Critérios de aceite

- [x] Nenhum SVG de ícone genérico em `assets/`
- [x] Apenas logos SVG permanecem (`logo_frota_branco`, `logo_horizontal`, `icone_Frota`)
- [x] `flutter analyze` sem erros
- [x] Testes existentes continuam passando (falhas pré-existentes não contam)

---

## Links relacionados

- [[DevLog/2026-03-13-remocao-svgs-redundantes]]
