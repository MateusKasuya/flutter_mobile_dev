---
tags: [tipo/devlog, dominio/frota]
date: 2026-03-13
---

# Dev Log — 13/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-frota-veiculo-card|Card de dados do veículo]]

## O que foi feito

- Substituído o placeholder de `FrotaDetalheScreen` pelo card completo com dados do veículo
- Card com header colorido (primary) exibindo placa e número de frota
- Linhas de informação (marca, modelo, ano/anoModelo, cor, tipo) via widget `_InfoRow`
- Body em `ListView` para suportar scroll quando a tela receber mais conteúdo (pneus)

## Decisões tomadas

Nenhuma decisão de arquitetura nova — segue os padrões já estabelecidos.

## Problemas encontrados

Campo `anoModelo` vinha `null` da API para alguns veículos, resultando em `"1967/"` na tela. Corrigido exibindo só `veiculo.ano` quando `anoModelo` estiver vazio.

## Aprendizados

Nenhum conceito novo.

## Próximos passos

- [[Tasks/2026-03-05-frota-pneus-lista|Lista de pneus do veículo]]
