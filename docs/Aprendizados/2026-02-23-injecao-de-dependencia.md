---
tags: [aprendizado]
date: 2026-02-23
topic: Flutter, testes, arquitetura
---

# Injeção de dependência simples em Flutter

[[Home]]

---

## O que aprendi

Ao invés de chamar uma função diretamente dentro de um widget, podemos recebê-la como parâmetro. Isso é chamado de **injeção de dependência**.

## Por que importa

Permite substituir a função real por uma falsa nos testes, sem precisar de bibliotecas extras. O widget não sabe (nem precisa saber) de onde vem a função — ele só a chama.

## Exemplo prático

```dart
class LoginScreen extends StatefulWidget {
  // Parâmetro opcional — usa a função real por padrão
  final Future<String> Function(String cpf, String senha) loginFn;

  const LoginScreen({super.key, this.loginFn = login});
}
```

No teste, passamos uma função falsa:

```dart
await tester.pumpWidget(
  buildApp((cpf, senha) async => 'token-falso'),
);
```

Em produção, `LoginScreen()` sem argumentos usa a função `login` real automaticamente.

## Referências

- [Flutter Testing docs](https://docs.flutter.dev/testing)

## Links relacionados

- [[DevLog/2026-02-23-login-api]]
