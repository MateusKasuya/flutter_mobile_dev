import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_http_client.dart';
import 'theme/app_theme.dart';

/// Chave global do Navigator. Diferente de `Navigator.of(context)`, ela dá
/// acesso à navegação sem precisar de um `BuildContext` — usamos isso no
/// tratamento de sessão expirada (401), que nasce na camada de rede, longe de
/// qualquer widget. Passada em `MaterialApp(navigatorKey: ...)`.
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // ensureInitialized() garante que o binding do Flutter esteja pronto antes
  // de qualquer código que use plataforma/assets rodar fora do runApp.
  // É obrigatório quando fazemos trabalho síncrono antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Por padrão o pacote google_fonts baixa as fontes pela internet no primeiro
  // uso; até o download terminar, o app renderiza com a fonte padrão. Como
  // empacotamos os .ttf da Montserrat em assets/fonts/, desligamos o fetch em
  // runtime: assim o google_fonts sempre usa o arquivo local (funciona offline
  // e o texto já aparece na fonte certa no primeiro launch, sem rede).
  GoogleFonts.config.allowRuntimeFetching = false;

  // Registra a licença OFL da Montserrat no inventário de licenças do app
  // (acessível em "about"/licenças). É exigido pela licença por empacotarmos
  // os arquivos de fonte. addLicense recebe uma função que emite as entradas.
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });

  runApp(const MainApp());
}

// StatefulWidget para registrar o handler de sessão expirada uma única vez em
// initState (em vez de a cada build).
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // Registra o que fazer quando o AuthHttpClient detectar um 401 no meio da
    // sessão: limpar o token e voltar pro login, descartando todo o histórico.
    sessionExpiredHandler = () {
      // currentContext é o contexto do Navigator, que fica ABAIXO do
      // ChangeNotifierProvider — então enxerga o AuthProvider.
      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;
      Provider.of<AuthProvider>(ctx, listen: false).clearToken();
      // addPostFrameCallback adia a navegação para depois do frame atual: o
      // 401 é detectado dentro do ciclo de resposta HTTP, e navegar ali no
      // meio pode conflitar com builds em andamento. Rodar após o frame é
      // seguro.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
    };
  }

  @override
  void dispose() {
    sessionExpiredHandler = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: AppTheme.theme,
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
