---
tags: [tipo/devlog, dominio/home]
date: 2026-03-02
task: "[[Tasks/2026-03-02-home-fab-movimento]]"
---

# Dev Log — FAB Movimento e tela placeholder

[[DevLog/_index|DevLog]]

---

## O que foi feito

Adicionado `FloatingActionButton.extended` à Home Screen com navegação para tela placeholder `MovimentoScreen`.

### Arquivos modificados

- `lib/screens/home_screen.dart` — FAB adicionado ao Scaffold

### Arquivos criados

- `lib/screens/movimento_screen.dart` — tela placeholder

### Detalhes

- FAB centralizado na base com `floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat`
- `Transform.scale(1.2)` para ampliar o botão
- `backgroundColor: primary`, `foregroundColor: Colors.white` explícitos
- Ícone `Icons.swap_horiz`
- Navegação com `Navigator.push` + `MaterialPageRoute`

## Próximo passo

[[Tasks/2026-03-02-home-tests|Testes da Home Screen (service, GridView e FAB)]]
