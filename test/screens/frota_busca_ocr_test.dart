import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/screens/frota_busca_screen.dart';

import '../helpers/test_viewport.dart';

Veiculo _makeVeiculo() => const Veiculo(
      placa: 'ABC1D23',
      nroFrota: '001',
      marca: 'Marca Y',
      modelo: 'Modelo X',
      ano: '2020',
      anoModelo: '2021',
      cor: 'Branco',
      tipo: 'Caminhão',
      codEsqEixo: '1',
      pneus: [],
    );

Widget _buildTestWidget({
  required Future<XFile?> Function() pickImageFn,
  required Future<String> Function(String) ocrFn,
  // Default proposital: se um teste NÃO espera busca, um fetchFn que lança
  // deixa a chamada acidental explodir em vez de passar despercebida.
  Future<Veiculo> Function(String, String)? fetchFn,
}) {
  return ChangeNotifierProvider(
    // A busca automática lê o token do provider, então precisamos de um.
    create: (_) => AuthProvider()..setToken('tok'),
    child: MaterialApp(
      home: FrotaBuscaScreen(
        fetchFn:
            fetchFn ?? (_, _) async => throw Exception('busca não esperada'),
        pickImageFn: pickImageFn,
        ocrFn: ocrFn,
      ),
    ),
  );
}

void main() {
  group('OCR scan placa', () {
    testWidgets('preenche campo e dispara busca quando placa Mercosul é detectada',
        (tester) async {
      // A busca navega para a FrotaDetalheScreen, cujo layout de tablet não
      // cabe no viewport padrão de teste (800x600) — força o de celular.
      usePhoneViewport(tester);
      String? placaBuscada;
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'BRASIL\nABC1D23\nSAO PAULO SP',
        fetchFn: (_, placa) async {
          placaBuscada = placa;
          return _makeVeiculo();
        },
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Buscou com a placa lida e navegou para o detalhe (header mostra a
      // placa concatenada com a frota).
      expect(placaBuscada, equals('ABC1D23'));
      expect(find.text('ABC1D23 - Frota 001'), findsOneWidget);
    });

    testWidgets('preenche campo e dispara busca quando placa antiga é detectada',
        (tester) async {
      usePhoneViewport(tester);
      String? placaBuscada;
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'ABC1234',
        fetchFn: (_, placa) async {
          placaBuscada = placa;
          return _makeVeiculo();
        },
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(placaBuscada, equals('ABC1234'));
      expect(find.text('ABC1D23 - Frota 001'), findsOneWidget);
    });

    testWidgets('não preenche campo nem busca quando câmera é cancelada',
        (tester) async {
      var buscou = false;
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => null,
        ocrFn: (_) async => 'ABC1D23',
        fetchFn: (_, _) async {
          buscou = true;
          return _makeVeiculo();
        },
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, isEmpty);
      expect(buscou, isFalse);
    });

    testWidgets('campo fica vazio e não busca quando nenhuma placa é encontrada',
        (tester) async {
      var buscou = false;
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => 'texto sem placa nenhuma',
        fetchFn: (_, _) async {
          buscou = true;
          return _makeVeiculo();
        },
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, isEmpty);
      expect(buscou, isFalse);
    });

    testWidgets('campo fica vazio e não busca quando OCR lança erro',
        (tester) async {
      var buscou = false;
      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) async => throw Exception('Tesseract error'),
        fetchFn: (_, _) async {
          buscou = true;
          return _makeVeiculo();
        },
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller;
      expect(controller?.text, isEmpty);
      expect(buscou, isFalse);
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
      // Texto sem placa: encerra o scan sem disparar a busca automática.
      ocrCompleter.complete('texto sem placa nenhuma');
      await tester.pumpAndSettle();
    });

    testWidgets('desmontar durante o OCR não escreve no controller disposto',
        (tester) async {
      // OCR pendente: o Future não resolve até chamarmos complete(). Isso
      // segura _scanPlaca logo após o await do OCR — exatamente antes do
      // `if (!mounted) return` que protege a escrita no controller.
      final ocrCompleter = Completer<String>();

      await tester.pumpWidget(_buildTestWidget(
        pickImageFn: () async => XFile('/fake/path.jpg'),
        ocrFn: (_) => ocrCompleter.future,
      ));

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pump(); // processa o pickImage; OCR fica pendente

      // Usuário sai da tela: troca toda a árvore, disparando o dispose() do
      // FrotaBuscaScreen (e do _placaController junto).
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // O OCR resolve com uma placa válida DEPOIS do dispose. Sem o guard
      // `if (!mounted)`, _scanPlaca tentaria _placaController.text = placa e
      // lançaria "A TextEditingController was used after being disposed".
      // O mesmo guard também barra a busca automática após o dispose.
      ocrCompleter.complete('ABC1D23');
      await tester.pumpAndSettle();

      // O guard barrou a escrita: nenhuma exceção capturada.
      expect(tester.takeException(), isNull);
    });
  });
}
