---
tags: [tipo/aprendizado, dominio/estilizacao]
date: 2026-03-09
---

# Stack, Positioned e SafeArea

[[Aprendizados/_index|Aprendizados]]

---

## Stack

Widget que permite sobrepor filhos. O tamanho do `Stack` é determinado pelo maior filho não-positioned.

```dart
Stack(
  children: [
    Container(...),         // filho de base — define o tamanho do Stack
    Positioned(             // filho sobreposto — posicionado absolutamente
      top: 127,
      left: 0, right: 0,
      child: Text(...),
    ),
  ],
)
```

**Quando usar:** elemento que precisa se sobrepor a outro com posição absoluta (ex: badge sobre ícone, título sobre gradiente).

## Positioned

Filho do `Stack` com posição absoluta. Propriedades:
- `top`, `bottom`, `left`, `right` — distância das bordas do Stack
- `width`, `height` — tamanho do widget (opcional)

Se não usar `left`/`right`, o widget tem a largura do filho. Para centralizar horizontalmente: `left: 0, right: 0` + `Center` como filho.

## SafeArea

Adiciona padding automático para evitar que o conteúdo fique atrás de notch, status bar, home indicator e barra de navegação.

```dart
SafeArea(
  top: false,    // desativa padding do topo → gradiente alcança status bar
  bottom: true,  // mantém padding inferior (padrão)
  child: ...,
)
```

**`top: false`** é útil quando um container de fundo (gradiente, imagem hero) deve se estender até a borda física da tela. O conteúdo interativo (campos, botões) ainda deve respeitar a safe area.

## Referência

- `lib/screens/login_screen.dart`
- [[Tasks/2026-03-05-estilizacao-login]]
