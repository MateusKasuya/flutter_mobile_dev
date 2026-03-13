---
tags: [tipo/task, dominio/login, dominio/estilizacao]
date: 2026-03-05
status: concluída
branch: feat/estilizacao-login
---

# Task — Estilização do Login

[[Tasks/_index|Tasks]]

---

## Contexto

O Figma mostra a tela de login com: gradiente suave de fundo no topo, logo centralizada no container, título "Entre na sua conta Frota!" posicionado sobre o gradiente, campos com label acima, borda arredondada e hint text estilizado, checkbox "Lembrar usuário e senha" e botão "Entrar" pill shape. A tela funcional precisava de ajustes visuais para alinhar com o design.

## Objetivo

Tela de login estilizada conforme o Figma: gradiente fixo de 180px no topo como fundo, bloco de conteúdo (logo + título + form) centralizado verticalmente na tela inteira, campos com Montserrat e borda teal, checkbox customizado, botão pill shape, rodapé ancorado no fundo.

---

## Branch

```bash
git checkout -b feat/estilizacao-login
```

## Arquivos modificados

- `lib/screens/login_screen.dart`
- `lib/components/cpf_field.dart`
- `lib/components/password_field.dart`
- `lib/components/remember_me_checkbox.dart`

---

## O que foi implementado

### Estrutura de layout — dois Stacks aninhados

O `body` do `Scaffold` usa um `Stack` com duas camadas:
1. `Container` de gradiente (180px, fundo fixo)
2. `SafeArea` com o conteúdo por cima

Dentro da `SafeArea`, um segundo `Stack` permite que o rodapé seja `Positioned` no fundo, liberando a área total da tela para o cálculo de centralização do conteúdo:

```dart
body: Stack(
  children: [
    // camada de fundo: gradiente fixo de 180px
    Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
    ),
    SafeArea(
      top: false,
      child: Stack(
        children: [
          // bloco centralizado na tela inteira
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [logo, título, campos, botão],
                ),
              ),
            ),
          ),
          // rodapé fora do fluxo, não afeta o cálculo de centro
          Positioned(
            bottom: 16,
            left: 0, right: 0,
            child: Text('por transportefacil.com.br', ...),
          ),
        ],
      ),
    ),
  ],
)
```

- **`Positioned.fill`** — envolve o `LayoutBuilder` dentro do `Stack`. Sem isso, filhos não-posicionados de um `Stack` recebem constraints soltas: se dimensionam pelo conteúdo (~300px) e ancoram no canto superior esquerdo, causando desalinhamento em telas mais largas que o frame Figma. `Positioned.fill` força constraints rígidas (largura e altura exatas do Stack).
- **`LayoutBuilder`** — captura a altura disponível da `SafeArea` inteira (sem subtrair o rodapé).
- **`ConstrainedBox(minHeight: constraints.maxHeight)`** — força a `Column` a ter no mínimo a altura total da tela, permitindo que `MainAxisAlignment.center` distribua o espaço sobrando igualmente acima e abaixo do bloco.
- **`Positioned`** — remove o rodapé do fluxo de layout; ele não entra no cálculo de centro, mas é renderizado sobre o conteúdo no fundo da tela.
- **`SingleChildScrollView`** — quando o teclado abre e o conteúdo não cabe, o scroll assume automaticamente.

### Tamanhos fixos do Figma — sem escala responsiva

Todos os tamanhos são valores literais do Figma (frame 375×648). Não há helper de escala — o que varia entre telas é apenas a posição Y do bloco (mais espaço acima/abaixo em telas maiores), não o tamanho dos elementos. O arquivo `lib/utils/responsive.dart` foi removido do projeto.

### Campos de entrada

`CpfField` e `PasswordField` com `appInputDecoration()`: borda `OutlineInputBorder` radius 10, `BorderSide` width 2 color `AppColors.primaryBorder`, hint text com `AppTextStyles.inputHint`. Ambos os campos com `height: 50` para altura idêntica.

Labels "CPF" e "Senha" em `SizedBox(width: 300)` com `Padding(left: 3)`, mesma largura dos campos. Isso garante alinhamento correto em qualquer tamanho de tela — label e campo são centralizados pela `Column` pelo mesmo ponto de referência. Com `Row` + `Expanded` (abordagem anterior), a label expandia até a borda do padding horizontal e desalinhava em telas mais largas que 375px. Gap de 8px entre label e campo.

### Checkbox

`CheckboxListTile` substituído por `Row` + `Checkbox` para controle total de padding e alinhamento. Ajustes: `Transform.translate(offset: Offset(-5, 0))` para alinhar com os campos, `Transform.scale(scale: 24/18)` para escala fixa (valor Figma direto), `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))` para cantos arredondados.

### Botão "Entrar"

```dart
SizedBox(
  width: 300, height: 56,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(56)),
    ),
    child: Text('Entrar', style: AppTextStyles.button),
  ),
)
```

---

## Critérios de aceite

- [x] Fundo com gradiente suave verde claro → branco
- [x] Sem AppBar, conteúdo respeita SafeArea (top: false para gradiente alcançar status bar)
- [x] Gradiente fixo de 180px no topo como fundo (não escala com a tela)
- [x] Sem AppBar, conteúdo respeita SafeArea (top: false para gradiente alcançar status bar)
- [x] Logo + título + form centralizado verticalmente e horizontalmente em qualquer tamanho de tela
- [x] Rodapé ancorado no fundo via Positioned, fora do cálculo de centralização
- [x] Scroll automático quando teclado abre
- [x] Campos CPF e Senha com altura idêntica (50px)
- [x] Campos com borda arredondada radius 10, cor teal, hint text Montserrat
- [x] Labels "CPF" e "Senha" acima dos campos, alinhadas à esquerda
- [x] Checkbox com cantos arredondados, alinhado com os campos
- [x] Botão "Entrar" pill shape, fundo teal, texto branco Montserrat
- [x] Todos os tamanhos como valores literais do Figma (frame 375×648), sem escala responsiva
- [x] `lib/utils/responsive.dart` removido do projeto
- [x] Cores e tipografia centralizadas em AppColors e AppTextStyles
- [x] Funcionalidade de login inalterada (CPF, senha, remember me, loading, toast)
- [x] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-splash-screen|Splash Screen]]
- [[Tasks/2026-03-09-modularizacao-codigo|Modularização do código]]
- [[Tasks/2026-03-05-estilizacao-home|Estilização da Home]]
- [[DevLog/2026-03-07-estilizacao-login]]
- [[DevLog/2026-03-09-estilizacao-login-continuacao]]
- [[DevLog/2026-03-10-estilizacao-login-finalizacao]]
