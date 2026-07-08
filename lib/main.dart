import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
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
