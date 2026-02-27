---
tags: [dev-log]
date: 2026-02-27
---

# Dev Log — 27/02/2026

[[Home]]

---

## Task

[[Tasks/2026-02-26-app-theme-color|Definir tema de cores padrão do app]]

## O que foi feito

- Criado `lib/theme/app_theme.dart` com a classe `AppTheme` centralizando as constantes de cor e o `ThemeData`
- Cor primária definida como `#028687` via `ColorScheme.fromSeed`
- `textColor` (`#414F56`) declarado como constante para uso futuro
- Aplicado `theme: AppTheme.theme` no `MaterialApp` em `lib/main.dart`
- Removido `const` do `MaterialApp` (necessário pois `AppTheme.theme` não é constante)

## Decisões tomadas

- **`textColor` declarado mas não aplicado ao `textTheme`**: optou-se por reservar a constante sem aplicar via `textTheme.apply` por ora, aguardando necessidade concreta de sobrescrever as cores de texto padrão do Material 3.
- **`useMaterial3` não explicitado**: padrão `true` desde Flutter 3.16, não há necessidade de declarar.

## Problemas encontrados

Nenhum.

## Aprendizados

- `ColorScheme.fromSeed` gera todo o sistema de cores do Material 3 a partir de uma única cor semente, aplicando-se automaticamente a AppBar, botões, checkboxes, bordas de foco, etc.
- Para aplicar cor de texto globalmente via tema, o caminho é `ThemeData().textTheme.apply(bodyColor: ..., displayColor: ...)` passado via `copyWith`.

## Próximos passos

- Aplicar `textColor` ao `textTheme` quando a tela de login for modularizada ou quando surgir necessidade visual concreta
- Tasks pendentes: toast de erro, loading screen, logo SVG, modularização do login
