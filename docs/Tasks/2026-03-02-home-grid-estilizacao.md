---
tags: [tipo/task, dominio/home, dominio/estilizacao]
date: 2026-03-02
status: planejada
branch: feat/home-grid-estilizacao
---

# Task — Estilização dos cards do GridView da Home Screen

[[Tasks/_index|Tasks]]

---

## Contexto

O GridView atual exibe os dados corretamente, mas o visual é simples — card branco genérico com texto. O objetivo é aplicar uma estilização mais polida: cards brancos com barra de acento lateral colorida, ícone específico por tipo de localização, e fundo sutil na tela.

## Objetivo

Cards estilizados com barra lateral colorida, ícone por tipo (ESTOQUE, FROTA, SUCATA, VENDA) e hierarquia visual mais clara.

---

## Branch

```bash
git checkout -b feat/home-grid-estilizacao
```

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `lib/screens/home_screen.dart` — reescrever `_LocalizacaoCard` e ajustar o `Scaffold`

---

## Implementação

> **Pré-requisito:** Task [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]] concluída.

### Passo 1 — Ajustar o Scaffold e o GridView

No `build` de `_HomeScreenState`, aplicar fundo sutil e ajustar a proporção dos cards:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Início')),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: _localizacoes
                  .map((loc) => _LocalizacaoCard(localizacao: loc))
                  .toList(),
            ),
          ),
  );
}
```

**`backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow`**

O Material Design 3 define uma escala de tons de superfície gerados automaticamente a partir da cor primária. `surfaceContainerLow` é um cinza muito suave que cria contraste sutil com os cards brancos por cima — dá profundidade à tela sem ser invasivo.

**`childAspectRatio: 1.1`**

Reduzimos de `1.5` para `1.1` — os cards agora são quase quadrados. Isso acomoda melhor o novo layout com ícone + número + nome empilhados verticalmente.

---

### Passo 2 — Criar o mapa de ícones por localização

Adicionar como constante no topo do arquivo (abaixo dos imports) ou dentro de `_LocalizacaoCard`:

```dart
const _localizacaoIcons = <String, IconData>{
  'ESTOQUE': Icons.warehouse,
  'FROTA': Icons.local_shipping,
  'SUCATA': Icons.recycling,
  'VENDA': Icons.sell,
};
```

**Por que um `Map<String, IconData>` constante?**

A API retorna o nome como String (`"ESTOQUE"`, `"FROTA"`, etc.). Precisamos converter essa String para um ícone visual. Um `Map` constante é a forma mais simples de fazer esse mapeamento. `IconData` é o tipo que representa um ícone do Flutter — quando você escreve `Icons.warehouse`, o valor é um `IconData`.

O `const` na frente do `Map` diz ao Dart: "esse mapa nunca muda, pode alocar em tempo de compilação". Isso evita recriar o mapa toda vez que o widget é reconstruído.

**Escolha dos ícones:**
- `Icons.warehouse` (ESTOQUE) — armazém/depósito
- `Icons.local_shipping` (FROTA) — caminhão, representando veículos da frota
- `Icons.recycling` (SUCATA) — símbolo de reciclagem, pneus descartados
- `Icons.sell` (VENDA) — etiqueta de preço, pneus à venda

---

### Passo 3 — Reescrever `_LocalizacaoCard` com barra lateral e ícone

Substituir o widget `_LocalizacaoCard` inteiro:

```dart
class _LocalizacaoCard extends StatelessWidget {
  final Localizacao localizacao;

  const _LocalizacaoCard({required this.localizacao});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final icon = _localizacaoIcons[localizacao.nome] ?? Icons.help_outline;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 6,
            color: primary,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: primary,
                  ),
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
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Explicação do novo layout

**A estrutura geral: `Card` → `Row` → `[barra, conteúdo]`**

Antes usávamos `Column` como filho direto do `Card` (empilhamento vertical). Agora usamos `Row` porque queremos dois elementos lado a lado horizontalmente: a barra colorida à esquerda e o conteúdo à direita.

---

**`shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`**

Define cantos arredondados com raio de 12 pixels. Sem esse parâmetro, o `Card` usaria o raio padrão do tema (que pode variar). Definir explicitamente garante consistência.

---

**`clipBehavior: Clip.antiAlias`**

Sem isso, a barra lateral (um `Container` retangular) "vazaria" pelos cantos arredondados do card. O `Clip.antiAlias` recorta qualquer conteúdo que ultrapasse os limites da forma do card, mantendo os cantos limpos. O `.antiAlias` especificamente suaviza as bordas do recorte para evitar serrilhado.

---

**`Container(width: 6, color: primary)`**

Dentro de um `Row`, o `Container` com `width: 6` cria uma barra vertical de 6 pixels de largura. Não definimos `height` porque, dentro do `Row`, ele automaticamente estica para a altura total do card (esse é o comportamento padrão de um filho de `Row` que não tem altura definida — ele segue a `crossAxisExtent` do pai).

---

**`Expanded` no conteúdo**

O `Expanded` diz ao `Row`: "depois de colocar a barra de 6px, dê todo o espaço restante para este filho". Sem ele, o `Padding` tentaria se dimensionar pelo conteúdo mínimo e a `Row` poderia reclamar de overflow ou deixar espaço vazio.

---

**`final icon = _localizacaoIcons[localizacao.nome] ?? Icons.help_outline;`**

Busca o ícone no mapa pelo nome. O operador `??` (null-aware) define um fallback: se o nome não existir no mapa (ex: a API retornar um tipo novo que não mapeamos), usa `Icons.help_outline` (ícone de interrogação). Isso evita crash por `null` — o app sempre mostra algo.

---

**`Icon(icon, size: 32, color: primary)`**

O widget `Icon` renderiza um ícone do Material Icons. `size: 32` define o tamanho em pixels lógicos. `color: primary` aplica a cor primária do tema. O ícone é SVG vetorial internamente, então escala sem perder qualidade.

---

**`headlineSmall` em vez de `headlineMedium`**

Reduzimos o tamanho da tipografia do número de `headlineMedium` para `headlineSmall` porque o card agora tem mais elementos (ícone + número + nome). Com `headlineMedium` o número ficaria grande demais e competiria visualmente com o ícone.

---

**`onSurface` para o número, `onSurfaceVariant` para o nome**

Hierarquia de cores no Material 3:
- `onSurface` = cor de conteúdo primário (mais escura, mais destaque) → usada no número
- `onSurfaceVariant` = cor de conteúdo secundário (mais clara, menos destaque) → usada no nome

Isso cria uma hierarquia visual: ícone (cor primária) > número (escuro) > nome (discreto).

---

## Critérios de aceite

- [ ] Scaffold com fundo `surfaceContainerLow`
- [ ] Cards com bordas arredondadas (radius 12) e `clipBehavior`
- [ ] Barra de acento lateral colorida (6px) na esquerda de cada card
- [ ] Ícone específico por localização (warehouse, local_shipping, recycling, sell)
- [ ] Fallback `help_outline` para localizações desconhecidas
- [ ] Quantidade em `headlineSmall` bold cor `onSurface`
- [ ] Nome em `labelLarge` com `letterSpacing: 0.5` e cor `onSurfaceVariant`
- [ ] `childAspectRatio` ajustado para 1.1
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-home-grid-localizacoes|Home Screen com GridView]]
- [[DevLog/]]
