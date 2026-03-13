---
tags: [tipo/task, dominio/infra]
date: 2026-03-09
status: concluída
branch: feat/modularizacao-codigo
---

# Task — Modularização do código

[[Tasks/_index|Tasks]]

---

## Contexto

Após a estilização do login e a evolução das telas, várias duplicações de código surgiram: URL da API repetida em 3 services, estilos de borda idênticos em CpfField e PasswordField, estilos de texto Montserrat espalhados por 5 arquivos, e cores hardcoded que deveriam vir do tema. Esta task centraliza esses padrões para facilitar manutenção e evitar inconsistências.

## Objetivo

Extrair constantes e padrões duplicados para arquivos centralizados, sem alterar nenhum comportamento visual ou funcional.

---

## Branch

```bash
git checkout -b feat/modularizacao-codigo
```

## Arquivos a criar

- `lib/config/api_config.dart` — URL base da API
- `lib/theme/app_colors.dart` — cores do projeto centralizadas
- `lib/theme/app_text_styles.dart` — estilos de texto Montserrat reutilizáveis
- `lib/components/app_input_decoration.dart` — decoração padrão dos inputs

## Arquivos a modificar

- `lib/services/auth_service.dart` — usar `api_config`
- `lib/services/frota_service.dart` — usar `api_config`
- `lib/services/localizacao_service.dart` — usar `api_config`
- `lib/components/cpf_field.dart` — usar `app_input_decoration` e `app_text_styles`
- `lib/components/password_field.dart` — usar `app_input_decoration` e `app_text_styles`
- `lib/components/remember_me_checkbox.dart` — usar `app_text_styles`
- `lib/screens/login_screen.dart` — usar `app_text_styles` e `app_colors`
- `lib/theme/app_theme.dart` — integrar `app_colors`

---

## Implementação

### Passo 1 — Centralizar URL base da API

Criar `lib/config/api_config.dart`:

```dart
/// Configuração centralizada da API.
/// Trocar para o endereço de produção quando necessário.
const String apiBaseUrl = 'fretefacilweb.ccmcloud.com.br:8624';
```

Em cada service (`auth_service.dart`, `frota_service.dart`, `localizacao_service.dart`):
- Remover a linha `const String _baseUrl = 'fretefacilweb.ccmcloud.com.br:8624';`
- Adicionar `import '../config/api_config.dart';`
- Substituir `_baseUrl` por `apiBaseUrl`

**Por que:** Atualmente a URL está duplicada em 3 arquivos. Se mudar o servidor (produção, staging, testes), precisaria editar 3 lugares. Com a centralização, muda em 1 lugar só.

---

### Passo 2 — Centralizar cores do projeto

Criar `lib/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

/// Cores centralizadas do projeto.
/// Referência: Figma do Frota Fácil.
class AppColors {
  // Primária (teal)
  static const Color primary = Color(0xFF006F70);
  static const Color primaryBorder = Color(0xFF028687);

  // Texto
  static const Color textDark = Color(0xFF003156);
  static const Color textMuted = Color(0xFF5F5F5F);
  static const Color textHint = Color(0xFFC4C4C4);

  // Gradiente do login
  static const Color gradientStart = Color(0xFFCEFCF1);
  static const Color gradientEnd = Color(0xFFFFFFFF);
}
```

