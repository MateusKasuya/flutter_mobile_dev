---
tags: [tipo/devlog, dominio/splash]
date: 2026-03-07
---

# Dev Log — 07/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-splash-screen|Splash Screen]]

## O que foi feito

- Criado `lib/screens/splash_screen.dart` com gradiente `#01556F → #028480`, logo branca centralizada e texto "por transportefacil.com.br" (fontSize 10)
- `main.dart` atualizado para abrir na `SplashScreen` em vez de `LoginScreen`
- Após 2 segundos, `Navigator.pushReplacement` navega para `LoginScreen`
- `flutter analyze` sem erros

## Decisões tomadas

- Nenhuma nova

## Problemas encontrados

- Nenhum

## Aprendizados

- Nenhum novo

## Próximos passos

- [[Tasks/2026-03-05-estilizacao-login|Estilização do Login]]
