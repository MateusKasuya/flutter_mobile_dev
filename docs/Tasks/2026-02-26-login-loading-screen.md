---
tags: [task]
date: 2026-02-26
status: concluída
branch: feat/login-loading-screen
---

# Task — Tela de loading durante chamada da API de login

[[Home]]

---

## Contexto

Atualmente, enquanto a API de login é chamada, o único indicador de loading é um pequeno `CircularProgressIndicator` dentro do botão "Entrar". Isso é pouco visível e não bloqueia a interação do usuário com o formulário. A ideia é exibir um **overlay de loading** cobrindo a tela inteira, com um indicador de carregamento centralizado, impedindo interações enquanto aguarda o retorno da API.

## Objetivo

Ao disparar o login, exibir um overlay escuro com `CircularProgressIndicator` e textos informativos cobrindo a tela inteira (incluindo AppBar). O overlay bloqueia todas as interações até o retorno da API (sucesso ou erro).

---

## Branch

```bash
git checkout -b feat/login-loading-screen
```

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `lib/screens/login_screen.dart` — substituir `Scaffold` como raiz por `Stack(Scaffold, overlay)`

---

## Implementação

### Passo 1 — Envolver o Scaffold com Stack

O `build` retorna um `Stack` no lugar do `Scaffold`. O `Scaffold` vira o primeiro filho e o overlay o segundo, garantindo cobertura total da tela (incluindo AppBar):

```dart
return Stack(
  children: [
    Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(...), // formulário sem alterações
    ),
    if (_isLoading)
      Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.black.withValues(alpha: 0.8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
                const SizedBox(height: 30),
                const Text('Realizando login...',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 15),
                const Text('Aguarde enquanto autenticamos',
                  style: TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w500, letterSpacing: 0.3),
                  textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
  ],
);
```

- `Material(type: MaterialType.transparency)` é necessário para que os `Text` dentro do overlay herdem o tema de tipografia corretamente. Sem ele, o Flutter aplica o `DefaultTextStyle` padrão (amarelo sublinhado) pois o overlay está fora da árvore do `Scaffold`.

### Passo 2 — Simplificar o botão

Remover o `CircularProgressIndicator` de dentro do `ElevatedButton`. O botão continua desabilitado durante loading, mas exibe sempre o texto "Entrar":

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _handleLogin,
  child: const Text('Entrar'),
),
```

---

## Critérios de aceite

- [x] Overlay escuro com `CircularProgressIndicator` e textos aparece durante chamada à API
- [x] Overlay cobre a tela inteira incluindo AppBar
- [x] Overlay bloqueia interações com o formulário enquanto loading
- [x] Botão "Entrar" fica desabilitado e exibe apenas texto (sem spinner interno)
- [x] Overlay desaparece após sucesso ou erro da API
- [x] `flutter analyze` sem erros

---

## Links relacionados

- [[DevLog/]]
- [[Decisoes/]]
