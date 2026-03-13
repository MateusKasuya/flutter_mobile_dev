---
tags: [tipo/task, dominio/splash]
date: 2026-03-05
status: planejada
branch: feat/splash-screen
---

# Task — Splash Screen

[[Tasks/_index|Tasks]]

---

## Contexto

O design do Figma inclui uma splash screen com gradiente #01556F #028480, logo "FROTA" centralizada em branco e texto "por transportefacil.com.br". Atualmente o app abre direto na tela de login. A splash screen serve como apresentacao visual da marca enquanto o app inicializa.

## Objetivo

Tela de splash com gradiente, logo e texto, exibida por alguns segundos antes de navegar automaticamente para a tela de login.

---

## Branch

```bash
git checkout -b feat/splash-screen
```

## Arquivos a criar

- `lib/screens/splash_screen.dart`
- `assets/logo_frota_branco.svg` *(exportar do Figma — logo branca para fundo escuro)*

## Arquivos a modificar

- `lib/main.dart` — trocar `home` de `LoginScreen` para `SplashScreen`
- `pubspec.yaml` — registrar o novo asset SVG (se necessario)

---

## Implementacao

### Passo 1 — Adicionar asset da logo branca

Exportar do Figma a versao branca da logo "FROTA" em SVG e salvar em `assets/logo_frota_branco.svg`.

Verificar que o `pubspec.yaml` ja registra a pasta `assets/`:

```yaml
flutter:
  assets:
    - assets/
```

Se ja estiver registrando a pasta inteira, nenhuma alteracao necessaria.

**Explicacao:**

- **Logo branca separada** — a logo atual (`icone_Frota.svg`) tem cores escuras para fundo claro. Na splash, o fundo eh escuro (teal), entao precisamos de uma versao branca para manter contraste.

---

### Passo 2 — Criar SplashScreen

Criar `lib/screens/splash_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0XFF01556F),
              Color(0xFF01556F),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo_frota_branco.svg',
              height: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'por transportefacil.com.br',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Explicacoes:**

- **`LinearGradient`** — cria um gradiente linear entre duas ou mais cores. `begin: Alignment.topCenter` e `end: Alignment.bottomCenter` fazem o gradiente ir de cima (branco) para baixo (teal), exatamente como no Figma.

- **`Container` com `decoration`** — usamos `Container` em vez de `Scaffold.backgroundColor` porque `backgroundColor` nao aceita gradientes, apenas cores solidas. O `BoxDecoration` permite gradientes, sombras, bordas, etc.

- **`width/height: double.infinity`** — forca o container a ocupar toda a tela. Sem isso, ele encolheria para o tamanho dos filhos.

- **`Future.delayed(Duration(seconds: 2))`** — espera 2 segundos antes de navegar. Tempo suficiente para o usuario ver a marca sem ser irritante. O `await` garante que a navegacao so acontece apos o delay.

- **`Navigator.pushReplacement`** — substitui a splash pela tela de login na pilha de navegacao. O usuario nao consegue voltar para a splash apertando "voltar". Diferente do `push` que empilha.

---

### Passo 3 — Atualizar main.dart

Modificar `lib/main.dart` para abrir na `SplashScreen`:

```dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
```

**O que mudou:**

- Import trocado de `login_screen.dart` para `splash_screen.dart`
- `home` trocado de `LoginScreen()` para `const SplashScreen()`

---

## Criterios de aceite

- [ ] Splash screen exibe gradiente branco → teal de cima para baixo
- [ ] Logo "FROTA" branca centralizada
- [ ] Texto "por transportefacil.com.br" abaixo da logo
- [ ] Apos 2 segundos, navega automaticamente para LoginScreen
- [ ] Usuario nao consegue voltar para splash com botao "voltar"
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-estilizacao-login|Estilizacao do Login]]
- [[DevLog/]]
