---
tags: [tipo/task, dominio/frota]
date: 2026-04-01
status: planejada
branch: feat/diagrama-eixos-widget
---

# Task — Widget do diagrama de eixos TOCO

[[Tasks/_index|Tasks]]

---

## Contexto

Com o model `Eixo` e a função `buildEixoLayout` prontos, precisamos do componente visual que desenha o diagrama esquemático do veículo visto de cima. Para um TOCO (2 eixos: dianteiro simples + traseiro duplo), o diagrama fica:

```
           ▲ Frente

  [2397]  ──────────────  [2396]       ← Eixo 1 (simples)
                ║  ║
                ║  ║
[1272][1353] ────────── [1334][1280]    ← Eixo 2 (duplo)
  EE    EI                DI    DE
```

Cada retângulo representa um pneu com duas interações:
- **Toque rápido** → callback `onPneuTap` (para exibir detalhes)
- **Segurar + arrastar** → `LongPressDraggable<Pneu>` (para ações como mover para estoque, conserto, etc.)

## Objetivo

Criar o widget `DiagramaEixos` reutilizável em `lib/components/`, que recebe `List<Eixo>`, um callback `onPneuTap` e suporta drag-and-drop nos tiles de pneu.

---

## Branch

```bash
git checkout -b feat/diagrama-eixos-widget
```

## Arquivos a criar

- `lib/components/diagrama_eixos.dart`

## Arquivos a modificar

- *(nenhum)*

---

## Implementação

### Passo 1 — Criar o widget `DiagramaEixos`

Criar `lib/components/diagrama_eixos.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/eixo.dart';
import '../models/pneu.dart';
import '../theme/app_colors.dart';

/// Diagrama esquemático de eixos do veículo visto de cima.
///
/// Exibe os eixos como linhas horizontais, os pneus como retângulos
/// arrastáveis e o chassis como linhas verticais conectando os eixos.
///
/// Interações:
/// - Toque rápido no pneu → [onPneuTap]
/// - Segurar + arrastar → [LongPressDraggable] com dado [Pneu]
class DiagramaEixos extends StatelessWidget {
  final List<Eixo> eixos;
  final void Function(Pneu pneu)? onPneuTap;

  const DiagramaEixos({
    super.key,
    required this.eixos,
    this.onPneuTap,
  });

  @override
  Widget build(BuildContext context) {
    if (eixos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const _DirecaoIndicator(),
          const SizedBox(height: 16),
          for (int i = 0; i < eixos.length; i++) ...[
            _EixoRow(eixo: eixos[i], onPneuTap: onPneuTap),
            if (i < eixos.length - 1) const _ChassisConnector(),
          ],
        ],
      ),
    );
  }
}
```

**Explicações:**

- **`SizedBox.shrink()`** — se não há eixos, renderiza um widget invisível de tamanho zero. Melhor que `Container()` (que ocupa espaço) ou lançar erro.

- **`for (int i = 0; ...)` dentro da lista de children** — Dart permite collection-for dentro de list literals. Iteramos pelos eixos e inserimos um `_ChassisConnector` entre cada par, usando `if (i < length - 1)` para não colocar após o último.

- **Spread operator `...[]`** — o `...` "espalha" os widgets gerados pelo for na lista de children. Sem ele, teríamos uma lista dentro de outra lista.

---

### Passo 2 — Indicador de direção

Adicionar no mesmo arquivo:

```dart
/// Seta indicando a frente do veículo.
class _DirecaoIndicator extends StatelessWidget {
  const _DirecaoIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_upward, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          'Frente',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
```

**Explicação:**

- **Indicador "Frente"** — como o diagrama é visto de cima, o usuário precisa saber qual lado é a frente do veículo. O Eixo 1 (dianteiro) fica no topo, próximo da seta.

---

### Passo 3 — Linha do eixo com pneus

```dart
/// Uma linha de eixo: pneus à esquerda, linha horizontal, pneus à direita.
class _EixoRow extends StatelessWidget {
  final Eixo eixo;
  final void Function(Pneu pneu)? onPneuTap;

  const _EixoRow({required this.eixo, this.onPneuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Linha do eixo (fundo, largura total)
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Pneus posicionados nas extremidades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLado(
                externo: eixo.esquerdoExterno,
                interno: eixo.esquerdoInterno,
              ),
              // Label do eixo no centro
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'E${eixo.numero}',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              _buildLado(
                externo: eixo.direitoExterno,
                interno: eixo.direitoInterno,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Monta o grupo de pneus de um lado (esquerdo ou direito).
  Widget _buildLado({Pneu? externo, Pneu? interno}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PneuTile(pneu: externo, onTap: onPneuTap),
        if (interno != null) ...[
          const SizedBox(width: 4),
          _PneuTile(pneu: interno, onTap: onPneuTap),
        ],
      ],
    );
  }
}
```

