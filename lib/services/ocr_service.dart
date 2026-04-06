import 'package:flutter/services.dart';

const _channel = MethodChannel('frota_facil/ocr');

/// Envia [imagePath] para o canal nativo e retorna o texto extraído.
/// Lança [PlatformException] se o nativo reportar erro.
Future<String> extractTextFromImage(String imagePath) async {
  final result = await _channel.invokeMethod<String>(
    'extractText',
    {'imagePath': imagePath},
  );
  return result ?? '';
}
