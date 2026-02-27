---
tags: [dev-log]
date: 2026-02-27
---

# Dev Log — 27/02/2026

[[Home]]

---

## Task

[[Tasks/2026-02-26-login-loading-screen|Tela de loading durante chamada da API de login]]

## O que foi feito

- `build` passou a retornar um `Stack` em vez do `Scaffold` diretamente
- `Scaffold` virou o primeiro filho do `Stack`
- Overlay de loading adicionado como segundo filho do `Stack`, cobrindo a tela inteira incluindo AppBar
- Overlay contém `CircularProgressIndicator` branco, texto "Realizando login..." e "Aguarde enquanto autenticamos"
- `CircularProgressIndicator` removido do interior do `ElevatedButton` — botão exibe apenas texto "Entrar" e fica desabilitado durante loading

## Decisões tomadas

- **`Stack` envolve o `Scaffold` inteiro** — colocar o overlay dentro do `body` do `Scaffold` não cobria a AppBar. Envolver o `Scaffold` garante cobertura total.
- **`Material(type: MaterialType.transparency)`** — sem esse wrapper, `Text` widgets dentro do overlay (fora da árvore do `Scaffold`) recebem o `DefaultTextStyle` padrão do Flutter (amarelo sublinhado). O `Material` com transparência fornece o contexto de tipografia correto sem adicionar cor ou elevação visível.
- **`alpha: 0.8`** — opacidade mais alta para dar destaque ao overlay e evidenciar que a tela está bloqueada.

## Problemas encontrados

- **Textos amarelos sublinhados no overlay**: causado por `Text` fora da árvore do `Scaffold`. Resolvido com `Material(type: MaterialType.transparency)` envolvendo o `Container` do overlay.

## Aprendizados

- Widgets `Text` fora do contexto de um `Scaffold` ou `Material` herdam o `DefaultTextStyle` do Flutter, que é amarelo sublinhado. Sempre que um widget flutuar fora do `Scaffold` (ex: overlay em `Stack` acima do `Scaffold`), envolver com `Material(type: MaterialType.transparency)` para herdar o tema corretamente.

## Próximos passos

- Tasks pendentes: logo SVG, modularização do login
