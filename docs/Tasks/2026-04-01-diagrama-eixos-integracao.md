---
tags: [tipo/task, dominio/frota]
date: 2026-04-01
status: concluída
branch: feat/diagrama-eixos-integracao
---

# Task — Integração do diagrama de eixos na FrotaDetalheScreen

[[Tasks/_index|Tasks]]

---

## Contexto

O widget `DiagramaEixos` está pronto com suporte a toque (detalhes) e `LongPressDraggable<Pneu>` (arrastar). Agora precisamos:

1. Integrar o diagrama na `FrotaDetalheScreen`
2. Criar zonas de ação (`DragTarget<Pneu>`) abaixo do diagrama para receber os pneus arrastados
3. Mostrar bottom sheet de detalhes ao tocar um pneu
4. Mostrar diálogo de confirmação ao soltar um pneu numa zona de ação

As 5 ações disponíveis (mesmo do sistema desktop): **Estoque**, **Conserto**, **Recapagem**, **Sucata** e **Venda**.

Como ainda não existe endpoint na API, a ação confirmada exibe apenas um toast de sucesso.

## Objetivo

Modificar a `FrotaDetalheScreen` para exibir o diagrama + zonas de ação com drag-and-drop, substituindo a lista de `_PneuCard`.

---

## Branch

```bash
git checkout -b feat/diagrama-eixos-integracao
```

## Arquivos a criar

- `lib/models/pneu_acao.dart` — enum com as 5 ações

## Arquivos a modificar

- `lib/screens/frota_detalhe_screen.dart`

---

## Implementação

### Passo 1 — Criar o enum `PneuAcao`

Criar `lib/models/pneu_acao.dart`:

```dart
import 'package:flutter/material.dart';

/// Ações que podem ser executadas ao arrastar um pneu para uma zona.
enum PneuAcao {
  estoque('Estoque', Icons.inventory_2, Color(0xFF1976D2)),
  conserto('Conserto', Icons.build, Color(0xFFF57C00)),
  recapagem('Recapagem', Icons.autorenew, Color(0xFF388E3C)),
  sucata('Sucata', Icons.delete_outline, Color(0xFFD32F2F)),
  venda('Venda', Icons.attach_money, Color(0xFF7B1FA2));

  final String label;
  final IconData icon;
  final Color color;

  const PneuAcao(this.label, this.icon, this.color);
}
```

**Explicações:**

- **Enhanced enum** — no Dart 2.17+, enums podem ter campos, construtores e métodos. Cada valor do enum carrega seu label, ícone e cor. Isso elimina a necessidade de maps ou switch/case para mapear ação → visual.

- **Cores semânticas** — cada ação tem uma cor intuitiva: azul para estoque (neutro/armazenamento), laranja para conserto (atenção), verde para recapagem (renovação), vermelho para sucata (descarte), roxo para venda (transação financeira).

---

### Passo 2 — Atualizar imports e body da `FrotaDetalheScreen`

No `lib/screens/frota_detalhe_screen.dart`, adicionar os imports:

```dart
import '../components/diagrama_eixos.dart';
import '../models/eixo.dart';
import '../models/pneu_acao.dart';
import '../utils/app_toast.dart';
import '../utils/eixo_utils.dart';
```

Substituir o `body` do `Scaffold`:

```dart
@override
Widget build(BuildContext context) {
  final eixos = buildEixoLayout(veiculo.pneus);

  return Scaffold(
    appBar: AppBar(title: Text(veiculo.placa)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _VeiculoCard(veiculo: veiculo),
        const SizedBox(height: 24),
        DiagramaEixos(
          eixos: eixos,
          onPneuTap: (pneu) => _showPneuDetails(context, pneu),
        ),
        const SizedBox(height: 24),
        _AcoesHeader(),
        const SizedBox(height: 12),
        _AcoesGrid(
          onPneuAction: (pneu, acao) =>
              _confirmAction(context, pneu, acao),
        ),
      ],
    ),
  );
}
```

**Explicações:**

- **`buildEixoLayout(veiculo.pneus)`** — transforma a lista plana de pneus na lista de eixos organizada.

- **Layout vertical** — VeiculoCard → Diagrama → Zonas de ação. Tudo dentro de um `ListView` para scroll quando o conteúdo excede a tela.

- **As zonas de ação ficam sempre visíveis** abaixo do diagrama. Quando o usuário arrasta um pneu sobre uma zona, ela destaca visualmente. Essa abordagem é mais simples e confiável do que mostrar/esconder zonas durante o arraste.

---

### Passo 3 — Header das ações

```dart
class _AcoesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.drag_indicator,
            size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          'Arraste um pneu para uma ação',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
```

**Explicação:**

- **Dica contextual** — o texto "Arraste um pneu para uma ação" ensina o usuário sobre a interação de drag-and-drop sem precisar de um tutorial. O ícone `drag_indicator` reforça visualmente.

---

### Passo 4 — Grid de zonas de ação (DragTargets)