**Explicações:**

- **`Stack` com linha + Row** — a linha do eixo ocupa toda a largura no fundo. Os pneus ficam posicionados sobre ela nas extremidades via `MainAxisAlignment.spaceBetween`. O Stack faz os pneus "flutuarem" sobre a linha.

- **Label "E1", "E2"** — no centro da linha do eixo, um label com fundo branco "corta" visualmente a linha, indicando o número do eixo.

- **`_buildLado`** — método genérico para ambos os lados. Se o eixo é simples, só renderiza o externo. Se é duplo, renderiza externo + gap + interno.

---

### Passo 4 — Tile do pneu com drag-and-drop

```dart
/// Retângulo que representa um pneu individual.
///
/// Duas interações:
/// - **Toque rápido** → chama [onTap] (para detalhes)
/// - **Segurar + arrastar** → [LongPressDraggable] (para ações)
///
/// O [LongPressDraggable] fornece o [Pneu] como dado para [DragTarget]s
/// consumirem (ex: zona de "Estoque", "Conserto", etc.).
class _PneuTile extends StatelessWidget {
  final Pneu? pneu;
  final void Function(Pneu pneu)? onTap;

  const _PneuTile({this.pneu, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (pneu == null) {
      return const SizedBox(width: 52, height: 28);
    }

    return LongPressDraggable<Pneu>(
      data: pneu,
      feedback: Material(
        color: Colors.transparent,
        child: _buildContent(dragging: true),
      ),
      childWhenDragging: Container(
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: () => onTap?.call(pneu!),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent({bool dragging = false}) {
    return Container(
      width: 52,
      height: 28,
      decoration: BoxDecoration(
        color: dragging ? AppColors.primary : const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: dragging ? AppColors.primary : Colors.grey.shade600,
          width: 1,
        ),
        boxShadow: dragging
            ? const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          pneu!.nroPneu,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
```

**Explicações:**

- **`LongPressDraggable<Pneu>`** — widget do Flutter que habilita drag-and-drop com ativação por pressão longa. O tipo genérico `<Pneu>` define que o dado transportado é um objeto `Pneu`. Qualquer `DragTarget<Pneu>` pode recebê-lo.

- **`feedback`** — o widget que segue o dedo durante o arraste. Usamos a mesma forma do tile mas com cor primária (teal) e sombra, para dar feedback visual de que o pneu está "levantado". O `Material(color: transparent)` é necessário porque o `feedback` é renderizado fora da árvore de widgets, sem acesso ao tema — sem ele, o `Text` não renderiza corretamente.

- **`childWhenDragging`** — o que fica no lugar original enquanto o pneu está sendo arrastado. Um retângulo cinza claro funciona como "espaço vazio" indicando de onde o pneu saiu.

- **`GestureDetector` dentro de `LongPressDraggable`** — o `LongPressDraggable` consome o gesto de pressão longa, mas o `GestureDetector.onTap` continua funcionando para toques rápidos. As duas interações coexistem sem conflito.

- **`_buildContent(dragging: true/false)`** — método compartilhado que gera o visual do tile. Quando `dragging` é true, usa cor primária + sombra. Evita duplicação de código entre o estado normal e o feedback do arraste.

---

### Passo 5 — Conector do chassis

```dart
/// Linhas verticais conectando eixos, representando o chassis.
class _ChassisConnector extends StatelessWidget {
  const _ChassisConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Explicação:**

- **Duas linhas verticais paralelas** — representam as longarinas do chassis. O gap de 16px dá a noção de largura do chassis.

---

## Critérios de aceite

- [ ] `lib/components/diagrama_eixos.dart` criado
- [ ] Indicador "Frente" com seta no topo
- [ ] Eixo simples renderiza 1 pneu de cada lado
- [ ] Eixo duplo renderiza 2 pneus de cada lado (externo + interno)
- [ ] Chassis (linhas verticais) conecta os eixos
- [ ] Label "E1", "E2" no centro de cada eixo
- [ ] Toque rápido no pneu dispara `onPneuTap`
- [ ] Segurar + arrastar levanta o pneu como `LongPressDraggable<Pneu>`
- [ ] Feedback do arraste: cor primária + sombra
- [ ] Placeholder cinza no local original durante arraste
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-04-01-eixo-layout-model|Modelo Eixo e parser de LOCALEIXO]]
- [[Tasks/2026-04-01-diagrama-eixos-integracao|Integração do diagrama na FrotaDetalheScreen]]
- [[DevLog/]]