Atualizar `lib/theme/app_theme.dart` para usar `AppColors.primary`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primary);
    return ThemeData(colorScheme: colorScheme);
  }
}
```

**Por que:** Cores como `0xFF028687`, `0xFF5F5F5F`, `0xFFC4C4C4` aparecem hardcoded em vários arquivos. Se a identidade visual mudar, precisa caçar cada ocorrência. Com `AppColors`, muda num lugar só.

---

### Passo 3 — Centralizar estilos de texto

Criar `lib/theme/app_text_styles.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto Montserrat reutilizáveis.
/// Nomes baseados no uso, não no tamanho.
class AppTextStyles {
  static TextStyle heading = GoogleFonts.montserrat(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textDark,
  );

  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: Colors.white,
  );

  static TextStyle label = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textMuted,
  );

  static TextStyle inputHint = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textHint,
  );

  static TextStyle checkboxLabel = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textMuted,
  );

  static TextStyle footer = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.textMuted,
  );
}
```

Nos arquivos que usam `GoogleFonts.montserrat(...)`:
- Adicionar `import '../theme/app_text_styles.dart';`
- Substituir o bloco `GoogleFonts.montserrat(...)` por `AppTextStyles.heading`, `.label`, etc.
- Remover `import 'package:google_fonts/google_fonts.dart';` dos arquivos que não precisarem mais

**Por que:** O mesmo estilo Montserrat está repetido em 5+ arquivos com fontSize, fontWeight, color escritos na mão. Se a fonte mudar (ex: Inter), precisaria editar todos. Centralizando, troca em 1 arquivo.

---

### Passo 4 — Centralizar decoração dos inputs

Criar `lib/components/app_input_decoration.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Decoração padrão para campos de entrada (CpfField, PasswordField, etc.).
InputDecoration appInputDecoration({
  required String hintText,
  Widget? suffixIcon,
}) {
  const borderRadius = BorderRadius.all(Radius.circular(10));
  const border = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(width: 2, color: AppColors.primaryBorder),
  );

  return InputDecoration(
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    hintText: hintText,
    hintStyle: AppTextStyles.inputHint,
    suffixIcon: suffixIcon,
  );
}
```

Em `cpf_field.dart`:
```dart
import 'app_input_decoration.dart';

// Substituir todo o bloco de borderRadius + border + InputDecoration por:
decoration: appInputDecoration(hintText: '000.000.000-00'),
```

Em `password_field.dart`:
```dart
import 'app_input_decoration.dart';

// Substituir por:
decoration: appInputDecoration(
  hintText: 'Digite a senha',
  suffixIcon: IconButton(
    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
    color: AppColors.primaryBorder,
    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
  ),
),
```

**Por que:** CpfField e PasswordField têm 10 linhas idênticas de definição de borda (borderRadius, borderSide, 3 estados de border). Mudança de cor ou raio requer edição em 2 arquivos. Com a função centralizada, muda em 1.

---

### Passo 5 — Aplicar nos arquivos existentes

Substituir todas as referências hardcoded nos seguintes arquivos:

**`login_screen.dart`:**
- `Color(0xFF003156)` → `AppColors.textDark`
- `Color(0xFFCEFCF1)` → `AppColors.gradientStart`
- `Color(0xFFFFFFFF)` → `AppColors.gradientEnd`
- `Color(0xFF5F5F5F)` → `AppColors.textMuted`
- Blocos `GoogleFonts.montserrat(...)` → `AppTextStyles.heading`, `.label`, `.button`, `.footer`

**`remember_me_checkbox.dart`:**
- Bloco `GoogleFonts.montserrat(...)` → `AppTextStyles.checkboxLabel`

**`cpf_field.dart` e `password_field.dart`:**
- Bloco de border + InputDecoration → `appInputDecoration(...)`

---

### Passo 6 — Verificação

```bash
flutter analyze
flutter test
```

Garantir que nenhum comportamento visual ou funcional mudou.

---

## Critérios de aceite

- [ ] URL da API definida em 1 lugar só (`lib/config/api_config.dart`)
- [ ] Cores em `AppColors`, não hardcoded nos widgets
- [ ] Estilos de texto em `AppTextStyles`, não repetidos nos widgets
- [ ] Borda dos inputs em `appInputDecoration()`, não repetida
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` — todos os testes passando
- [ ] Visual da tela de login idêntico ao antes da refatoração

---

## Links relacionados

- [[Tasks/2026-03-05-estilizacao-login|Estilização do Login]]
- [[DevLog/]]
