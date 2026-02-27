---
tags: [task]
date: 2026-02-26
status: concluída
branch: feat/login-modularization
---

# Task — Modularizar a tela de login

[[Home]]

---

## Contexto

`login_screen.dart` concentra toda a lógica e UI em ~185 linhas: formulário, campos com validação e máscara, toggle de senha, checkbox de lembrar credenciais, lógica de login, loading e navegação. Conforme o app cresce, isso dificulta manutenção e reuso.

## Objetivo

Extrair os campos de formulário para componentes em `lib/components/`, mantendo comportamento idêntico ao atual. A `LoginScreen` fica responsável apenas por: estado do form, lógica de login (`_handleLogin`), credenciais salvas e navegação.

---

## Branch

```bash
git checkout -b feat/login-modularization
```

## Arquivos a criar

- `lib/components/cpf_field.dart` — campo CPF com máscara e validação
- `lib/components/password_field.dart` — campo senha com toggle de visibilidade (stateful)
- `lib/components/remember_me_checkbox.dart` — checkbox "lembrar usuário e senha"

## Arquivos a modificar

- `lib/screens/login_screen.dart` — substituir campos inline pelos componentes extraídos e remover `_obscurePassword` do state

---

## Implementação

### Passo 1 — Extrair CpfField

Criar `lib/components/cpf_field.dart`:
- Widget **stateless** que recebe `TextEditingController controller`
- Contém o `TextFormField` com `maskFormatter`, `InputDecoration` e validação de CPF
- Importa `cpf_validator.dart` internamente

```dart
class CpfField extends StatelessWidget {
  final TextEditingController controller;

  const CpfField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [maskFormatter],
      decoration: const InputDecoration(
        labelText: 'CPF',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe o CPF';
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.length < 11) return 'CPF incompleto';
        if (!isValidCpf(value)) return 'CPF inválido';
        return null;
      },
    );
  }
}
```

### Passo 2 — Extrair PasswordField

Criar `lib/components/password_field.dart`:
- Widget **stateful** que recebe `TextEditingController controller`
- Gerencia `_obscurePassword` internamente — removendo esse estado do `_LoginScreenState`

```dart
class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Senha',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe a senha';
        return null;
      },
    );
  }
}
```

### Passo 3 — Extrair RememberMeCheckbox

Criar `lib/components/remember_me_checkbox.dart`:
- Widget **stateless** que recebe `bool value` e `ValueChanged<bool?> onChanged`

```dart
class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RememberMeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text('Lembrar usuário e senha'),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
```

### Passo 4 — Refatorar LoginScreen

Em `lib/screens/login_screen.dart`:
- Remover `bool _obscurePassword` do state (movido para `PasswordField`)
- Importar os 3 componentes novos
- Substituir os widgets inline pelos componentes

O `Column` interno ao `Form` fica:

```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    CpfField(controller: _cpfController),
    const SizedBox(height: 16),
    PasswordField(controller: _passwordController),
    RememberMeCheckbox(
      value: _rememberMe,
      onChanged: (v) => setState(() => _rememberMe = v ?? false),
    ),
    const SizedBox(height: 8),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: const Text('Entrar'),
      ),
    ),
  ],
)
```

O restante do `build` (logo, `Expanded`, `Center`, `LoadingOverlay`) permanece sem alterações.

### Passo 5 — Validar

- Rodar `flutter analyze` sem erros
- Rodar `flutter test` — todos os testes existentes devem continuar passando sem modificação

---

## Critérios de aceite

- [x] `CpfField`, `PasswordField` e `RememberMeCheckbox` em `lib/components/`
- [x] `PasswordField` gerencia `_obscurePassword` internamente
- [x] `_obscurePassword` removido do `_LoginScreenState`
- [x] `LoginScreen` usa os componentes extraídos (~185 → ~148 linhas)
- [x] Comportamento idêntico ao atual (máscara, validação, toggle, checkbox)
- [x] Testes existentes passam sem modificação (15/15)
- [x] `flutter analyze` sem erros

---

## Links relacionados

- [[DevLog/]]
- [[Decisoes/]]
