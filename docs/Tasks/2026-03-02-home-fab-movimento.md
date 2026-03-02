---
tags: [task]
date: 2026-03-02
status: planejada
branch: feat/home-fab-movimento
---

# Task — FloatingActionButton Movimento na Home Screen

[[Home]]

---

## Contexto

A Home Screen precisa de um ponto de acesso para a funcionalidade de Movimento de pneus. Um FloatingActionButton com label "Movimento" será adicionado à Home, navegando para uma tela placeholder que será implementada posteriormente.

## Objetivo

FAB "Movimento" na Home Screen que navega para uma tela placeholder `MovimentoScreen`.

---

## Branch

```bash
git checkout -b feat/home-fab-movimento
```

## Arquivos a criar

- `lib/screens/movimento_screen.dart` — tela placeholder para navegação futura

## Arquivos a modificar

- `lib/screens/home_screen.dart` — adicionar FloatingActionButton ao Scaffold

---

## Implementação

> **Pré-requisito:** Task [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]] concluída.

### Passo 1 — Criar tela placeholder `MovimentoScreen`

Criar `lib/screens/movimento_screen.dart`:

```dart
class MovimentoScreen extends StatelessWidget {
  const MovimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimento')),
      body: const Center(child: Text('Em construção')),
    );
  }
}
```

### Passo 2 — Adicionar FAB à Home Screen

No Scaffold de `home_screen.dart`, adicionar:

- `FloatingActionButton.extended` com:
  - `label: Text('Movimento')`
  - `icon: Icon(Icons.add)` (ou ícone apropriado)
  - `onPressed` navega para `MovimentoScreen` com `Navigator.push`

---

## Critérios de aceite

- [ ] FAB "Movimento" visível na Home Screen
- [ ] Ao tocar no FAB, navega para `MovimentoScreen`
- [ ] `MovimentoScreen` exibe AppBar com título "Movimento"
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]]
- [[DevLog/]]
- [[Decisoes/]]
