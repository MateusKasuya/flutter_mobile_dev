---
tags: [tipo/devlog, dominio/frota]
date: 2026-03-06
---

# Dev Log — 06/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-frota-models|Models Veiculo e Pneu]]

## O que foi feito

- Criado `lib/models/pneu.dart` com 27 campos mapeados do JSON da API, constructor `const` e factory `fromJson`
- Criado `lib/models/veiculo.dart` com dados do veículo + `List<Pneu> pneus`, factory `fromJson` com deserialização do array
- `flutter analyze` sem erros

## Decisões tomadas

- Todos os campos mantidos como `String` mesmo os numéricos (ex: `KMRODADO`), pois a API retorna tudo como string — conversão feita no ponto de uso quando necessário

## Problemas encontrados

- Nenhum

## Aprendizados

- Nenhum novo

## Próximos passos

- [[Tasks/2026-03-05-frota-service|Service de frota]]
