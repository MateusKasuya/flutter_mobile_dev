---
tags: [tipo/task, dominio/infra]
date: 2026-03-06
status: planejada
branch: feat/auth-provider
---

# Task — Migrar token para Provider

[[Tasks/_index|Tasks]]

---

## Contexto

Atualmente o token de autenticacao eh passado por construtor de tela em tela: `LoginScreen → HomeScreen(token) → MovimentoScreen(token) → FrotaBuscaScreen(token)`. Isso eh "prop drilling" — telas intermediarias como `MovimentoScreen` carregam o token no construtor sem usa-lo, apenas repassam. Conforme o app cresce (mais telas, mais dados globais), esse padrao nao escala.

O `provider` eh o pacote recomendado pela documentacao oficial do Flutter para gerenciamento de estado. Ele usa `InheritedWidget` por baixo — qualquer tela descendente acessa o estado sem precisar receber via construtor.

## Objetivo

- Token acessivel em qualquer tela via `context.read<AuthProvider>()` sem prop drilling
- Remover `token` dos construtores de `HomeScreen`, `MovimentoScreen` e futuras telas
- Services continuam recebendo token como parametro (funcoes puras, faceis de testar)
- Testes existentes adaptados para funcionar com Provider

---

## Branch

```bash
git checkout -b feat/auth-provider
```

## Arquivos a criar

- `lib/providers/auth_provider.dart`

## Arquivos a modificar

- `pubspec.yaml` — adicionar dependencia `provider`
- `lib/main.dart` — envolver `MaterialApp` com `ChangeNotifierProvider`
- `lib/screens/login_screen.dart` — setar token no provider apos login, remover passagem por construtor
- `lib/screens/home_screen.dart` — ler token do provider, remover `final String token` do construtor
- `lib/screens/movimento_screen.dart` — sem mudancas (nao usa token, nao repassa mais)
- `test/screens/login_screen_test.dart` — envolver com Provider nos testes
- `test/screens/home_screen_test.dart` — envolver com Provider nos testes

---

## Implementacao

### Passo 1 — Adicionar dependencia provider

```bash
flutter pub add provider
```

**Explicacao:**

- **`provider`** — pacote oficial recomendado pelo Flutter para gerenciamento de estado. Usa `InheritedWidget` internamente para propagar dados pela arvore de widgets sem precisar passar por construtor.

---

### Passo 2 — Criar AuthProvider

Criar `lib/providers/auth_provider.dart`:

```dart
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String _token = '';

  String get token => _token;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
}
```

**Explicacoes:**

- **`ChangeNotifier`** — classe base do Flutter que implementa o padrao Observer. Quando chamamos `notifyListeners()`, todos os widgets que estao "ouvindo" esse provider sao reconstruidos. Eh o contrato que o `provider` espera.

- **`_token` privado + getter publico** — encapsulamento. Ninguem de fora pode fazer `authProvider._token = 'x'` diretamente, precisa usar `setToken()`. Isso garante que `notifyListeners()` sempre eh chamado quando o token muda.

- **`import 'package:flutter/foundation.dart'`** — `ChangeNotifier` vive em `foundation.dart`, nao em `material.dart`. Importar `foundation` em vez de `material` eh mais leve — nao traz toda a biblioteca de widgets do Material Design, apenas as classes base do framework.

---

### Passo 3 — Envolver MaterialApp com Provider

Modificar `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        theme: AppTheme.theme,
        home: LoginScreen(),
      ),
    );
  }
}
```

**Explicacoes:**

- **`ChangeNotifierProvider`** — widget do pacote `provider` que cria uma instancia de `AuthProvider` e a disponibiliza para toda a arvore de widgets abaixo dele. O `create: (_) => AuthProvider()` eh chamado uma unica vez (lazy, na primeira leitura).

- **Envolver o `MaterialApp`** — colocar o provider acima do `MaterialApp` garante que TODAS as telas (inclusive as navegadas com `Navigator.push`) tenham acesso ao `AuthProvider`. Se colocassemos abaixo, telas empilhadas via Navigator nao teriam acesso.

---

### Passo 4 — Setar token no LoginScreen apos login

Modificar `lib/screens/login_screen.dart`. Na funcao `_handleLogin`, apos receber o token da API e antes de navegar:

**Antes (linhas 81-86):**
```dart
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(token: token)),
      );
```

**Depois:**
```dart
      if (!mounted) return;

      context.read<AuthProvider>().setToken(token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
```

Adicionar imports no topo:
```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
```

Remover o import de `home_screen.dart`? Nao — ainda precisamos para o `Navigator.push`.

**Explicacoes:**

- **`context.read<AuthProvider>()`** — leitura pontual (one-time) do provider. Usa `read` em vez de `watch` porque estamos dentro de um callback (`_handleLogin`), nao no `build`. A regra eh: `watch` no build (para reagir a mudancas), `read` fora do build (para acessar sem assinar).

