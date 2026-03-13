---
tags: [tipo/devlog, dominio/movimento]
date: 2026-03-03
task: "[[Tasks/2026-03-03-movimento-screen-cards]]"
---

# Dev Log — Tela Movimento com cards de navegação

[[DevLog/_index|DevLog]]

---

## O que foi feito

Substituído o placeholder da `MovimentoScreen` por uma lista de cards estilizados com barra lateral colorida, ícone, label, subtítulo e seta. Aplicados ajustes de qualidade: correção de padding duplo, `InkWell` para feedback visual e subtítulo descritivo em cada card.

### Arquivos criados

- *(nenhum)*

### Arquivos modificados

- `lib/screens/movimento_screen.dart` — layout com `_MovimentoCard`, padding corrigido, `InkWell` e subtítulos

### Detalhes

- Padding unificado em `ListView(padding: EdgeInsets.all(16))` — removido `Padding` externo redundante
- `InkWell` com `borderRadius: BorderRadius.circular(12)` para ripple respeitando os cantos arredondados do `Card`
- Subtítulo adicionado via `Column` com `MainAxisAlignment.center` e `CrossAxisAlignment.start`; cor `colorScheme.onSurfaceVariant` para hierarquia visual sem hardcode
- `onTap` removido por enquanto — linter flagou parâmetro opcional nunca usado; será adicionado de volta ao implementar as telas de destino
