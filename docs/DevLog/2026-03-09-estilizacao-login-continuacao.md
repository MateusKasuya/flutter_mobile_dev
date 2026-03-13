---
tags: [tipo/devlog, dominio/login, dominio/estilizacao]
date: 2026-03-09
---

# Dev Log — 09/03/2026 (Estilização Login — continuação)

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-estilizacao-login|Estilização do Login]]

## O que foi feito

- Criado `lib/utils/responsive.dart` — helper `R` com frame Figma 375×648. Todos os tamanhos migrados para `R.h()` / `R.w()`
- Container do topo migrado para `Stack` + `Positioned`: logo centralizada no container, título "Entre na sua conta Frota!" posicionado a `R.h(127)` do topo sobreposto ao gradiente
- `SafeArea(top: false)` — gradiente alcança a status bar (horário, bateria, WiFi)
- Tipografia migrada para Montserrat via `google_fonts`: heading (26/w700), label (16/w600), inputHint (18/w500), button (20/w600), footer (10/w500)
- `CpfField` e `PasswordField`: borda teal `#028687` width 2, radius 10, hint text estilizado
- `CheckboxListTile` substituído por `Row + Checkbox` para controle preciso de padding e alinhamento com os campos
- Checkbox: `Transform.translate(-5,0)` para alinhamento, `Transform.scale(R.w(24)/18)` para escala responsiva, `shape: RoundedRectangleBorder(radius: 6)` para cantos arredondados
- `Expanded` → `SingleChildScrollView` no formulário para suporte ao teclado em telas pequenas
- Rodapé movido para fora do `Expanded`, ancorado no fundo da `Column` externa
- Cores e estilos centralizados em `AppColors` e `AppTextStyles` (task de modularização)
- Teste `CheckboxListTile` → `Checkbox` corrigido
- `flutter analyze` sem erros — 26 testes passando

## Decisões tomadas

- **`Stack` + `Positioned` para o título** — necessário porque o título precisa se sobrepor ao container do gradiente com coordenada `top` absoluta vinda do Figma
- **`SafeArea(top: false)`** — deliberado para o gradiente cobrir a status bar, como no Figma. Os outros lados (`bottom`, `left`, `right`) continuam protegidos
- **`Row + Checkbox` no lugar de `CheckboxListTile`** — `CheckboxListTile` tem padding mínimo e altura mínima (56px) que não podem ser totalmente removidos, causando desalinhamento com os demais elementos
- **`SingleChildScrollView` sem `LayoutBuilder/IntrinsicHeight`** — público-alvo é majoritariamente Android mais antigo (telas ~360×640), próximo ao frame Figma (375×648). Solução simples é suficiente; a abordagem complexa seria overkill

## Problemas encontrados

- Overflow no container do topo ao usar `SafeArea(top: false)` com posicionamentos fixos — resolvido ajustando a altura do container para `R.h(180)` e usando `Stack`
- `CheckboxListTile` não respeitava padding do pai — resolvido substituindo por `Row + Checkbox`
- `SizedBox(width: double.infinity)` dentro de `Row` causa overflow — resolvido com `Expanded`

## Aprendizados

- [[Aprendizados/2026-03-09-responsive-design-mobile]] — Helper R e boas práticas de proporções no Flutter
- [[Aprendizados/2026-03-09-stack-positioned]] — Stack, Positioned e SafeArea

## Próximos passos

- [[Tasks/2026-03-05-estilizacao-home|Estilização da Home]]
