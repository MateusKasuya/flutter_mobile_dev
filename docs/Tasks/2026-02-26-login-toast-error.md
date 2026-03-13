---
tags: [tipo/task, dominio/login]
date: 2026-02-26
status: concluída
branch: feat/login-toast-error
---

# Task — Toast notification para erros de login

[[Tasks/_index|Tasks]]

---

## Contexto

Atualmente, quando a API de login retorna um status diferente de 202, o erro é exibido como um `Text` vermelho estático abaixo do formulário. Isso é pouco visível e não segue o padrão UX de feedback temporário. A ideia é substituir esse texto por um **toast nativo** via `fluttertoast` que aparece flutuando sobre a tela com a mensagem de erro da API.

## Objetivo

Ao receber um status diferente de 202 da API de login, exibir um toast via `fluttertoast` com a mensagem de erro retornada pela API. Remover o texto de erro estático (`_errorMessage`) que existe atualmente.

---

## Branch

```bash
git checkout -b feat/login-toast-error
```

## Arquivos a criar

- `lib/utils/app_toast.dart` — wrapper do fluttertoast com funções reutilizáveis

## Arquivos a modificar

- `pubspec.yaml` — adicionar dependência `fluttertoast`
- `lib/screens/login_screen.dart` — substituir exibição de erro estático por chamada ao `app_toast`
- `test/screens/login_screen_test.dart` — atualizar teste de erro (toast não é verificável via flutter_test)

---

## Implementação

> Instruções passo a passo para o agente de código

### Passo 1 — Adicionar dependência

Em `pubspec.yaml`, adicionar:

```yaml
dependencies:
  fluttertoast: ^8.2.12
```

Rodar `flutter pub get`.

### Passo 2 — Remover estado `_errorMessage`

Em `lib/screens/login_screen.dart`:
- Remover a variável `String? _errorMessage` do state
- Remover o `setState` inteiro do bloco `catch` (ele só atribuía `_errorMessage`)
- O `setState(() { _isLoading = false; })` no bloco `finally` deve permanecer intacto
- Remover o widget condicional `if (_errorMessage != null) Padding(...)` do `build`

### Passo 3 — Criar `lib/utils/app_toast.dart`

Criar o wrapper com funções nomeadas por intenção:

```dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showErrorToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 5,
    backgroundColor: const Color.fromARGB(255, 227, 108, 108),
    textColor: Colors.white,
  );
}
```

- `gravity: ToastGravity.TOP` — toast aparece no topo da tela
- `timeInSecForIosWeb: 5` — duração explícita para iOS/web
- `backgroundColor` com vermelho suavizado em vez de `Colors.red`
- Centralizar aqui evita repetir a configuração do `fluttertoast` em cada tela.

### Passo 4 — Exibir toast no catch

No bloco `catch` de `_handleLogin`, substituir a atribuição de `_errorMessage` por:

```dart
import '../utils/app_toast.dart';

// No catch:
showErrorToast(e.toString().replaceFirst('Exception: ', ''));
```

Sem necessidade de `context` nem de verificação de `mounted`.

### Passo 5 — Atualizar testes

`fluttertoast` chama código nativo e **não é verificável** via `flutter_test`. O teste de erro deve ser ajustado para verificar apenas que:
- A navegação não ocorreu (ainda está na `LoginScreen`)
- Nenhum widget de erro estático é exibido

```dart
testWidgets('login com falha permanece na LoginScreen', (tester) async {
  await tester.pumpWidget(
    buildApp((_, _) async => throw Exception(mensagemErro)),
  );

  await tester.enterText(find.byType(TextField).first, '07069953925');
  await tester.enterText(find.byType(TextField).last, 'errada');
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  expect(find.byType(LoginScreen), findsOneWidget);
});
```

---

## Critérios de aceite

- [x] Dependência `fluttertoast: ^9.0.0` adicionada ao `pubspec.yaml`
- [x] Arquivo `lib/utils/app_toast.dart` criado com `showErrorToast`
- [x] Nenhum texto de erro estático é exibido na tela de login
- [x] Toast aparece com a mensagem de erro da API quando status ≠ 202
- [x] Toast desaparece automaticamente
- [x] Teste de erro atualizado para verificar permanência na `LoginScreen`
- [x] `flutter test` sem falhas (15/15)
- [x] `flutter analyze` sem erros

---

## Observação sobre testes

`fluttertoast` usa canal de plataforma nativo (MethodChannel). Em ambiente de teste, a chamada é silenciada automaticamente pelo Flutter (sem crash), mas o conteúdo do toast **não pode ser verificado** via `flutter_test`. Para validar a mensagem visualmente, testar no dispositivo/emulador.

---

## Links relacionados

- [[DevLog/]]
- [[Decisoes/]]
