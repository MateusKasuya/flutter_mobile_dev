---
tags: [dev-log]
date: 2026-03-06
---

# Dev Log — 06/03/2026

[[Home]]

---

## Task

[[Tasks/2026-03-05-frota-service|Service de frota]]

## O que foi feito

- Criado `lib/services/frota_service.dart` com função `fetchVeiculo(token, placa, {client})`
- Segue o mesmo padrão de injeção de dependência do `localizacao_service.dart`
- Tratamento específico para 404 (veículo não encontrado) e erros genéricos da API
- `flutter analyze` sem erros

## Decisões tomadas

- `Uri.http` com query params em vez de concatenação de string — encoding automático e mais seguro
- Flag `createdClient` para fechar o client apenas quando criado internamente, evitando leak de conexões

## Problemas encontrados

- Nenhum

## Aprendizados

- Nenhum novo

## Próximos passos

- [[Tasks/2026-03-05-frota-busca-placa|Tela de busca de veículo por placa]]
