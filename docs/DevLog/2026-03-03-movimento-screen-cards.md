---
tags: [devlog]
date: 2026-03-03
task: "[[Tasks/2026-03-03-movimento-screen-cards]]"
---

# Dev Log — Tela Movimento com cards de navegação

[[Home]]

---

## O que foi feito

Substituído o placeholder da `MovimentoScreen` por uma lista de cards estilizados com barra lateral colorida, ícone, label e seta. Aplicados dois ajustes de qualidade: correção de padding duplo e adição de `onTap` com `InkWell` para feedback visual.

### Arquivos criados

- *(nenhum)*

### Arquivos modificados

- `lib/screens/movimento_screen.dart` — layout com `_MovimentoCard`, correção de padding e `InkWell`

### Detalhes

- Padding unificado em `ListView(padding: EdgeInsets.all(16))` — removido `Padding` externo redundante
- `_MovimentoCard` recebe `VoidCallback? onTap` opcional — preparado para navegação futura sem quebrar o estado atual
- `InkWell` com `borderRadius` correspondente ao do `Card` para ripple respeitando os cantos arredondados
