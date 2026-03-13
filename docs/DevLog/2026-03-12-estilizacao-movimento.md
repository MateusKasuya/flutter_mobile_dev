---
tags: [tipo/devlog, dominio/movimento, dominio/estilizacao]
date: 2026-03-12
---

# Dev Log — 12/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-estilizacao-movimento|Estilizacao do Movimento]]

## O que foi feito

- `Card` substituído por `Container` com `BoxDecoration` — fundo teal sólido (`AppColors.primary`), `borderRadius: 12` e sombra `BoxShadow` com `offset (0,4)`, `blurRadius 15`, `color #0000004D` (conforme Figma)
- Removida a barra lateral colorida dos cards anteriores
- Layout interno do card refatorado: `Column` com `mainAxisAlignment.center` envolta por `Padding(horizontal: 35, right: 20)`, com `Row` externo para posicionar a seta à direita
- Ícone, label e sublabel em branco (`Colors.white`)
- Sublabel em `toUpperCase()` via `.toUpperCase()` aplicado na chamada
- Estilos centralizados em `AppTextStyles.labelCardMovements` e `AppTextStyles.sublabelCardMovements`
- Parâmetro opcional `labelFontSize` adicionado ao `_MovimentoCard` para permitir override de tamanho por card — usado em "Abastecimento" com `22px`
- Seta `Icons.arrow_forward_ios` branca posicionada à direita via `Row` + `Expanded`
- `AppBar` com `centerTitle: true` para centralizar o título
- `ListView` envolvida em `Center` com `shrinkWrap: true` para centralizar os cards verticalmente na tela

## Decisões tomadas

- `Container` + `BoxDecoration` em vez de `Card` — permite controle preciso do `BoxShadow` (offset, blurRadius, spreadRadius) que o `Card.elevation` não oferece
- `ClipRRect` removido pelo linter — sem impacto visual pois o `InkWell` foi removido junto (sem `onTap` implementado ainda)
- `labelFontSize` como parâmetro opcional em vez de subclasse — solução mais simples para o caso pontual de "Abastecimento" com fonte menor

## Problemas encontrados

- Linter removeu `ClipRRect`, `InkWell` e `Padding` em uma edição intermediária, deixando parênteses desbalanceados — resolvido reescrevendo o arquivo completo
- `height` e `width` do `Container` removidos pelo linter em outra edição — restaurados manualmente

## Aprendizados

- `BoxShadow` no Flutter usa formato ARGB (`0x4D000000`), enquanto CSS usa RRGGBBAA (`#0000004D`) — o canal alpha muda de posição
- `ClipRRect` é necessário quando `InkWell` está dentro de `Container` com `borderRadius` — sem ele o ripple vaza para fora dos cantos arredondados
- `shrinkWrap: true` no `ListView` faz ele ocupar apenas o espaço dos filhos, permitindo centralização via `Center`
- `copyWith` em `TextStyle` sobrescreve só os campos especificados, mantendo fonte, peso e cor originais

## Próximos passos

- [[Tasks/2026-03-05-frota-busca-placa|Tela de busca de veiculo por placa]]
