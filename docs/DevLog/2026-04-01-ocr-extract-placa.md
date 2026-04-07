---
tags: [tipo/devlog, dominio/frota]
date: 2026-04-01
---

# Dev Log — 01/04/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-16-ocr-extract-placa|Extração inteligente de placa do OCR]]

## O que foi feito

- Criado `lib/utils/placa_utils.dart` com o helper `extractPlaca`
- `extractPlaca` quebra o texto bruto do OCR em tokens, remove caracteres especiais e valida cada token contra os dois formatos de placa brasileira (antigo `ABC1234` e Mercosul `ABC1D23`)
- Integrado `extractPlaca` em `FrotaBuscaScreen._scanPlaca`, substituindo a concatenação ingênua anterior
- Adicionado toast de erro quando o OCR não encontra nenhuma placa válida na foto

## Decisões tomadas

- Regex compilados como variáveis top-level `final` para evitar recompilação a cada chamada
- Verificação do formato Mercosul antes do antigo (preferência ao formato mais moderno)
- Retorno `null` em vez de string vazia para forçar o chamador a tratar o caso de falha explicitamente

## Problemas encontrados

Nenhum.

## Aprendizados

Nenhum novo.

## Próximos passos

- [[Tasks/2026-03-16-ocr-extract-placa-tests|Testes do extractPlaca]]
