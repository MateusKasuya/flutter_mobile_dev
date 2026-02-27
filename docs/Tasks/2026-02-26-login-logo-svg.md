---
tags: [task]
date: 2026-02-26
status: concluída
branch: main
---

# Task — Inserir logo SVG de frota na tela de login

[[Home]]

---

## Contexto

A tela de login atualmente não possui identidade visual — apenas campos de formulário. Precisamos exibir o ícone/logo de frota (SVG) no topo da tela para dar identidade ao app.

## Objetivo

Exibir o logo SVG da frota no topo da tela de login, com o formulário centralizado no espaço restante abaixo.

---

## Branch

Implementado diretamente em `main`.

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `pubspec.yaml` — adicionar dependência `flutter_svg` e declarar pasta `assets/`
- `lib/screens/login_screen.dart` — reestruturar layout com logo no topo e formulário centralizado abaixo

---

## Implementação

### Passo 1 — Configurar assets e dependência

Em `pubspec.yaml`:

```yaml
dependencies:
  flutter_svg: ^2.2.3

flutter:
  uses-material-design: true
  assets:
    - assets/
```

### Passo 2 — Reestruturar layout

Substituir o `Column` com `mainAxisAlignment: center` por uma estrutura que posiciona o logo no topo e centraliza o formulário no espaço restante:

```dart
body: Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 24),
      SvgPicture.asset('assets/icone_Frota.svg', height: 35),
      Expanded(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // ocupa só o espaço necessário
              children: [ /* campos */ ],
            ),
          ),
        ),
      ),
    ],
  ),
),
```

- `Expanded` ocupa todo o espaço vertical restante após o logo
- `Center` centraliza o formulário dentro desse espaço
- `mainAxisSize: MainAxisSize.min` no `Column` interno impede que ele tente expandir para toda a altura do `Expanded`

---

## Critérios de aceite

- [x] Logo SVG (`assets/icone_Frota.svg`) exibido no topo da tela
- [x] Formulário centralizado no espaço abaixo do logo
- [x] Dependência `flutter_svg: ^2.2.3` adicionada ao `pubspec.yaml`
- [x] Assets declarados no `pubspec.yaml`
- [x] `flutter analyze` sem erros
- [x] `flutter test` sem falhas (15/15)

---

## Links relacionados

- [[DevLog/]]
- [[Decisoes/]]
