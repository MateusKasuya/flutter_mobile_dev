---
tags: [devlog]
date: 2026-03-02
task: "[[Tasks/2026-03-02-localizacao-service]]"
---

# Dev Log — Modelo e serviço de localizações de pneus

[[Home]]

---

## O que foi feito

Criados o modelo de dados e o serviço HTTP para o endpoint de localizações de pneus.

### Arquivos criados

- `lib/models/localizacao.dart` — classe `Localizacao` com campos `nome` e `quantidade`, e factory `fromJson`
- `lib/services/localizacao_service.dart` — função `fetchLocalizacoes(String token)` que faz GET autenticado em `api/frota/pneu/qlocalizacaopneus`

## Decisões

- Seguiu o mesmo padrão do `auth_service.dart`: mesma `_baseUrl`, mesma convenção de lançar `Exception` em caso de erro HTTP
- Campos do modelo mapeados de `QTLOCALIZACAO` → `quantidade` e `LOCALIZACAO` → `nome` (nomes em português snake_case conforme padrão Dart)

## Próximo passo

[[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView de localizações]]
