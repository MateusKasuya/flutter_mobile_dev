import 'dart:async';

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
    create: (_) => AuthProvider(),
    child: MaterialApp(
      home: FrotaBuscaScreen(
        fetchFn: (_, _) async => throw Exception('não deve buscar'),
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

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, equals('ABC1D23'));
    });

    testWidgets('preenche campo quando placa antiga é detectada',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'ABC1234',
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, equals('ABC1234'));
    });

    testWidgets('não preenche campo quando câmera é cancelada',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => null,
        ocrFn: (_) async => 'ABC1D23',
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, isEmpty);
    });

    testWidgets('campo fica vazio quando nenhuma placa é encontrada',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'texto sem placa nenhuma',
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, isEmpty);
    });

    testWidgets('campo fica vazio quando OCR lança erro', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => throw Exception('Tesseract error'),
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, isEmpty);
    });

    testWidgets('segundo tap no FAB não dispara scan durante o loading',
        (tester) async {
      // Contamos quantas vezes a câmera foi acionada.
      var pickCount = 0;
      // Completer deixa o OCR "pendente": o Future não resolve até chamarmos
      // complete(). Assim _isLoading permanece true e o FAB fica desabilitado.
      final ocrCompleter = Completer<String>();

      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async {
          pickCount++;
          return XFile('/fake/path.jpg');
        },
        ocrFn: (_) => ocrCompleter.future,
      ));

      // Primeiro tap: aciona a câmera (pickImage resolve) e entra em loading
      // enquanto aguarda o OCR pendente.
      await tester.tap(find.byIcon(Icons.camera_alt));
      // pump() sem settle: processa o pickImage mas não espera o OCR (que trava).
      await tester.pump();
      expect(pickCount, 1);

      // Segundo tap durante o loading: FAB desabilitado, não deve acionar de novo.
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pump();
      expect(pickCount, 1);

      // Finaliza o OCR pendente para não deixar timers/futures em aberto.
      ocrCompleter.complete('texto sem placa nenhuma');
      await tester.pumpAndSettle();
    });
  });
}
