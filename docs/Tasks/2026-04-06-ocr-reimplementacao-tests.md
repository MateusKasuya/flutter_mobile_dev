---
tags: [tipo/task, dominio/frota]
date: 2026-04-06
status: planejada
branch: feat/ocr-reimplementacao-tests
---

# Task — Testes da integração OCR com Tesseract

[[Tasks/_index|Tasks]]

---

## Contexto

A task `2026-04-06-ocr-reimplementacao-tesseract` reimplementa o OCR de placa usando Tesseract. Precisamos de testes de widget para garantir que a integração na `FrotaBuscaScreen` funciona corretamente — sem depender do Tesseract real (que precisa de assets e câmera).

Os testes unitários do `extractPlaca` já existem em `test/utils/placa_utils_test.dart`. Aqui cobrimos apenas a integração do fluxo na tela.

## Objetivo

Ao final desta task:
- Testes de widget verificam o fluxo completo: câmera → OCR → preenchimento do campo
- Mocks isolam `ImagePicker` e `FlutterTesseractOcr` para testes determinísticos
- Cenários de sucesso, cancelamento e erro estão cobertos

---

## Branch

```bash
git checkout -b feat/ocr-reimplementacao-tests
```

## Arquivos a criar

- `test/screens/frota_busca_ocr_test.dart` — testes de widget do fluxo OCR

## Arquivos a modificar

- `lib/screens/frota_busca_screen.dart` — injetar dependências de OCR para permitir mocks nos testes

---

## Implementação

### Passo 1 — Injetar dependências de OCR na FrotaBuscaScreen

Para testar o fluxo OCR sem câmera real ou Tesseract, precisamos injetar as funções de captura e OCR como parâmetros opcionais:

```dart
class FrotaBuscaScreen extends StatefulWidget {
  final Future<Veiculo> Function(String token, String placa) fetchFn;
  final Future<XFile?> Function() pickImageFn;
  final Future<String> Function(String imagePath) ocrFn;

  const FrotaBuscaScreen({
    super.key,
    this.fetchFn = frota_service.fetchVeiculo,
    this.pickImageFn = _defaultPickImage,
    this.ocrFn = _defaultOcr,
  });
}
```

Adicionar as funções default fora da classe:

```dart
Future<XFile?> _defaultPickImage() async {
  final picker = ImagePicker();
  return picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.rear,
    imageQuality: 85,
  );
}

Future<String> _defaultOcr(String imagePath) async {
  return FlutterTesseractOcr.extractText(
    imagePath,
    language: 'eng',
    args: {
      "psm": "6",
      "preserve_interword_spaces": "1",
    },
  );
}
```

Atualizar `_scanPlaca()` para usar as funções injetadas:

```dart
Future<void> _scanPlaca() async {
  final photo = await widget.pickImageFn();
  if (photo == null) return;

  setState(() => _isLoading = true);

  try {
    final ocrText = await widget.ocrFn(photo.path);
    final placa = extractPlaca(ocrText);

    if (placa != null) {
      _placaController.text = placa;
      showSuccessToast('Placa detectada: $placa');
    } else {
      showErrorToast('Nenhuma placa encontrada na imagem');
    }
  } catch (e) {
    showErrorToast('Erro ao processar imagem: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

**Explicação:**
- O padrão é o mesmo já usado em `fetchFn` — injeção de dependência via construtor com valor default
- Em produção, usa `_defaultPickImage` e `_defaultOcr` (comportamento real)
- Nos testes, passamos funções mock que retornam valores controlados
- `XFile` é o tipo retornado pelo `image_picker` — representa um arquivo no dispositivo

---

### Passo 2 — Criar testes de widget

```dart
// test/screens/frota_busca_ocr_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/screens/frota_busca_screen.dart';

Widget _buildTestWidget({
  required Future<XFile?> Function() pickImageFn,
  required Future<String> Function(String) ocrFn,
}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider()..setToken('test-token'),
    child: MaterialApp(
      home: FrotaBuscaScreen(
        fetchFn: (_, __) async => throw Exception('não deve buscar'),
        pickImageFn: pickImageFn,
        ocrFn: ocrFn,
      ),
    ),
  );
}

void main() {
  group('OCR scan placa', () {
    testWidgets('preenche campo quando placa Mercosul é detectada',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'BRASIL\nABC1D23\nSAO PAULO SP',
      ));

      // Tap no FAB de câmera
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Verifica que o campo foi preenchido com a placa extraída
      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(
        (textField.controller)?.text,
        equals('ABC1D23'),
      );
    });

    testWidgets('preenche campo quando placa antiga é detectada',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'ABC1234',
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(
        (textField.controller)?.text,
        equals('ABC1234'),
      );
    });

    testWidgets('não preenche campo quando câmera é cancelada',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => null, // usuário cancelou
        ocrFn: (_) async => 'ABC1D23',
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(
        (textField.controller)?.text,
        isEmpty,
      );
    });

    testWidgets('mostra toast quando nenhuma placa é encontrada',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'texto sem placa nenhuma',
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Campo deve continuar vazio
      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(
        (textField.controller)?.text,
        isEmpty,
      );
    });

    testWidgets('campo fica vazio quando OCR lança erro',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => throw Exception('Tesseract error'),
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Campo deve continuar vazio (erro tratado gracefully)
      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(
        (textField.controller)?.text,
        isEmpty,
      );
    });
  });
}
```

**Explicação dos testes:**
- `_buildTestWidget` — helper que monta o widget com Provider e mocks injetados. O `fetchFn` lança exception porque nenhum teste deve acionar busca.
- **Placa Mercosul detectada** — simula OCR retornando texto com "BRASIL", placa e cidade. Verifica que `extractPlaca` extraiu corretamente e preencheu o campo.
- **Placa antiga detectada** — mesmo fluxo com formato antigo `ABC1234`.
- **Câmera cancelada** — `pickImageFn` retorna `null`. O campo deve permanecer vazio e nenhum erro deve ocorrer.
- **Nenhuma placa encontrada** — OCR retorna texto genérico sem padrão de placa. Campo permanece vazio.
- **Erro no OCR** — simula falha do Tesseract. O app não deve crashar, apenas mostra toast de erro.

---

## Critérios de aceite

- [ ] `FrotaBuscaScreen` aceita `pickImageFn` e `ocrFn` como parâmetros opcionais
- [ ] Comportamento default (produção) usa `ImagePicker` e `FlutterTesseractOcr`
- [ ] Teste: placa Mercosul detectada → campo preenchido
- [ ] Teste: placa antiga detectada → campo preenchido
- [ ] Teste: câmera cancelada → campo vazio, sem erro
- [ ] Teste: OCR sem placa → campo vazio
- [ ] Teste: OCR com erro → campo vazio, sem crash
- [ ] `flutter test test/screens/frota_busca_ocr_test.dart` passa
- [ ] `flutter analyze` passa sem erros

---

## Links relacionados

- [[Tasks/2026-04-06-ocr-reimplementacao-tesseract|Task de reimplementação OCR]]
- [[Tasks/2026-03-16-ocr-extract-placa-tests|Testes do extractPlaca (unitários)]]
