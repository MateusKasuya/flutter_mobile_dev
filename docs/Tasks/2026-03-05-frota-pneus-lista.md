---
tags: [tipo/task, dominio/frota]
date: 2026-03-05
status: planejada
branch: feat/frota-pneus-lista
---

# Task — Lista de pneus do veiculo

[[Tasks/_index|Tasks]]

---

## Contexto

A `FrotaDetalheScreen` ja exibe o card do veiculo. Agora adicionamos a lista de pneus abaixo do card, mostrando as informacoes principais de cada pneu em cards individuais.

## Objetivo

`FrotaDetalheScreen` exibindo, abaixo do card do veiculo, uma secao "Pneus" com cards para cada pneu contendo: posicao (localEixo), marca/modelo, dimensao, situacao, km rodado e vida do pneu.

---

## Branch

```bash
git checkout -b feat/frota-pneus-lista
```

## Arquivos a criar

- *(nenhum)*

## Arquivos a modificar

- `lib/screens/frota_detalhe_screen.dart`

---

## Implementacao

### Passo 1 — Adicionar secao de pneus ao ListView

Modificar o `ListView` em `frota_detalhe_screen.dart` para incluir a lista de pneus apos o card do veiculo.

Adicionar no `children` do `ListView`, apos `_VeiculoCard(veiculo: veiculo)`:

```dart
const SizedBox(height: 24),
Row(
  children: [
    Icon(Icons.tire_repair, color: colorScheme.primary),
    const SizedBox(width: 8),
    Text(
      'Pneus (${veiculo.pneus.length})',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ),
  ],
),
const SizedBox(height: 12),
...veiculo.pneus.map((pneu) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PneuCard(pneu: pneu),
    )),
```

**Nota:** para usar `colorScheme` e `Theme.of(context)` no `build`, extrair antes do `return`:

```dart
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return Scaffold(
    // ...
```

**Explicacoes:**

- **`...veiculo.pneus.map()`** — o operador spread `...` "espalha" os elementos do `Iterable` retornado pelo `map` diretamente dentro da lista `children`. Sem o spread, estariamos tentando colocar um `Iterable<Widget>` como um unico item da lista, o que daria erro de tipo.

- **`'Pneus (${veiculo.pneus.length})'`** — string interpolation com `${}` para expressoes. Mostra o total de pneus como referencia visual ao usuario.

- **`Padding(padding: EdgeInsets.only(bottom: 12))`** — espacamento entre os cards de pneu. Usamos `EdgeInsets.only(bottom:)` em vez de `SizedBox(height:)` porque estamos dentro de um `map` e o `Padding` envolve cada card individualmente.

---

### Passo 2 — Criar widget _PneuCard

Adicionar ao final do arquivo `frota_detalhe_screen.dart`:

```dart
class _PneuCard extends StatelessWidget {
  final Pneu pneu;

  const _PneuCard({required this.pneu});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colorScheme.secondaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.tire_repair,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  pneu.localEixo,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pneu.situacao,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'Marca / Modelo', value: '${pneu.marca} ${pneu.modelo}'),
                _InfoRow(label: 'Dimensao', value: pneu.dimensao),
                _InfoRow(label: 'N Serie', value: pneu.nroSerie),
                _InfoRow(label: 'DOT', value: pneu.nroDot),
                _InfoRow(label: 'Km Rodado', value: pneu.kmRodado),
                _InfoRow(label: 'Vida', value: '${pneu.vidaPneu}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

Adicionar o import do model `Pneu` no topo do arquivo:

```dart
import '../models/pneu.dart';
```

**Explicacoes:**

- **`colorScheme.secondaryContainer`** — cor semantica para containers de destaque secundario. Diferente do `primary` usado no card do veiculo, cria hierarquia visual: veiculo (principal) vs pneu (secundario). O Material Design 3 define pares container/onContainer para garantir contraste.

- **`const Spacer()`** — widget que ocupa todo o espaco disponivel na `Row`. Empurra o badge de situacao para a direita enquanto o icone e posicao ficam na esquerda.

- **Badge de situacao** — um `Container` com `decoration` arredondada que funciona como chip/tag visual. Mostra a situacao do pneu ("Em uso", etc.) de forma destacada no header.

- **Reutilizacao do `_InfoRow`** — mesmo widget privado criado na task anterior para o card do veiculo. Como esta no mesmo arquivo, pode ser usado diretamente.

---

### Passo 3 — Estado final do arquivo completo

Apos os dois passos, o `lib/screens/frota_detalhe_screen.dart` deve ficar:

```dart
import 'package:flutter/material.dart';

import '../models/pneu.dart';
import '../models/veiculo.dart';

class FrotaDetalheScreen extends StatelessWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(veiculo.placa)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _VeiculoCard(veiculo: veiculo),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.tire_repair, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Pneus (${veiculo.pneus.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...veiculo.pneus.map((pneu) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PneuCard(pneu: pneu),
              )),
        ],
      ),
    );
  }
}

class _VeiculoCard extends StatelessWidget {
  final Veiculo veiculo;

  const _VeiculoCard({required this.veiculo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: colorScheme.primary,
            child: Row(
              children: [
                Icon(Icons.directions_car, color: colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text(
                  '${veiculo.placa} - Frota ${veiculo.nroFrota}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'Marca', value: veiculo.marca),
                _InfoRow(label: 'Modelo', value: veiculo.modelo),
                _InfoRow(label: 'Ano', value: '${veiculo.ano}/${veiculo.anoModelo}'),
                _InfoRow(label: 'Cor', value: veiculo.cor),
                _InfoRow(label: 'Tipo', value: veiculo.tipo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PneuCard extends StatelessWidget {
  final Pneu pneu;

  const _PneuCard({required this.pneu});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colorScheme.secondaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.tire_repair,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  pneu.localEixo,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pneu.situacao,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'Marca / Modelo', value: '${pneu.marca} ${pneu.modelo}'),
                _InfoRow(label: 'Dimensao', value: pneu.dimensao),
                _InfoRow(label: 'N Serie', value: pneu.nroSerie),
                _InfoRow(label: 'DOT', value: pneu.nroDot),
                _InfoRow(label: 'Km Rodado', value: pneu.kmRodado),
                _InfoRow(label: 'Vida', value: '${pneu.vidaPneu}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
```

---

## Criterios de aceite

- [ ] Secao "Pneus (N)" aparece abaixo do card do veiculo
- [ ] Cada pneu exibe card com header (posicao + situacao) e dados (marca/modelo, dimensao, serie, DOT, km, vida)
- [ ] Header do pneu usa `secondaryContainer` para diferenciar do header do veiculo
- [ ] Badge de situacao visivel no header
- [ ] Scroll funciona com veiculo + multiplos pneus
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-veiculo-card|Card de dados do veiculo]]
- [[Tasks/2026-03-05-frota-camera-ocr|Camera + OCR da placa]]
- [[DevLog/]]
