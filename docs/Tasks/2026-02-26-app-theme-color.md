---
tags: [tipo/task, dominio/infra]
date: 2026-02-26
status: concluída
branch: feat/app-theme-color
---

# Task — Definir tema de cores padrão do app

[[Tasks/_index|Tasks]]

---

## Contexto

O app não possui `ThemeData` configurado no `MaterialApp`, usando o tema padrão do Flutter. Isso resulta em cores inconsistentes entre componentes (AppBar, botões, checkbox, inputs, etc.). Precisamos definir uma cor primária padrão que se aplique a todos os componentes automaticamente.

## Objetivo

Configurar um `ThemeData` com `ColorScheme` baseado na cor `#028687` como cor primária e `#414F56` como cor padrão de texto, aplicando-os globalmente a todos os componentes (AppBar, ElevatedButton, CheckboxListTile, OutlineInputBorder focus, CircularProgressIndicator, etc.).

---

## Branch

```bash
git checkout -b feat/app-theme-color
```

## Arquivos a criar

- `lib/theme/app_theme.dart` — arquivo com a definição do tema

## Arquivos a modificar

- `lib/main.dart` — aplicar o tema no `MaterialApp`

---

## Implementação

> Instruções passo a passo para o agente de código

### Passo 1 — Criar arquivo de tema

Criar `lib/theme/app_theme.dart` com o `ThemeData` centralizado:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0XFF028687);
  static const Color textColor = Color(0xFF414F56); // reservado para uso futuro

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);
    return ThemeData(
      colorScheme: colorScheme,
    );
  }
}
```

- `ColorScheme.fromSeed` gera automaticamente variações da cor primária (onPrimary, secondary, surface, etc.) para todos os componentes.
- `textColor` está declarado como constante para uso futuro (aplicação via `textTheme` quando necessário).
- `useMaterial3` não foi definido explicitamente — padrão `true` desde Flutter 3.16.

### Passo 2 — Aplicar tema no MaterialApp

Em `lib/main.dart`, importar e aplicar o tema:

```dart
import 'theme/app_theme.dart';

// No MaterialApp (remover const do MaterialApp):
MaterialApp(
  theme: AppTheme.theme,
  home: LoginScreen(),
);
```

### Passo 3 — Validar

- Rodar `flutter analyze` — apenas infos pré-existentes nos testes (unnecessary_underscores)
- Rodar `flutter test` — 15/15 testes passando
- Verificar visualmente que AppBar, botão, checkbox e borda dos inputs usam `#028687`

---

## Critérios de aceite

- [x] Arquivo `lib/theme/app_theme.dart` criado com cor primária `#028687` e `textColor` reservado
- [x] `MaterialApp` usa o tema definido
- [x] AppBar, ElevatedButton, Checkbox e input focus border usam a cor `#028687`
- [ ] Textos do app usam a cor `#414F56` — pendente (aplicação do `textTheme` adiada)
- [x] Sem cores hardcoded desnecessárias nos componentes
- [x] `flutter analyze` sem erros novos
- [x] `flutter test` sem falhas (15/15)

---

## Links relacionados

- [[DevLog/]]
- [[Decisoes/]]
