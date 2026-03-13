---
tags: [tipo/devlog, dominio/infra]
date: 2026-03-09
---

# Dev Log — 09/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-09-modularizacao-codigo|Modularização do código]]

## O que foi feito

- Criado `lib/config/api_config.dart` com `apiBaseUrl` — URL base removida dos 3 services
- Criado `lib/theme/app_colors.dart` com `AppColors` (primary, primaryBorder, textDark, textMuted, textHint, gradientStart, gradientEnd)
- Criado `lib/theme/app_text_styles.dart` com `AppTextStyles` (heading, button, label, inputHint, checkboxLabel, footer) usando Montserrat via google_fonts
- Criado `lib/components/app_input_decoration.dart` com função `appInputDecoration()` — borda duplicada de CpfField e PasswordField centralizada
- `app_theme.dart` atualizado para usar `AppColors.primary`
- `auth_service`, `frota_service`, `localizacao_service` atualizados para usar `apiBaseUrl`
- `cpf_field.dart` e `password_field.dart` refatorados para usar `appInputDecoration()` e `AppTextStyles`
- `remember_me_checkbox.dart` atualizado para usar `AppTextStyles.checkboxLabel`
- `login_screen.dart` atualizado para usar `AppColors` e `AppTextStyles` — removido `google_fonts` direto
- Teste `checkbox lembrar usuário e senha está presente` atualizado: `CheckboxListTile` → `Checkbox` (componente foi substituído em sessão anterior)
- `flutter analyze`: sem erros — `flutter test`: 26 testes passando

## Decisões tomadas

- Cores, tipografia e URL centralizadas em arquivos de tema/config para facilitar manutenção
- `appInputDecoration()` como função (não classe) por ser stateless e simples

## Problemas encontrados

- Teste buscava `CheckboxListTile` que foi substituído por `Checkbox` + `Row` em sessão anterior — corrigido

## Aprendizados

- Nenhum novo

## Próximos passos

- [[Tasks/2026-03-05-estilizacao-home|Estilização da Home]]
