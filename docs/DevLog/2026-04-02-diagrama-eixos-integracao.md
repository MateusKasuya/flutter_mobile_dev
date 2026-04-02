---
tags: [tipo/devlog, dominio/frota]
date: 2026-04-02
---

# Dev Log — 02/04/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-04-01-diagrama-eixos-integracao|Integração do diagrama de eixos na FrotaDetalheScreen]]

## O que foi feito

- Integrado o widget `DiagramaEixos` na `FrotaDetalheScreen`, substituindo a lista `_PneuCard`
- Criado o enum `PneuAcao` com as 5 ações (Estoque, Conserto, Recapagem, Sucata, Venda)
- Adicionadas zonas de ação (`DragTarget<Pneu>`) com destaque animado ao pairar
- Implementado diálogo de confirmação ao soltar pneu em uma zona
- Implementado bottom sheet de detalhes ao tocar rapidamente em um pneu
- Adicionada `showSuccessToast` ao `app_toast.dart`

## Decisões tomadas

- Zonas de ação ficam sempre visíveis abaixo do diagrama (sem mostrar/esconder durante o drag) — abordagem mais simples e confiável
- `FilledButton` no diálogo usa a cor da ação para reforço visual semântico

## Problemas encontrados

- `showSuccessToast` não existia em `app_toast.dart` — adicionada junto com esta task
- Import `eixo.dart` estava desnecessário em `frota_detalhe_screen.dart` (o tipo `Eixo` é usado internamente pelo `buildEixoLayout`, não exposto na screen) — removido

## Aprendizados

- `DragTarget.builder` recebe `candidateData` (lista dos dados pairando sobre o target) — quando não está vazio, um item está sendo arrastado sobre a zona
- `AnimatedContainer` anima automaticamente qualquer mudança de propriedade decorativa entre rebuilds

## Próximos passos

- Task de testes: [[Tasks/2026-04-01-diagrama-eixos-tests|Testes do diagrama de eixos]]
