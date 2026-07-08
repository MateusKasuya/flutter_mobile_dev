import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_text_styles.dart';
import 'home_screen.dart';
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
    _decideRotaInicial();
  }

  Future<void> _decideRotaInicial() async {
    // Mantém a splash visível por 2s (branding) enquanto decidimos a rota.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Carrega o token persistido: havendo sessão salva, pula o login e vai
    // direto pra Home (o botão "Sair" na Home é a saída se a sessão expirou).
    final auth = context.read<AuthProvider>();
    await auth.loadToken();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            auth.isAuthenticated ? const HomeScreen() : LoginScreen(),
      ),
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
            colors: [Color(0xFF01556F), Color(0xFF028480)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo_frota_branco.svg',
              height: 86.28,
              width: 108,
            ),
            const SizedBox(height: 19),
            Text(
              'por transportefacil.com.br',
              textAlign: TextAlign.center,
              style: AppTextStyles.splashTagline,
            ),
          ],
        ),
      ),
    );
  }
}
