package com.example.frota_facil_mobile;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

/**
 * Ponte entre o mundo de testes do Android e os integration tests do Flutter.
 *
 * O Firebase Test Lab (e o `gradlew connectedAndroidTest`) só sabem executar
 * testes de INSTRUMENTAÇÃO Android — classes JUnit como esta. O
 * FlutterTestRunner (do pacote integration_test) abre a MainActivity real e
 * repassa a execução para os testWidgets do arquivo Dart apontado no build
 * via -Ptarget (integration_test/all_tests.dart), reportando cada teste
 * Flutter como um teste JUnit.
 */
@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<MainActivity> rule =
      new ActivityTestRule<>(MainActivity.class, true, false);
}
