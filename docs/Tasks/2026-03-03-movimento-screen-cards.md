---
tags: [task]
date: 2026-03-03
status: concluída
branch: feat/movimento-screen-cards
---

# Task — Tela Movimento com cards de navegação

[[Home]]

---

## Contexto

A `MovimentoScreen` foi criada como placeholder na task [[Tasks/2026-03-02-home-fab-movimento|FAB Movimento]]. Agora é necessário substituir o conteúdo placeholder por cards que representam os módulos de movimento: **Frotas**, **Pneu** e **Abastecimento**. O usuário já implementou a maior parte do layout — esta task documenta o que foi feito e registra os ajustes finais necessários.

## Objetivo

`MovimentoScreen` exibindo uma lista vertical de cards estilizados (barra lateral colorida, ícone, label e seta) para Frotas, Pneu e Abastecimento, com `onTap` preparado para navegação futura.

---

## Branch

```bash
git checkout -b feat/movimento-screen-cards
```

## Arquivos a criar

- *(nenhum)*

## Arquivos a modificar

- `lib/screens/movimento_screen.dart` — substituir placeholder por ListView com cards

---

## Implementação

> A maior parte já foi implementada pelo usuário. Os passos abaixo cobrem o estado final desejado, incluindo os ajustes pendentes.

---

### Passo 1 — Corrigir padding duplo no body

O código atual tem dois paddings sobrepostos: `Padding(EdgeInsets.all(16))` envolvendo um `ListView(padding: EdgeInsets.all(8))`, totalizando 24px. Simplificar para um só.

**Antes:**
```dart
body: Padding(
  padding: const EdgeInsets.all(16),
  child: ListView(
    padding: const EdgeInsets.all(8),
    children: <Widget>[
```

**Depois:**
```dart
body: ListView(
  padding: const EdgeInsets.all(16),
  children: <Widget>[
```

Remover o `Padding` externo e manter apenas o `padding` do `ListView`. O `ListView` já aceita `padding` como parâmetro — usar o widget `Padding` por fora é redundante e adiciona espaço extra desnecessário.

**Fechar corretamente:** remover também o fechamento extra do `Padding` — o `)` correspondente ao `Padding(` e o `)` do `child:`.

---

### Passo 2 — Adicionar `onTap` ao `_MovimentoCard`

Adicionar um parâmetro `VoidCallback? onTap` ao `_MovimentoCard` para preparar a navegação futura.

**Atualizar a classe `_MovimentoCard`:**

```dart
class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(icon, size: 28, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**O que mudou e por quê:**

- **`VoidCallback? onTap`** — tipo `VoidCallback?` (nullable) permite que o card funcione sem callback por enquanto. `VoidCallback` é um alias do Dart para `void Function()` — uma função sem parâmetros e sem retorno. O `?` torna o parâmetro opcional.

- **`InkWell` envolvendo o conteúdo** — `InkWell` é o widget do Material Design que adiciona o efeito visual de "ripple" (ondulação) ao toque e recebe o `onTap`. Diferente do `GestureDetector` (que só detecta gestos sem feedback visual), o `InkWell` segue as guidelines do Material e dá feedback tátil ao usuário.

- **`borderRadius: BorderRadius.circular(12)` no `InkWell`** — necessário para que o ripple respeite os cantos arredondados do `Card`. Sem isso, o efeito de toque vaza além das bordas arredondadas formando um retângulo.

---

### Passo 3 — Adicionar subtítulo a cada card

Cada card deve exibir um subtítulo descritivo abaixo do label principal.

**Atualizar `_MovimentoCard` para aceitar `subtitle`:**

```dart
class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
```

**Substituir o `Text` do label por uma `Column` com título e subtítulo:**

```dart
Expanded(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  ),
),
```

**Atualizar as instâncias de `_MovimentoCard` com os subtítulos:**

```dart
_MovimentoCard(
  label: 'Frotas',
  subtitle: 'Movimentações de frota',
  icon: Icons.directions_car,
),
// ...
_MovimentoCard(
  label: 'Pneu',
  subtitle: 'Controle de pneus',
  icon: Icons.tire_repair,
),
// ...
_MovimentoCard(
  label: 'Abastecimento',
  subtitle: 'Registro de abastecimento',
  icon: Icons.local_gas_station,
),
```

**O que é novo e por quê:**

- **`Column` com `mainAxisAlignment: MainAxisAlignment.center`** — centraliza verticalmente os dois textos dentro da altura fixa de 100px do card. Sem isso, os textos ficam colados no topo.

- **`crossAxisAlignment: CrossAxisAlignment.start`** — alinha os textos à esquerda. O padrão do `Column` é `center` (centralizado horizontalmente), o que ficaria estranho numa lista.

- **`colorScheme.onSurfaceVariant`** — cor semântica do Material Design para texto secundário sobre superfícies. Automaticamente mais clara que `onSurface` (usada para texto principal), criando hierarquia visual sem precisar hardcodar um valor como `Colors.grey`.

- **`SizedBox(height: 2)`** — espaçamento mínimo entre título e subtítulo. Suficiente para separar visualmente sem afastar demais.

---

### Estado final do arquivo completo

Após os três passos, o `lib/screens/movimento_screen.dart` deve ficar assim:

```dart
import 'package:flutter/material.dart';

class MovimentoScreen extends StatelessWidget {
  const MovimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _MovimentoCard(
            label: 'Frotas',
            subtitle: 'Movimentações de frota',
            icon: Icons.directions_car,
          ),
          const SizedBox(height: 16),
          _MovimentoCard(
            label: 'Pneu',
            subtitle: 'Controle de pneus',
            icon: Icons.tire_repair,
          ),
          const SizedBox(height: 16),
          _MovimentoCard(
            label: 'Abastecimento',
            subtitle: 'Registro de abastecimento',
            icon: Icons.local_gas_station,
          ),
        ],
      ),
    );
  }
}

class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(icon, size: 28, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Critérios de aceite

- [x] `MovimentoScreen` exibe 3 cards: Frotas, Pneu, Abastecimento
- [x] Cada card tem barra lateral colorida, ícone, label e seta
- [x] Padding único de 16px no `ListView` (sem `Padding` externo duplicado)
- [x] `_MovimentoCard` aceita `VoidCallback? onTap` opcional
- [x] Cards envolvidos em `InkWell` com ripple respeitando `borderRadius`
- [ ] Cada card exibe subtítulo abaixo do label com `colorScheme.onSurfaceVariant`
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-home-fab-movimento|FAB Movimento na Home]]
- [[DevLog/]]
