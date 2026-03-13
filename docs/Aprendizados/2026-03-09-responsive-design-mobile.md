---
tags: [tipo/aprendizado, dominio/estilizacao]
date: 2026-03-09
---

# Responsive Design Mobile — Helper R e boas práticas

[[Aprendizados/_index|Aprendizados]]

---

## Problema

O Figma usa um frame fixo (375×648 neste projeto). Valores de pixels copiados diretamente para o Flutter ficam errados em dispositivos com telas diferentes.

## Solução — Helper R

```dart
class R {
  static late double _screenWidth;
  static late double _screenHeight;
  static const double _figmaWidth = 375;
  static const double _figmaHeight = 648;

  static void init(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }

  static double h(double figmaValue) => _screenHeight * (figmaValue / _figmaHeight);
  static double w(double figmaValue) => _screenWidth * (figmaValue / _figmaWidth);
}
```

**Uso:** chamar `R.init(context)` na primeira linha do `build()`. Depois usar `R.h(valor)` para dimensões verticais e `R.w(valor)` para horizontais.

## O que escalar vs não escalar

| Elemento | Escalar? | Motivo |
|---|---|---|
| Heights, widths, spacing | ✅ Sim | Proporcional ao tamanho da tela |
| `fontSize` | ❌ Não | Flutter já tem `TextScaleFactor` para acessibilidade |
| `borderRadius` | ❌ Não | Fica estranho se escalado; manter fixo |
| Área de toque mínima | ❌ Não | Mínimo 48×48px (guideline Google/Apple) |

## Boas práticas

- **`SafeArea`** — sempre usar para não sobrepor notch, status bar e barra de navegação
- **Sem altura fixa em containers de conteúdo dinâmico** — use `Expanded`, `Flexible` ou sem altura. Altura fixa só para elementos de tamanho conhecido
- **`SingleChildScrollView`** — adicionar em formulários para suporte ao teclado em telas pequenas
- **Rodapé fora do `Expanded`** — ancora naturalmente no fundo da tela em qualquer dispositivo

## Quando usar alternativa — flutter_screenutil

Pacote popular que faz o mesmo com sintaxe mais curta (`.h`, `.w`). Vale adotar se o projeto crescer muito e o `R.init(context)` em cada tela se tornar incômodo.

## Referência

- `lib/utils/responsive.dart`
- [[Tasks/2026-03-05-estilizacao-login]]
