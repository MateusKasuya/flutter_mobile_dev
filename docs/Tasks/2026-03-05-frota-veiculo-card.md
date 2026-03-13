---
tags: [tipo/task, dominio/frota]
date: 2026-03-05
status: planejada
branch: feat/frota-veiculo-card
---

# Task — Card de dados do veiculo

[[Tasks/_index|Tasks]]

---

## Contexto

A `FrotaDetalheScreen` foi criada como placeholder na task anterior. Agora precisamos exibir os dados do veiculo retornado pela API em um card estilizado. Esta tela vai receber mais informacoes futuramente, entao organizamos o conteudo em um `ListView` para permitir scroll.

## Objetivo

`FrotaDetalheScreen` exibindo um card com os dados principais do veiculo: placa, frota, marca/modelo, ano, cor e tipo.

---

## Branch

```bash
git checkout -b feat/frota-veiculo-card
```

## Arquivos a criar

- *(nenhum)*

## Arquivos a modificar

- `lib/screens/frota_detalhe_screen.dart`

---

## Implementacao

### Passo 1 — Substituir placeholder pelo card do veiculo

Reescrever `lib/screens/frota_detalhe_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/veiculo.dart';

class FrotaDetalheScreen extends StatelessWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(veiculo.placa)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _VeiculoCard(veiculo: veiculo),
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

**Explicacoes:**

- **`ListView` no body** — mesmo que hoje tenha apenas um card, usamos `ListView` em vez de `Column` porque a tela vai receber mais conteudo futuramente (pneus, etc.). O `ListView` ja fornece scroll automatico quando o conteudo excede a tela.

- **`clipBehavior: Clip.antiAlias`** — faz o conteudo respeitar o `borderRadius` do card. Sem isso, o `Container` colorido do header vazaria alem das bordas arredondadas. `antiAlias` aplica suavizacao nas bordas recortadas para evitar serrilhado (pixels dentados).

- **`Container` como header** — um container com `color: colorScheme.primary` ocupa toda a largura do card e serve como cabecalho visual. O `width: double.infinity` garante que ocupe toda a largura disponivel.

- **`colorScheme.onPrimary`** — cor semantica do Material Design para texto/icones sobre `primary`. Se o primary for escuro, `onPrimary` sera claro, e vice-versa. Garante contraste e acessibilidade automaticamente.

- **`_InfoRow` como widget privado** — encapsula o padrao label/valor que se repete 5 vezes. O underscore `_` torna a classe privada ao arquivo (nao exportada). Reutilizavel dentro desta tela sem poluir o namespace global.

- **`MainAxisAlignment.spaceBetween`** — distribui os filhos da `Row` com o label na esquerda e o valor na direita, com todo o espaco sobrando entre eles. Cria o layout classico de "label: valor" alinhado.

---

## Criterios de aceite

- [ ] `FrotaDetalheScreen` exibe card com header colorido (placa + frota)
- [ ] Card mostra: marca, modelo, ano/anoModelo, cor, tipo
- [ ] Layout usa `ListView` para suportar scroll futuro
- [ ] Header respeita bordas arredondadas (`clipBehavior`)
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-busca-placa|Tela de busca por placa]]
- [[Tasks/2026-03-05-frota-pneus-lista|Lista de pneus do veiculo]]
- [[DevLog/]]
