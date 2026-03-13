---
tags: [tipo/devlog, dominio/login]
date: 2026-02-27
---

# Dev Log — 27/02/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-02-26-login-toast-error|Toast notification para erros de login]]

## O que foi feito

- Adicionada dependência `fluttertoast: ^9.0.0` ao `pubspec.yaml`
- Criado `lib/utils/app_toast.dart` com `showErrorToast(String message)` encapsulando a configuração do `fluttertoast`
- Removido estado `_errorMessage` e o widget `Text` de erro estático do `login_screen.dart`
- Bloco `catch` de `_handleLogin` substituído por chamada a `showErrorToast`
- Teste `login com falha exibe mensagem de erro` atualizado para `login com falha permanece na LoginScreen` — verifica apenas que não houve navegação, pois toast usa canal nativo e não é verificável via `flutter_test`

## Decisões tomadas

- **`gravity: ToastGravity.TOP`** — toast no topo para não sobrepor o botão de login
- **`timeInSecForIosWeb: 5`** — duração explícita no iOS (sem isso, usa padrão curto da plataforma)
- **`backgroundColor: Color.fromARGB(255, 227, 108, 108)`** — vermelho suavizado no lugar de `Colors.red`
- **`app_toast.dart` em `utils/`** — toast não é um widget, é uma função helper; `utils/` é mais adequado que `components/`

## Problemas encontrados

- Teste `login com falha exibe mensagem de erro` quebrou após a mudança — esperava `find.text('Credenciais inválidas')` que não existe mais na árvore de widgets. Corrigido ajustando o teste para verificar apenas a permanência na `LoginScreen`.

## Aprendizados

- `fluttertoast` usa `MethodChannel` nativo, portanto não aparece na árvore de widgets do Flutter e não é verificável via `flutter_test`. Em testes, a chamada é silenciada sem crash.
- A separação entre `toastLength` (Android, SHORT/LONG) e `timeInSecForIosWeb` (iOS/web, em segundos) é independente — é possível configurar ambos ou apenas um.

## Próximos passos

- Tasks pendentes: tela de loading, logo SVG, modularização do login
