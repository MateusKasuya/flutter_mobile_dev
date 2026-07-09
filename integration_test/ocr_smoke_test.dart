import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frota_facil_mobile/services/ocr_service.dart';
import 'package:frota_facil_mobile/utils/placa_utils.dart';

// Smoke test do OCR NATIVO — o único código do app que widget test nenhum
// alcança (o handler do MethodChannel 'frota_facil/ocr' é Kotlin/Swift).
//
// Diferente dos testes em test/, os testes de integration_test/ rodam com o
// app REAL instalado num emulador ou aparelho:
//
//   flutter test integration_test/ocr_smoke_test.dart -d <device>
//
// Aqui o canal nativo existe de verdade (MainActivity registra o OcrPlugin),
// então a chamada atravessa Dart → plataforma → ML Kit (Android) / Vision
// (iOS) e volta. O pipeline exercitado é o mesmo do fluxo de escanear placa,
// menos a câmera: imagem em disco → extractTextFromImage → extractPlaca.
//
// A imagem de placa é GERADA pelo teste com o canvas do próprio Flutter em
// vez de um arquivo commitado no repo: o teste controla o conteúdo (dá para
// variar placa e layout) e não dependemos de binário em git.

/// Desenha uma "placa Mercosul" sintética: moldura, faixa com BRASIL no topo
/// (que o extractPlaca deve descartar) e a [placa] em destaque. Retorna o
/// arquivo PNG salvo no diretório temporário do app.
Future<File> _gerarImagemDePlaca(String placa, {String nomeArquivo = 'placa'}) async {
  const largura = 800.0;
  const altura = 400.0;

  // PictureRecorder + Canvas é a API de desenho por trás de todo widget;
  // usá-la direto nos dá um bitmap sem precisar montar árvore de widgets.
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  canvas.drawRect(
    const Rect.fromLTWH(0, 0, largura, altura),
    Paint()..color = Colors.white,
  );
  canvas.drawRect(
    const Rect.fromLTWH(12, 12, largura - 24, altura - 24),
    Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6,
  );

  void desenharTexto(String texto, double fontSize, double y) {
    final painter = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset((largura - painter.width) / 2, y));
  }

  desenharTexto('BRASIL', 44, 36);
  desenharTexto(placa, 150, 140);

  // Converte o desenho em PNG: Picture → Image rasterizada → bytes.
  final picture = recorder.endRecording();
  final image = await picture.toImage(largura.toInt(), altura.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  // Directory.systemTemp aponta para o diretório temporário DO APP no
  // aparelho (sandbox) — mesmo tipo de caminho que o image_picker devolve.
  final file = File(
    '${Directory.systemTemp.path}/ocr_smoke_$nomeArquivo.png',
  );
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  return file;
}

void main() {
  // Versão do binding para testes de integração: conecta o processo de teste
  // ao app real rodando no aparelho (em vez do ambiente simulado do
  // flutter test puro).
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OCR nativo lê placa Mercosul de imagem e extractPlaca a extrai',
      (tester) async {
    // XYZ4H67 evita glifos que OCR confunde (0/O, 1/I, 5/S).
    final arquivo = await _gerarImagemDePlaca('XYZ4H67');

    final textoOcr = await extractTextFromImage(arquivo.path);
    final placa = extractPlaca(textoOcr);

    expect(
      placa,
      'XYZ4H67',
      reason: 'texto bruto devolvido pelo OCR nativo:\n$textoOcr',
    );
  });

  testWidgets('imagem sem placa não produz falso positivo', (tester) async {
    final arquivo = await _gerarImagemDePlaca(
      'NOTA FISCAL',
      nomeArquivo: 'sem_placa',
    );

    final textoOcr = await extractTextFromImage(arquivo.path);

    expect(
      extractPlaca(textoOcr),
      isNull,
      reason: 'texto bruto devolvido pelo OCR nativo:\n$textoOcr',
    );
  });

  testWidgets('caminho de imagem inexistente vira PlatformException',
      (tester) async {
    // Pinha o CONTRATO de erro do plugin nativo (result.error("IMAGE_ERROR"))
    // — é o que o _scanPlaca trata na tela de busca.
    await expectLater(
      extractTextFromImage('/caminho/que/nao/existe.png'),
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'IMAGE_ERROR'),
      ),
    );
  });
}
