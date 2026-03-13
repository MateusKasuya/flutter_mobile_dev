---
tags: [tipo/task, dominio/home]
date: 2026-03-02
status: planejada
branch: feat/home-fab-movimento
---

# Task — FloatingActionButton Movimento na Home Screen

[[Tasks/_index|Tasks]]

---

## Contexto

A Home Screen precisa de um ponto de acesso para a funcionalidade de Movimento de pneus. Um `FloatingActionButton` com label "Movimento" será adicionado à Home, navegando para uma tela placeholder que será implementada posteriormente.

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

- `lib/screens/home_screen.dart` — adicionar `floatingActionButton` ao Scaffold

---

## Implementação

> **Pré-requisito:** Tasks [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]] e [[Tasks/2026-03-02-home-grid-estilizacao|Estilização dos cards]] concluídas.

---

### Passo 1 — Criar a tela placeholder `MovimentoScreen`

Criar o arquivo `lib/screens/movimento_screen.dart` com o conteúdo abaixo:

```dart
import 'package:flutter/material.dart';

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

**Por que `StatelessWidget` aqui?**

A tela é apenas um placeholder — exibe texto fixo, sem estado mutável. Sempre que uma tela não precisa gerenciar dados que mudam (loading, listas, formulários), `StatelessWidget` é a escolha certa. Mais simples, menos código.

**Por que `Center` com `Text`?**

É o mínimo necessário para uma tela funcional e reconhecível. O `Center` centraliza o filho tanto horizontal quanto verticalmente na área disponível do `body`. O `Text('Em construção')` sinaliza que a funcionalidade existe mas ainda não foi implementada. Essa abordagem é comum no desenvolvimento iterativo — cria-se a navegação antes de desenvolver o conteúdo real.

---

### Passo 2 — Adicionar o FAB ao Scaffold da Home Screen

Em `lib/screens/home_screen.dart`, adicionar o parâmetro `floatingActionButton` ao `Scaffold` existente:

```dart
return Scaffold(
  appBar: AppBar(),
  body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          // ... (sem alteração)
        ),
  floatingActionButton: Transform.scale(
    scale: 1.2,
    child: FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MovimentoScreen()),
        );
      },
      icon: const Icon(Icons.swap_horiz),
      label: const Text('Movimento'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
);
```

Lembre de adicionar o import no topo do arquivo:

```dart
import 'movimento_screen.dart';
```

---

### Explicação linha a linha

**`floatingActionButton:` no Scaffold**

O `Scaffold` tem um slot dedicado para o FAB: o parâmetro `floatingActionButton`. Ao usar esse parâmetro, o Flutter automaticamente posiciona o botão no canto inferior direito da tela (comportamento padrão do Material Design) e garante que ele não seja sobreposto pela barra de navegação do sistema. Não é necessário posicionar manualmente com `Stack` ou `Positioned`.

---

**`FloatingActionButton.extended`**

O Flutter oferece três variantes do FAB:
- `FloatingActionButton(...)` — botão redondo, só ícone
- `FloatingActionButton.small(...)` — versão menor, só ícone
- `FloatingActionButton.extended(...)` — versão alongada com ícone **e** texto

Usamos `.extended` porque queremos que o texto "Movimento" apareça visível ao lado do ícone, deixando a ação mais clara para o usuário.

---

**`onPressed: () { Navigator.push(...) }`**

`onPressed` recebe uma função anônima (`() { ... }`) que será executada quando o usuário tocar no botão.

Dentro dessa função, `Navigator.push` empurra uma nova tela para a pilha de navegação. A analogia é uma pilha de cartas: `push` coloca uma carta no topo, e ao pressionar voltar, o Flutter faz `pop` (retira a carta do topo), voltando à tela anterior — a Home.

A diferença para o `Navigator.pushReplacement` usado no login é importante: `pushReplacement` substitui a tela atual (sem possibilidade de voltar), enquanto `push` empilha (mantém a Home acessível pelo botão de voltar).

---

**`MaterialPageRoute(builder: (_) => const MovimentoScreen())`**

`MaterialPageRoute` define como a transição entre telas vai acontecer. No Android, aplica a animação padrão do Material Design (slide de baixo para cima). No iOS, aplica o slide da direita para a esquerda.

O `builder: (_) => const MovimentoScreen()` é uma função que recebe o `BuildContext` (que não precisamos usar, então chamamos de `_`) e retorna a tela de destino.

---

**`Transform.scale(scale: 1.2, child: ...)`**

`Transform.scale` aplica uma transformação de escala no widget filho — `scale: 1.2` o deixa 20% maior que o tamanho original. É diferente de alterar o `width`/`height` diretamente: o `Transform` opera após o layout, então o espaço ocupado pelo widget no layout continua sendo o tamanho original. Para o FAB isso funciona bem, pois ele flutua sobre a tela e não interfere no posicionamento de outros widgets.

---

**`backgroundColor` e `foregroundColor`**

Por padrão, o FAB já usa a cor primária do tema. Definir explicitamente `backgroundColor: Theme.of(context).colorScheme.primary` e `foregroundColor: Colors.white` garante que as cores não mudem caso o tema seja alterado no futuro — e documenta a intenção visual de forma clara no código.

---

**`floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat`**

O `Scaffold` tem um parâmetro separado `floatingActionButtonLocation` que controla onde o FAB é posicionado. O valor padrão é `endFloat` (canto inferior direito). `centerFloat` centraliza horizontalmente na base da tela, flutuando acima da barra de navegação. Funciona bem com FABs `.extended` que têm texto, pois ficam mais visíveis no centro.

---

**`Icons.swap_horiz`**

Ícone de duas setas horizontais opostas, que representa troca/movimentação. Semanticamente mais preciso para "Movimento de pneus" do que `Icons.add` (que sugere criação) ou `Icons.arrow_forward` (que sugere navegação unidirecional).

---

## Critérios de aceite

- [ ] `MovimentoScreen` criada em `lib/screens/movimento_screen.dart`
- [ ] FAB "Movimento" visível centralizado na base da Home Screen
- [ ] FAB ampliado com `Transform.scale(1.2)`
- [ ] Ícone `swap_horiz` visível no FAB
- [ ] Ao tocar no FAB, navega para `MovimentoScreen` com animação
- [ ] `MovimentoScreen` exibe AppBar com título "Movimento"
- [ ] Botão de voltar retorna à Home Screen
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]]
- [[Tasks/2026-03-02-home-grid-estilizacao|Estilização dos cards]]
- [[DevLog/]]
