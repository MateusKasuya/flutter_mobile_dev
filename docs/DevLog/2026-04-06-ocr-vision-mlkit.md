---
tags: [tipo/devlog, dominio/frota]
date: 2026-04-06
---

# Dev Log — 06/04/2026 — OCR Vision + ML Kit

[[DevLog/_index|DevLog]]

---

## O que foi feito

- Removido `flutter_tesseract_ocr` e o asset `assets/tessdata/` (4 MB desnecessários)
- Criado MethodChannel customizado `frota_facil/ocr` com duas implementações nativas:
  - **iOS**: `OcrPlugin.swift` usando `VNRecognizeTextRequest` do Vision framework
  - **Android**: `OcrPlugin.kt` usando ML Kit (`com.google.mlkit:text-recognition`)
- Criado `lib/services/ocr_service.dart` — wrapper Dart que invoca o canal
- `FrotaBuscaScreen._defaultOcr` atualizado para usar `ocr_service.extractTextFromImage`
- Registrado `OcrPlugin` no AppDelegate (iOS) e no `configureFlutterEngine` do MainActivity (Android)
- Todos os 5 testes de widget passando sem alteração (injeção de `ocrFn` continua funcionando)

## Decisões tomadas

- **Vision framework (iOS) em vez de SwiftyTesseract**: Tesseract no iOS requer assets externos (`eng.traineddata`) em caminho que o SwiftyTesseract não encontra dentro da estrutura de assets Flutter. O Vision framework é nativo, offline, sem assets, disponível desde iOS 13 e com precisão superior.
- **ML Kit (Android) em vez de Tesseract**: ML Kit é a solução recomendada pelo Google para reconhecimento de texto no Android — suporte oficial, modelo bundled, sem configuração extra.
- **MethodChannel `frota_facil/ocr`**: canal único com método `extractText` aceita `{imagePath: String}` e retorna o texto bruto. A lógica de extração de placa continua em `placa_utils.dart` — separação de responsabilidades mantida.
- **`usesLanguageCorrection = false`** no Vision: desativado para não "corrigir" sequências alfanuméricas de placas para palavras reais.

## Problemas resolvidos

- `flutter_tesseract_ocr` + `SwiftyTesseract` não localizava `eng.traineddata` no bundle Flutter → OCR falhava silenciosamente
- Versão do pod (`0.3.4`) desincronizada com a versão pub (`^0.4.30`) — risco latente de incompatibilidade de API nativa/Dart

## Aprendizados

- Em Flutter, a ponte Flutter ↔ nativo é o **MethodChannel**: Flutter chama `channel.invokeMethod('methodName', args)` e o nativo implementa o delegate/handler correspondente. É o "túnel" entre as duas camadas.
- No iOS, o MethodChannel é registrado via `FlutterPluginRegistrar` — o plugin precisa implementar `register(with:)` e ser chamado explicitamente (ou via `GeneratedPluginRegistrant` se embutido num pacote pub).
- O Vision framework executa em background thread — o `result` do Flutter deve ser chamado na completion handler (não no main thread), o que o `VNImageRequestHandler` já garante com `DispatchQueue.global`.
