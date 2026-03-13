---
tags: [tipo/devlog, dominio/login, dominio/estilizacao]
date: 2026-03-10
---

# Dev Log — 10/03/2026 (Estilização Login — finalização)

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-estilizacao-login|Estilização do Login]]

## O que foi feito

- Removido `lib/utils/responsive.dart` — helper `R` descartado. Todos os `R.h()` / `R.w()` substituídos pelos valores literais do Figma (frame 375×648) em `login_screen.dart`, `cpf_field.dart`, `password_field.dart` e `remember_me_checkbox.dart`
- Reestruturado o layout da tela de login: `Stack` + `Positioned` do título removidos; logo, título e form passam a ser uma coluna linear única
- Gradiente de 180px mantido como camada de fundo via `Stack` no `body` do `Scaffold`
- Bloco de conteúdo (logo + título + form + botão) centralizado verticalmente em relação à tela inteira com `LayoutBuilder` + `ConstrainedBox(minHeight)` + `MainAxisAlignment.center`
- Rodapé movido para `Positioned(bottom: 16)` dentro de um segundo `Stack` na `SafeArea` — fica fora do fluxo de layout, não afeta o cálculo de centro
- Corrigido `CpfField`: adicionado `height: 50` no `SizedBox` para igualar a altura do `PasswordField`
- Corrigido alinhamento das labels "CPF" e "Senha": substituída a abordagem `Row` + `Expanded` por `SizedBox(width: 300)` + `Padding(left: 3)`, mesma largura dos campos — label e campo centralizados pelo mesmo ponto de referência em qualquer tela
- Corrigido desalinhamento à esquerda em telas largas (ex: iPhone 17 Pro Max): `LayoutBuilder` envolto em `Positioned.fill` dentro do `Stack` da `SafeArea` — sem isso, o filho recebia constraints soltas e se dimensionava pelo conteúdo (~300px), ancorando no canto superior esquerdo
- `flutter analyze` sem erros

## Decisões tomadas

- **Valores literais do Figma sem escala** — decisão do projeto: manter as dimensões exatas do Figma. Adaptação entre telas se dá apenas pelo deslocamento vertical do bloco (mais espaço acima/abaixo em telas maiores), não pelo redimensionamento dos elementos
- **`LayoutBuilder` + `ConstrainedBox(minHeight)` para centralização** — padrão Flutter para centralizar conteúdo verticalmente num `SingleChildScrollView`: `LayoutBuilder` captura a altura disponível, `ConstrainedBox` garante que a `Column` sempre ocupa pelo menos esse espaço, `MainAxisAlignment.center` distribui o restante igualmente acima e abaixo
- **Rodapé como `Positioned`** — sem `Positioned`, o rodapé subtrairia sua altura do espaço medido pelo `LayoutBuilder`, deslocando o centro para cima. Com `Positioned` ele fica fora do fluxo e o cálculo usa a tela inteira
- **Labels com `SizedBox(width: 300)` em vez de `Row` + `Expanded`** — `Row` + `Expanded` faz a label crescer até a largura total da área de conteúdo (tela − padding). Em telas mais largas que 375px, o campo de 300px é centralizado mais para dentro que a label, causando desalinhamento. Com `SizedBox(width: 300)` ambos têm o mesmo container e são centralizados pelo mesmo ponto
- **`Positioned.fill` no `LayoutBuilder` dentro do `Stack`** — filhos não-posicionados de um `Stack` recebem constraints soltas: se dimensionam pelo conteúdo (~300px) e ancoram no canto superior esquerdo. `Positioned.fill` converte para constraints rígidas (largura e altura exatas do Stack), fazendo o `LayoutBuilder` medir a tela inteira e o `MainAxisAlignment.center` funcionar corretamente em qualquer largura

## Próximos passos

- [[Tasks/2026-03-05-estilizacao-home|Estilização da Home]]
