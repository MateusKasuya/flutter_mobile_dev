import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/cpf_field.dart';
import '../components/loading_overlay.dart';
import '../components/password_field.dart';
import '../components/remember_me_checkbox.dart';
import '../services/auth_service.dart';
import '../utils/app_toast.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  // loginFn permite trocar a função de login nos testes.
  // Em produção, usa a função real do auth_service automaticamente.
  final Future<String> Function(String cpf, String senha) loginFn;

  // prefs permite injetar SharedPreferences nos testes.
  final SharedPreferences? prefs;

  const LoginScreen({super.key, this.loginFn = login, this.prefs});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = widget.prefs ?? await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    if (remember && mounted) {
      setState(() {
        _rememberMe = true;
        _cpfController.text = prefs.getString('saved_cpf') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      });
    }
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '').trim();
      final token = await widget.loginFn(cpf, _passwordController.text);

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

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(token: token)),
      );
    } catch (e) {
      showErrorToast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      title: 'Realizando login...',
      subtitle: 'Aguarde enquanto autenticamos',
      child: Scaffold(
        appBar: AppBar()),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              SvgPicture.asset(
                'assets/icone_Frota.svg',
                height: 35,
              ),
              Expanded(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
