---
tags: [tipo/devlog, dominio/login]
date: 2026-02-27
---

# Dev Log — 27/02/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-02-26-login-logo-svg|Inserir logo SVG de frota na tela de login]]

## O que foi feito

- Adicionada dependência `flutter_svg: ^2.2.3` ao `pubspec.yaml`
- Declarada pasta `assets/` no `pubspec.yaml`
- Layout da tela de login reestruturado: logo `icone_Frota.svg` no topo, formulário centralizado no espaço restante via `Expanded + Center`

## Decisões tomadas

- **Logo no topo, não inline com o formulário**: separar o logo do bloco de campos dá mais identidade visual à tela e é o padrão mais comum em apps de login
- **`Expanded` + `Center` + `mainAxisSize: MainAxisSize.min`**: o `Expanded` ocupa o espaço restante após o logo, o `Center` centraliza o formulário dentro desse espaço, e o `mainAxisSize: MainAxisSize.min` no `Column` interno impede que ele tente expandir para toda a altura disponível
- **Sem `AppLogo` component**: o logo é usado apenas na tela de login por ora; a extração para componente ficará para quando houver reuso real em outras telas

## Problemas encontrados

Nenhum.

## Aprendizados

- Para posicionar um elemento no topo e centralizar o restante, o padrão `Column(element, Expanded(Center(content)))` é mais limpo do que manipular `mainAxisAlignment` ou usar `Spacer`.
- `mainAxisSize: MainAxisSize.min` é essencial em `Column` aninhados dentro de `Expanded` — sem ele, o `Column` tenta preencher toda a altura e quebra o layout.

## Próximos passos

- Task pendente: modularizar a tela de login
