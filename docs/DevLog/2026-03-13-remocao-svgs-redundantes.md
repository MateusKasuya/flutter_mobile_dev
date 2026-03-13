---
tags: [tipo/devlog, dominio/infra]
date: 2026-03-13
---

# Dev Log — 13/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-13-remocao-svgs-redundantes|Remoção de SVGs redundantes]]

## O que foi feito

Removidos 11 arquivos SVG de `assets/` que replicavam ícones já disponíveis via `Icons.*` (Material Icons) e que não estavam sendo referenciados em nenhum arquivo Dart. Os três SVGs de identidade visual foram mantidos: `logo_frota_branco.svg`, `logo_horizontal.svg` e `icone_Frota.svg`.

SVGs removidos e seus equivalentes em código:

| SVG removido | Icon em uso |
|---|---|
| `estoque.svg` | `Icons.warehouse` |
| `frota.svg` | `Icons.local_shipping` |
| `sucata.svg` | `Icons.recycling` |
| `venda.svg` | `Icons.attach_money` |
| `conserto.svg` | `Icons.build` |
| `recapagem.svg` | `Icons.settings` |
| `frota-icon.svg` | `Icons.local_shipping` |
| `pneu-icon.svg` | `Icons.tire_repair` |
| `abastec-icon.svg` | `Icons.local_gas_station` |
| `seta-icon.svg` | `Icons.arrow_forward_ios` |
| `mais-icon.svg` | `Icons.add_circle` |

## Decisões tomadas

Nenhuma decisão de arquitetura relevante — remoção de arquivos mortos.

## Problemas encontrados

Nenhum. A busca por referências nos arquivos Dart confirmou que os SVGs não estavam sendo usados. `flutter analyze` passou sem erros.

## Aprendizados

Nenhum novo aprendizado — tarefa de limpeza simples.

## Próximos passos

Prosseguir com as tasks planejadas do módulo Frota.