- **`const HomeScreen()`** — agora que `HomeScreen` nao recebe `token` no construtor, pode ser `const` novamente. Isso eh uma micro-otimizacao: widgets `const` sao reutilizados pelo framework sem reconstruir.

---

### Passo 5 — Remover token do construtor da HomeScreen

Modificar `lib/screens/home_screen.dart`:

**Antes:**
```dart
class HomeScreen extends StatefulWidget {
  final String token;
  final Future<List<Localizacao>> Function(String token) fetchFn;

  const HomeScreen({
    super.key,
    required this.token,
    this.fetchFn = fetchLocalizacoes
  });
```

**Depois:**
```dart
class HomeScreen extends StatefulWidget {
  final Future<List<Localizacao>> Function(String token) fetchFn;

  const HomeScreen({
    super.key,
    this.fetchFn = fetchLocalizacoes
  });
```

Na funcao `_load`, trocar `widget.token` por leitura do provider:

**Antes:**
```dart
  Future<void> _load() async {
    try {
      final data = await widget.fetchFn(widget.token);
```

**Depois:**
```dart
  Future<void> _load() async {
    try {
      final token = context.read<AuthProvider>().token;
      final data = await widget.fetchFn(token);
```

Adicionar imports no topo:
```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
```

Na navegacao do FAB para `MovimentoScreen`, remover passagem de token (ja nao precisa):

**Antes (se houvesse):**
```dart
MaterialPageRoute(builder: (_) => MovimentoScreen(token: widget.token)),
```

**Depois (manter como esta):**
```dart
MaterialPageRoute(builder: (_) => const MovimentoScreen()),
```

**Explicacao:**

- **`context.read<AuthProvider>().token`** — busca o token diretamente do provider. O `context` em um `State` refere-se ao `BuildContext` deste widget na arvore. Como o `ChangeNotifierProvider` esta acima (no `main.dart`), o `read` encontra a instancia.

- **Services continuam recebendo token como parametro** — `fetchFn(token)` ainda recebe o token explicitamente. Nao fazemos o service depender do provider. Isso mantem os services como funcoes puras, sem dependencia de `BuildContext`, faceis de testar isoladamente.

---

### Passo 6 — Adaptar testes do LoginScreen

Modificar `test/screens/login_screen_test.dart`. O helper `buildApp` precisa envolver com Provider:

**Antes:**
```dart
Widget buildApp(Future<String> Function(String, String) loginFn, {SharedPreferences? prefs}) {
  return MaterialApp(
    home: LoginScreen(loginFn: loginFn, prefs: prefs),
  );
}
```

**Depois:**
```dart
Widget buildApp(Future<String> Function(String, String) loginFn, {SharedPreferences? prefs}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: MaterialApp(
      home: LoginScreen(loginFn: loginFn, prefs: prefs),
    ),
  );
}
```

Adicionar imports:
```dart
import 'package:provider/provider.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
```

**Explicacao:**

- **Provider no teste** — como o `LoginScreen` agora chama `context.read<AuthProvider>()` no `_handleLogin`, o provider precisa existir na arvore do teste. Sem isso, daria `ProviderNotFoundException`. Criamos uma instancia nova e isolada para cada teste.

---

### Passo 7 — Adaptar testes da HomeScreen

Modificar `test/screens/home_screen_test.dart`. Envolver com Provider e setar token:

**Antes:**
```dart
home: HomeScreen(token: 'test-token', fetchFn: fetchFn),
```

**Depois:**
```dart
home: ChangeNotifierProvider(
  create: (_) => AuthProvider()..setToken('test-token'),
  child: HomeScreen(fetchFn: fetchFn),
),
```

Adicionar imports:
```dart
import 'package:provider/provider.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
```

**Explicacoes:**

- **`AuthProvider()..setToken('test-token')`** — operador cascade (`..`). Cria o `AuthProvider`, chama `setToken` nele, e retorna o proprio `AuthProvider` (nao o retorno do `setToken`). Util para inicializar um objeto em uma unica expressao.

- **`ChangeNotifierProvider` no teste** — mesmo principio do passo anterior. A `HomeScreen` vai fazer `context.read<AuthProvider>().token` dentro de `_load`, entao o provider precisa estar na arvore com o token ja setado.

---

## Criterios de aceite

- [ ] Pacote `provider` adicionado ao `pubspec.yaml`
- [ ] `AuthProvider` criado com `setToken` e getter `token`
- [ ] `ChangeNotifierProvider` envolve o `MaterialApp` no `main.dart`
- [ ] `LoginScreen` seta token no provider apos login bem-sucedido
- [ ] `HomeScreen` le token do provider (sem `token` no construtor)
- [ ] `MovimentoScreen` nao recebe e nao repassa token
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` — todos os testes passam
- [ ] Nenhum service foi alterado (continuam recebendo token como parametro)

---

## Links relacionados

- [[Tasks/2026-03-05-frota-busca-placa|Tela de busca por placa]] — sera simplificada por esta task (le token do provider)
- [[DevLog/]]
- [[Decisoes/]]
