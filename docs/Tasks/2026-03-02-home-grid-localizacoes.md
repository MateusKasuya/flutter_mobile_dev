---
tags: [task]
date: 2026-03-02
status: planejada
branch: feat/home-grid-localizacoes
---

# Task — Home Screen com GridView de localizações

[[Home]]

---

## Contexto

Após o login, o app exibe uma Home Screen placeholder que apenas mostra o token. Precisamos transformá-la numa tela funcional que consome o serviço de localizações e exibe a distribuição de pneus num grid 2x2.

## Objetivo

Home Screen que carrega dados do serviço de localizações e exibe 4 cards em GridView 2x2 com nome e quantidade.

---

## Branch

```bash
git checkout -b feat/home-grid-localizacoes
```

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `lib/screens/home_screen.dart` — reescrever completamente

---

## Implementação

> **Pré-requisito:** Task [[Tasks/2026-03-02-localizacao-service|Modelo e serviço de localizações]] concluída.

### Passo 1 — Reescrever `HomeScreen` como StatefulWidget

Modificar `lib/screens/home_screen.dart`:

- Converter de `StatelessWidget` para `StatefulWidget`
- Manter o parâmetro `token` (recebido do login)
- No `initState`, chamar `fetchLocalizacoes(token)` e armazenar resultado no state
- Gerenciar estados: `_isLoading`, `_localizacoes`, `_hasError`

### Passo 2 — Implementar o GridView 2x2

No body do Scaffold:

- Enquanto `_isLoading`, exibir `CircularProgressIndicator` centralizado
- Quando carregado, exibir `GridView.count` com:
  - `crossAxisCount: 2`
  - `crossAxisSpacing` e `mainAxisSpacing` adequados
  - Cada item é um `Card` com estilo uniforme contendo:
    - Nome da localização (`LOCALIZACAO`) — texto principal
    - Quantidade (`QTLOCALIZACAO`) — número em destaque
- Em caso de erro, exibir mensagem com `showErrorToast` (de `lib/utils/app_toast.dart`)

### Passo 3 — Manter AppBar

- AppBar com título "Início" (já existente)

---

## Critérios de aceite

- [ ] Home Screen carrega dados do endpoint ao abrir
- [ ] Exibe loading enquanto busca dados
- [ ] GridView 2x2 exibe os 4 cards com nome e quantidade
- [ ] Cards com estilo uniforme
- [ ] Tratamento de erro com toast em caso de falha na API
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-localizacao-service|Modelo e serviço de localizações]]
- [[DevLog/]]
- [[Decisoes/]]
