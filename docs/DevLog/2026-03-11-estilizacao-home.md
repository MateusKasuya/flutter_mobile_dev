---
tags: [tipo/devlog, dominio/home, dominio/estilizacao]
date: 2026-03-11
---

# Dev Log — 11/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-estilizacao-home|Estilizacao da Home]]

## O que foi feito

- Substituído `AppBar` padrão por `AppBar` customizado com `toolbarHeight: 91`, fundo branco e logo SVG alinhada à esquerda via `titleSpacing: 28`
- Cor de fundo da tela definida com `AppColors.backgroundScreen` (`#EDEDED`)
- Título "Monitoramento de movimentações da Frota" centralizado com `AppTextStyles.body`
- Grid migrado de 2 para 3 colunas com `GridView.count`, `shrinkWrap: true` e `childAspectRatio: 0.785`
- Cards refatorados de `Card` para `Container` com `color: Colors.white`, `borderRadius: 16`, borda `1px` em `AppColors.textHint`
- Ícones atualizados por localização: warehouse, local_shipping, recycling, attach_money, build, settings
- `AppColors.iconColor` (`#00ACAD`) e `AppColors.backgroundScreen` adicionados ao `app_colors.dart`
- FAB substituído por `FloatingActionButton.extended` com dimensões fixas `300x56` via `SizedBox` e `borderRadius: 56`
- Conteúdo (título + grid) deslocado levemente para cima com `Padding(bottom: 80)` em volta da `Column`

## Decisões tomadas

- Usado `AppBar` com fundo branco em vez de `SafeArea + Container` — mais simples e gerencia a status bar automaticamente
- `Container` com `BoxDecoration` em vez de `Card` — sem sombra conforme Figma
- `GridView.count` mantido em vez de `Wrap` — garante 3 colunas independente do tamanho da tela

## Problemas encontrados

- `GridView` dentro de `Column` sem `shrinkWrap: true` quebrava o layout (altura infinita)
- Parênteses extras quebrando compilação no `_LocalizacaoCard`

## Aprendizados

- `SafeArea` vs `AppBar`: ambos resolvem a status bar, mas `AppBar` é mais direto quando há uma barra no topo
- `childAspectRatio` no `GridView`: `largura / altura` define a proporção dos cards
- `bottomNavigationBar` vs `FloatingActionButton`: FAB flutua sobre o conteúdo, `bottomNavigationBar` reserva espaço fixo no rodapé
- `shrinkWrap: true` + `NeverScrollableScrollPhysics` para `GridView` dentro de `Column`

## Próximos passos

- Estilização da tela Movimento ([[Tasks/2026-03-05-estilizacao-movimento]])
