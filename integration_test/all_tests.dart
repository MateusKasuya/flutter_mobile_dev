import 'e2e_homolog_test.dart' as e2e_homolog;
import 'fluxo_critico_test.dart' as fluxo_critico;
import 'ocr_smoke_test.dart' as ocr_smoke;

/// Agregador para o Firebase Test Lab.
///
/// O Test Lab executa UM binário por rodada: o APK é compilado com um único
/// arquivo Dart como entry point (via -Ptarget no Gradle). Este arquivo junta
/// todos os integration tests numa suíte só — cada main() abaixo registra os
/// seus testWidgets e tudo roda em sequência no aparelho.
///
/// O nome NÃO termina em _test.dart de propósito: assim o
/// `flutter test integration_test` (modo device do testar.sh) não o enxerga
/// e não executa os mesmos testes duas vezes.
///
/// O E2E de homologação se auto-pula sem credenciais (--dart-define), então
/// no Test Lab ele aparece como "skipped" — inofensivo.
void main() {
  ocr_smoke.main();
  fluxo_critico.main();
  e2e_homolog.main();
}
