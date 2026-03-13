---
tags: [tipo/task, dominio/home, dominio/estilizacao]
date: 2026-03-05
status: concluída
branch: feat/estilizacao-home
---

# Task — Estilizacao da Home

[[Tasks/_index|Tasks]]

---

## Contexto

O Figma mostra a Home Screen com visual diferente do atual: logo "FROTA" no canto superior esquerdo (sem AppBar padrao), titulo "Monitoramento de movimentacoes da Frota", grid de 3 colunas (atualmente 2), cards brancos com icone teal e label, e botao "Adicionar Movimento" largo fixo na parte inferior (atualmente eh um FAB). Precisamos reestilizar para alinhar com o design.

## Objetivo

Home Screen estilizada conforme o Figma: logo no topo, titulo descritivo, grid 3 colunas, cards arredondados com icone/numero/label, e botao inferior estilizado substituindo o FAB.

---

## Branch

```bash
git checkout -b feat/estilizacao-home
```

## Arquivos a criar

- *(nenhum)*

## Arquivos a modificar

- `lib/screens/home_screen.dart`

---

## Implementacao

### Passo 1 — Substituir AppBar por logo no topo

Remover o `appBar: AppBar()` e adicionar a logo "FROTA" como parte do body. Usar `SafeArea` para respeitar a status bar.

Modificar o `Scaffold` no `build`:

```dart
return Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'assets/icone_Frota.svg',
              height: 30,
            ),
          ),
        ),
        const Divider(),
        // ... restante do conteudo
      ],
    ),
  ),
);
```

Adicionar import no topo:

```dart
import 'package:flutter_svg/flutter_svg.dart';
```

**Explicacoes:**

- **Remocao do `AppBar`** — o Figma nao mostra a AppBar padrao do Material, apenas a logo alinhada a esquerda. Isso da um visual mais limpo e personalizado.

- **`Align(alignment: Alignment.centerLeft)`** — alinha a logo a esquerda dentro do padding. O Figma mostra a logo no canto superior esquerdo.

- **`const Divider()`** — linha fina separando a logo do conteudo abaixo, como no Figma. O `Divider` usa a cor do tema automaticamente.

- **`EdgeInsets.fromLTRB(16, 12, 16, 0)`** — padding assimetrico: Left 16, Top 12, Right 16, Bottom 0. O top menor que o padrao porque o `SafeArea` ja adiciona espaco para a status bar.

---

### Passo 2 — Adicionar titulo descritivo

Apos o `Divider`, adicionar o titulo:

```dart
const Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Text(
    'Monitoramento de\nmovimentacoes da Frota',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
),
```

**Explicacao:**

- **Titulo centralizado** — o Figma mostra "Monitoramento de movimentacoes da Frota" centralizado entre a logo e o grid. Fornece contexto sobre o que os cards representam.

---

### Passo 3 — Alterar grid para 3 colunas

Modificar o `GridView.count` existente:

```dart
Expanded(
  child: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: _localizacoes
              .map((loc) => _LocalizacaoCard(localizacao: loc))
              .toList(),
        ),
      ),
),
```

**Explicacoes:**

- **`crossAxisCount: 3`** — muda de 2 para 3 colunas, conforme o Figma. Cada card ocupa 1/3 da largura.

- **`childAspectRatio: 0.85`** — ajustado porque com 3 colunas os cards ficam mais estreitos. Um ratio menor que 1 significa que os cards sao mais altos que largos. O valor 0.85 cria proporcao similar ao Figma. Ajustar conforme necessario.

- **`Expanded`** — envolve o grid para que ocupe todo o espaco disponivel entre o titulo e o botao inferior, dentro da `Column`.

---

### Passo 4 — Reestilizar o _LocalizacaoCard

Modificar o widget `_LocalizacaoCard` para alinhar com o Figma — card branco, arredondado, sem barra lateral, icone teal centralizado, numero grande, label abaixo:

```dart
class _LocalizacaoCard extends StatelessWidget {
  final Localizacao localizacao;

  const _LocalizacaoCard({required this.localizacao});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final icon = _localizacaoIcons[localizacao.nome] ?? Icons.help_outline;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: primary),
            const SizedBox(height: 8),
            Text(
              '${localizacao.quantidade}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              localizacao.nome,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

**O que mudou:**

- **Removida a barra lateral colorida** — o Figma mostra cards limpos sem a barra de 6px.
- **`borderRadius: 16`** — cantos mais arredondados que antes (era 12), consistente com o Figma.
- **`fontSize: 11`** — label menor para caber em 3 colunas sem quebrar.
- **`overflow: TextOverflow.ellipsis`** — caso o nome da localizacao seja longo demais, trunca com "..." em vez de estourar o layout.
- **Layout mais compacto** — padding reduzido para acomodar 3 colunas.

---

### Passo 5 — Substituir FAB por botao inferior estilizado

Remover o `floatingActionButton` e `floatingActionButtonLocation` do `Scaffold`. Adicionar o botao como ultimo item da `Column`, antes do fechamento do `SafeArea`:

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
  child: SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovimentoScreen(token: widget.token),
          ),
        );
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text(
        'Adicionar Movimento',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
    ),
  ),
),
```

**Explicacoes:**

- **Botao em vez de FAB** — o Figma mostra um botao largo na parte inferior, nao um FAB flutuante. O `ElevatedButton.icon` combina icone + texto num botao unico.

- **`BorderRadius.circular(26)`** — pill shape igual ao botao "Entrar" do login, mantendo consistencia visual.

- **`EdgeInsets.fromLTRB(24, 8, 24, 16)`** — margens laterais de 24 e padding inferior de 16 para afastar do fundo da tela.

- **`Icons.add_circle_outline`** — o Figma mostra um icone de "+" dentro de circulo ao lado do texto. Este icone do Material eh o mais proximo.

---

## Criterios de aceite

- [ ] Sem AppBar padrao — logo "FROTA" alinhada a esquerda no topo com `Divider` abaixo
- [ ] Titulo "Monitoramento de movimentacoes da Frota" centralizado
- [ ] Grid com 3 colunas
- [ ] Cards brancos arredondados, sem barra lateral, com icone/numero/label centralizados
- [ ] Botao "Adicionar Movimento" largo na parte inferior (pill shape, teal, texto branco)
- [ ] FAB removido
- [ ] Scroll funciona quando ha muitos cards
- [ ] Funcionalidade inalterada (loading, erro, navegacao)
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-estilizacao-login|Estilizacao do Login]]
- [[Tasks/2026-03-05-estilizacao-movimento|Estilizacao do Movimento]]
- [[DevLog/]]
