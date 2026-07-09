import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/cpf_field.dart';
import '../components/loading_overlay.dart';
import '../components/password_field.dart';
import '../components/remember_me_checkbox.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/credential_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/breakpoints.dart';
import '../utils/app_toast.dart';
import '../utils/friendly_error.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  // loginFn permite trocar a função de login nos testes.
  // Em produção, usa a função real do auth_service automaticamente.
  final Future<String> Function(String cpf, String senha) loginFn;

  // prefs permite injetar SharedPreferences nos testes.
  final SharedPreferences? prefs;

  // credentialStorage guarda a senha do "lembrar-me" com segurança
  // (Keystore/Keychain). Injetável para usar uma versão em memória nos testes.
  final CredentialStorage credentialStorage;

  const LoginScreen({
    super.key,
    this.loginFn = login,
    this.prefs,
    this.credentialStorage = const SecureCredentialStorage(),
  });

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
    if (!remember) return;

    final cpf = prefs.getString('saved_cpf') ?? '';
    // A senha vem do armazenamento seguro (Keystore/Keychain), nunca do
    // SharedPreferences.
    final senha = await widget.credentialStorage.readPassword() ?? '';

    // Depois dos awaits acima a tela pode já ter sido descartada.
    if (!mounted) return;
    setState(() {
      _rememberMe = true;
      _cpfController.text = cpf;
      _passwordController.text = senha;
    });
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
        // Senha vai para o armazenamento seguro, não para o SharedPreferences.
        await widget.credentialStorage.savePassword(_passwordController.text);
        // Limpa qualquer senha em texto puro deixada por versões anteriores.
        await prefs.remove('saved_password');
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_cpf');
        await prefs.remove('saved_password');
        await widget.credentialStorage.deletePassword();
      }

      if (!mounted) return;

      context.read<AuthProvider>().setToken(token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      showErrorToast(friendlyError(e));
    } finally {
      // O finally roda mesmo após o `if (!mounted) return` do try, então
      // precisa do próprio guard: sem ele, um setState após dispose lançaria
      // "setState() called after dispose()" (ex.: se a tela for fechada durante
      // o await do login).
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      title: 'Realizando login...',
      subtitle: 'Aguarde enquanto autenticamos',
      child: Scaffold(
        backgroundColor: AppColors.gradientEnd,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= kTabletBreakpoint;
            return isTablet
                ? _buildTabletLayout()
                : _buildPhoneLayout(constraints);
          },
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BoxConstraints constraints) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 38),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: _buildFormContent()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF01556F), Color(0xFF028480)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              width: 420,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 40,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildFormContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/logo_horizontal.svg',
            height: 22,
            width: 177,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 324,
            child: Text(
              'Entre na sua conta\nFrota!',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text('CPF', style: AppTextStyles.label),
            ),
          ),
          const SizedBox(height: 8),
          CpfField(controller: _cpfController),
          const SizedBox(height: 19),
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text('Senha', style: AppTextStyles.label),
            ),
          ),
          const SizedBox(height: 8),
          PasswordField(controller: _passwordController),
          const SizedBox(height: 25),
          RememberMeCheckbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
          ),
          const SizedBox(height: 58),
          SizedBox(
            width: 300,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(56),
                ),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: Text('Entrar', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(height: 19),
          Text(
            'por transportefacil.com.br',
            textAlign: TextAlign.center,
            style: AppTextStyles.footer,
          ),
        ],
      ),
    );
  }
}
