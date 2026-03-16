---
tags: [tipo/devlog, dominio/frota]
date: 2026-03-16
---

# Dev Log — 16/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-frota-tests|Testes do módulo Frota]]

## O que foi feito

- Criados testes unitários para `Pneu.fromJson` e `Veiculo.fromJson` em `test/models/`
- Criados testes do `fetchVeiculo` cobrindo status 200, 404 e 422 com `MockClient`
- Criados testes de widget da `FrotaBuscaScreen`: campo de placa, validação, busca com sucesso, erro
- Criados testes de widget da `FrotaDetalheScreen`: dados do veículo, pneu renderizado, veículo sem pneus
- 13 testes passando, `flutter analyze` sem erros

## Decisões tomadas

Os testes da `FrotaBuscaScreen` precisam envolver a tela com `ChangeNotifierProvider<AuthProvider>`, pois a screen usa `context.read<AuthProvider>().token` internamente. Criado helper `_wrap()` para reutilizar nos 4 testes da screen.

## Problemas encontrados

A task planejada usava `token: 'tok'` como parâmetro direto da screen, mas a implementação real usa `AuthProvider` via Provider. Ajustado o helper de teste para refletir o código real.

## Aprendizados

Nenhum conceito novo.

## Próximos passos

- Módulo Frota completo ✅
