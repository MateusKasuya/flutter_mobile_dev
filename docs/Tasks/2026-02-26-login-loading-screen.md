---
tags: [tipo/task, dominio/login]
date: 2026-02-26
status: concluída
branch: feat/login-loading-screen
---

# Task — Tela de loading durante chamada da API de login

[[Tasks/_index|Tasks]]

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

- `lib/components/loading_overlay.dart` — widget reutilizável com `title` (obrigatório) e `subtitle` (opcional)

## Arquivos a modificar

- `lib/screens/login_screen.dart` — usar `LoadingOverlay` no lugar do `Scaffold` como raiz

---

## Implementação

### Passo 1 — Criar `lib/components/loading_overlay.dart`

Widget genérico que recebe `child`, `isLoading`, `title` e `subtitle` opcional:

```dart
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String title;
  final String? subtitle;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
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
                    Text(title, style: const TextStyle(...)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 15),
                      Text(subtitle!, style: const TextStyle(...)),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

- `Material(type: MaterialType.transparency)` é necessário para que os `Text` herdem o tema corretamente fora da árvore do `Scaffold`.
- `subtitle` condicional com spread operator `...[]` para renderizar apenas quando fornecido.

### Passo 2 — Usar LoadingOverlay no login

```dart
return LoadingOverlay(
  isLoading: _isLoading,
  title: 'Realizando login...',
  subtitle: 'Aguarde enquanto autenticamos',
  child: Scaffold(...),
);
```

### Passo 3 — Simplificar o botão

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
- [x] `LoadingOverlay` aceita `title` e `subtitle` opcional como parâmetros
- [x] `flutter analyze` sem erros
- [x] `flutter test` sem falhas (15/15)

---

## Links relacionados

- [[DevLog/]]
- [[Decisoes/]]