```dart
class _AcoesGrid extends StatelessWidget {
  final void Function(Pneu pneu, PneuAcao acao) onPneuAction;

  const _AcoesGrid({required this.onPneuAction});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: PneuAcao.values
          .map((acao) => _ActionZone(
                acao: acao,
                onPneuAction: onPneuAction,
              ))
          .toList(),
    );
  }
}

class _ActionZone extends StatelessWidget {
  final PneuAcao acao;
  final void Function(Pneu pneu, PneuAcao acao) onPneuAction;

  const _ActionZone({
    required this.acao,
    required this.onPneuAction,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Pneu>(
      onAcceptWithDetails: (details) =>
          onPneuAction(details.data, acao),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: isHovering
                ? acao.color.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? acao.color : Colors.grey.shade300,
              width: isHovering ? 2.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                acao.icon,
                color: isHovering ? acao.color : Colors.grey.shade600,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                acao.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isHovering ? acao.color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Explicações:**

- **`DragTarget<Pneu>`** — widget que recebe dados de um `Draggable<Pneu>` (ou `LongPressDraggable<Pneu>`). O tipo genérico `<Pneu>` garante que só aceita pneus, não outros objetos arrastáveis.

- **`onAcceptWithDetails`** — callback disparado quando o usuário solta o pneu sobre esta zona. `details.data` contém o `Pneu` que foi arrastado.

- **`builder` com `candidateData`** — o `candidateData` é uma lista dos dados que estão sendo arrastados sobre este target neste momento. Se não está vazio, significa que um pneu está "pairando" sobre a zona → destaca visualmente.

- **`AnimatedContainer`** — anima as mudanças de cor e borda automaticamente quando `isHovering` muda. A duração de 200ms dá um feedback suave.

- **`Wrap`** — layout que distribui os filhos horizontalmente e quebra para a próxima linha quando não cabe. Com 5 zonas de 100px + spacing de 12px, cabem ~3 por linha na maioria dos dispositivos.

---

### Passo 5 — Diálogo de confirmação e toast

```dart
void _confirmAction(
    BuildContext context, Pneu pneu, PneuAcao acao) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(acao.label),
      content: Text(
        'Mover pneu ${pneu.nroPneu} para ${acao.label}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: acao.color,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // TODO: chamar API quando endpoint estiver disponível
    showSuccessToast(
        'Pneu ${pneu.nroPneu} movido para ${acao.label}');
  }
}
```

**Explicações:**

- **`showDialog<bool>`** — exibe um AlertDialog modal e retorna `true` (confirmar) ou `false`/`null` (cancelar/fechar). O tipo genérico `<bool>` garante que o retorno de `Navigator.pop` é tipado.

- **`FilledButton` com cor da ação** — o botão de confirmação usa a cor da ação específica (ex: vermelho para sucata), reforçando visualmente o que vai acontecer.

- **`confirmed == true`** — checagem explícita porque `showDialog` pode retornar `null` se o diálogo for fechado pelo botão de voltar do Android.

- **TODO para API** — quando o endpoint existir, substituir o toast por uma chamada HTTP.

---

### Passo 6 — Bottom sheet de detalhes (toque rápido)

```dart
void _showPneuDetails(BuildContext context, Pneu pneu) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Pneu ${pneu.nroPneu}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(height: 24),
          _InfoRow(label: 'Posição', value: pneu.localEixo),
          _InfoRow(label: 'Marca', value: pneu.marca),
          _InfoRow(label: 'Modelo', value: pneu.modelo),
          _InfoRow(label: 'Dimensão', value: pneu.dimensao),
          _InfoRow(label: 'Tipo', value: pneu.tipo),
          _InfoRow(label: 'Qtd. Vida', value: pneu.vidaPneu),
          _InfoRow(label: 'KM Rodado', value: pneu.kmRodado),
          _InfoRow(label: 'KM Ult. Vei.', value: pneu.kmAtuVei),
          _InfoRow(label: 'D. Ult. Atualização', value: pneu.dataAtzKm),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
```

**Explicações:**

- **`showModalBottomSheet`** — painel que desliza da parte inferior da tela. Padrão Flutter/Material para mostrar detalhes contextuais.

- **`MainAxisSize.min`** — o Column ocupa apenas o espaço do conteúdo, o bottom sheet se ajusta à altura.

- **Handle visual** — barra cinza no topo indica que o painel pode ser arrastado para fechar.

---

### Passo 7 — Remover widgets não utilizados e limpeza

Remover:
- `_PneuCard` — substituída pelo diagrama + bottom sheet

Manter:
- `_VeiculoCard` — exibida no topo
- `_InfoRow` — reutilizada no bottom sheet

---

## Critérios de aceite

- [ ] `lib/models/pneu_acao.dart` criado com enum de 5 ações
- [ ] Diagrama exibido na tela abaixo do card do veículo
- [ ] Zonas de ação visíveis abaixo do diagrama (Estoque, Conserto, Recapagem, Sucata, Venda)
- [ ] Arrastar pneu sobre zona destaca com cor + borda animada
- [ ] Soltar pneu na zona exibe diálogo de confirmação
- [ ] Confirmar exibe toast de sucesso
- [ ] Toque rápido no pneu abre bottom sheet com detalhes
- [ ] `_PneuCard` removida
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-04-01-eixo-layout-model|Modelo Eixo e parser de LOCALEIXO]]
- [[Tasks/2026-04-01-diagrama-eixos-widget|Widget do diagrama de eixos]]
- [[Tasks/2026-04-01-diagrama-eixos-tests|Testes do diagrama de eixos]]
- [[DevLog/]]
