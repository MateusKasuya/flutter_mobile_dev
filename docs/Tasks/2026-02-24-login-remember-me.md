---
tags: [tipo/task, dominio/login]
date: 2026-02-24
status: planejada
branch: feat/login-remember-me
---

# Task — Checkbox "Lembrar usuário e senha"

[[Tasks/_index|Tasks]]

---

## Contexto

O usuário precisa digitar CPF e senha toda vez que abre o app. Para frotas onde o mesmo motorista usa o mesmo dispositivo diariamente, isso é fricção desnecessária. Um checkbox de "lembrar-me" resolve isso persistindo as credenciais localmente.

## Objetivo

- Checkbox "Lembrar usuário e senha" na tela de login
- Se marcado e login bem-sucedido, CPF e senha são salvos localmente
- Ao reabrir o app, campos são preenchidos automaticamente e checkbox já marcado
- Se desmarcado, credenciais salvas são removidas

---

## Branch

```bash
git checkout -b feat/login-remember-me
```

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `pubspec.yaml` (adicionar `shared_preferences`)
- `lib/screens/login_screen.dart`

---

## Implementação

> Instruções passo a passo para o agente de código (Cursor, Claude Code, etc.)

### Passo 1 — Adicionar shared_preferences

Adicionar ao `pubspec.yaml`:
```yaml
shared_preferences: ^2.2.0
```
Rodar `flutter pub get`.

### Passo 2 — Injetar SharedPreferences no LoginScreen

Adicionar parâmetro opcional ao `LoginScreen` para facilitar testes:
```dart
final SharedPreferences? prefs;
const LoginScreen({super.key, this.loginFn = login, this.prefs});
```

### Passo 3 — Carregar credenciais no initState

No `initState`, carregar do `SharedPreferences`:
```dart
void _loadSavedCredentials() async {
  final prefs = widget.prefs ?? await SharedPreferences.getInstance();
  final remember = prefs.getBool('remember_me') ?? false;
  if (remember) {
    setState(() {
      _rememberMe = true;
      _cpfController.text = prefs.getString('saved_cpf') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
    });
  }
}
```

### Passo 4 — Adicionar CheckboxListTile

Entre o campo de senha e o botão "Entrar", adicionar:
```dart
CheckboxListTile(
  title: const Text('Lembrar usuário e senha'),
  value: _rememberMe,
  onChanged: (value) => setState(() => _rememberMe = value ?? false),
  controlAffinity: ListTileControlAffinity.leading,
  contentPadding: EdgeInsets.zero,
)
```

### Passo 5 — Salvar ou limpar no _handleLogin

Após login bem-sucedido (antes do `Navigator.pushReplacement`):
```dart
final prefs = widget.prefs ?? await SharedPreferences.getInstance();
if (_rememberMe) {
  await prefs.setBool('remember_me', true);
  await prefs.setString('saved_cpf', _cpfController.text);
  await prefs.setString('saved_password', _passwordController.text);
} else {
  await prefs.remove('remember_me');
  await prefs.remove('saved_cpf');
  await prefs.remove('saved_password');
}
```

---

## Critérios de aceite

- [ ] Checkbox "Lembrar usuário e senha" visível na tela de login
- [ ] Marcar checkbox + login → credenciais persistidas
- [ ] Reabrir app → campos preenchidos e checkbox marcado
- [ ] Desmarcar checkbox + login → credenciais removidas
- [ ] `SharedPreferences` injetável para testes
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` todos passando

---

## Links relacionados

- [[Tasks/2026-02-24-login-password-toggle|Task 3 — Toggle de senha]]
- [[Tasks/2026-02-24-login-fields-tests|Task 5 — Testes completos]]
