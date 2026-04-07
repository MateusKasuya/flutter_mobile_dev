---
tags: [tipo/task, dominio/frota]
date: 2026-04-06
status: concluída
branch: feat/ocr-vision-mlkit
---

# Task — OCR de placa com Vision (iOS) e ML Kit (Android) via MethodChannel

[[Tasks/_index|Tasks]]

---

## Contexto

A implementação anterior com `flutter_tesseract_ocr` falhou em produção: o SwiftyTesseract (biblioteca nativa iOS do pacote) não localizava o `eng.traineddata` dentro da estrutura de assets Flutter (`Frameworks/App.framework/flutter_assets/tessdata/`). O OCR lançava exceção silenciosa no iOS.

A solução é usar um **MethodChannel customizado** `frota_facil/ocr` que chama implementações nativas verdadeiras:
- **iOS**: `VNRecognizeTextRequest` do Vision framework (nativo Apple, sem assets extras)
- **Android**: `TextRecognition` do ML Kit (suporte oficial Google, modelo bundled)

## Objetivo

- OCR funciona em dispositivos iOS e Android reais
- Sem assets de tessdata no bundle
- Interface Dart inalterada (`ocrFn(imagePath) → String`)
- Testes de widget continuam passando (injeção de `ocrFn` mantida)

---

## Branch

```bash
git checkout -b feat/ocr-vision-mlkit
```

## Arquivos criados

- `ios/Runner/OcrPlugin.swift` — plugin Swift com Vision framework
- `android/app/src/main/kotlin/.../OcrPlugin.kt` — plugin Kotlin com ML Kit
- `lib/services/ocr_service.dart` — wrapper Dart do MethodChannel

## Arquivos modificados

- `ios/Runner/AppDelegate.swift` — registrar `OcrPlugin`
- `android/app/src/main/kotlin/.../MainActivity.kt` — registrar `OcrPlugin` via `configureFlutterEngine`
- `android/app/build.gradle.kts` — adicionar dependência `com.google.mlkit:text-recognition:16.0.1`
- `lib/screens/frota_busca_screen.dart` — `_defaultOcr` usa `ocr_service.extractTextFromImage`
- `pubspec.yaml` — remove `flutter_tesseract_ocr` e `assets/tessdata/`

---

## Implementação

### iOS — OcrPlugin.swift

```swift
import Flutter
import Vision

class OcrPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "frota_facil/ocr",
      binaryMessenger: registrar.messenger()
    )
    let instance = OcrPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "extractText" else {
      result(FlutterMethodNotImplemented); return
    }
    guard let args = call.arguments as? [String: Any],
          let imagePath = args["imagePath"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "imagePath obrigatório", details: nil)); return
    }

    let fileUrl = URL(fileURLWithPath: imagePath)
    guard let image = CIImage(contentsOf: fileUrl) else {
      result(FlutterError(code: "IMAGE_ERROR", message: "Não foi possível carregar a imagem", details: nil)); return
    }

    let request = VNRecognizeTextRequest { req, error in
      if let error = error {
        result(FlutterError(code: "OCR_ERROR", message: error.localizedDescription, details: nil)); return
      }
      let observations = req.results as? [VNRecognizedTextObservation] ?? []
      let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
      result(text)
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false  // evita "corrigir" placas para palavras reais

    let handler = VNImageRequestHandler(ciImage: image, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do { try handler.perform([request]) }
      catch { result(FlutterError(code: "OCR_ERROR", message: error.localizedDescription, details: nil)) }
    }
  }
}
```

**Conceitos:**
- `FlutterPlugin` — protocolo que o canal precisa implementar. `register(with:)` é chamado pelo AppDelegate.
- `FlutterMethodChannel(name:binaryMessenger:)` — cria o canal nomeado. O nome deve ser idêntico no Dart.
- `VNRecognizeTextRequest` — requisição de reconhecimento de texto do Vision. A closure recebe os resultados após o processamento.
- `recognitionLevel = .accurate` — modo preciso (vs `.fast`). Compensa o tempo extra com melhor taxa de acerto em placas.
- `usesLanguageCorrection = false` — desativado para não "corrigir" `ABC1D23` para uma palavra real.
- `DispatchQueue.global` — processa em background thread para não travar a UI.

### Android — OcrPlugin.kt

```kotlin
class OcrPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "frota_facil/ocr")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method != "extractText") { result.notImplemented(); return }
        val imagePath = call.argument<String>("imagePath")
            ?: run { result.error("INVALID_ARGS", "imagePath obrigatório", null); return }

        val bitmap = BitmapFactory.decodeFile(imagePath)
            ?: run { result.error("IMAGE_ERROR", "Não foi possível carregar a imagem", null); return }

        val image = InputImage.fromBitmap(bitmap, 0)
        TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
            .process(image)
            .addOnSuccessListener { result.success(it.text) }
            .addOnFailureListener { result.error("OCR_ERROR", it.localizedMessage, null) }
    }
}
```

**Conceitos:**
- `FlutterPlugin` — interface do lado Android. `onAttachedToEngine` é chamado quando o engine Flutter inicializa o plugin.
- `MethodChannel` — mesmo canal nomeado do iOS e do Dart. A mensagem trafega via Binder (IPC Android).
- `TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)` — inicializa o reconhecedor ML Kit com o modelo padrão (lateinit, pode demorar na primeira chamada).
- `.process(image).addOnSuccessListener` — ML Kit é assíncrono por design (usa Tasks do Play Services).

### Dart — ocr_service.dart

```dart
const _channel = MethodChannel('frota_facil/ocr');

Future<String> extractTextFromImage(String imagePath) async {
  final result = await _channel.invokeMethod<String>(
    'extractText',
    {'imagePath': imagePath},
  );
  return result ?? '';
}
```

**Conceitos:**
- `MethodChannel` — o canal nomeado no Dart. Deve ter o mesmo nome que o nativo.
- `invokeMethod<String>('extractText', args)` — envia a mensagem pelo canal e aguarda a resposta. O retorno pode ser nulo se o nativo retornar null.

### Registro do plugin — AppDelegate.swift

```swift
func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    OcrPlugin.register(with: engineBridge.pluginRegistry.registrar(forPlugin: "OcrPlugin")!)
}
```

### Registro do plugin — MainActivity.kt

```kotlin
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    flutterEngine.plugins.add(OcrPlugin())
}
```

---

## Critérios de aceite

- [x] OCR funciona no iOS via Vision framework
- [x] OCR funciona no Android via ML Kit
- [x] `flutter analyze` passa sem erros
- [x] 5 testes de widget passando (`flutter test test/screens/frota_busca_ocr_test.dart`)
- [x] `flutter_tesseract_ocr` e `assets/tessdata/` removidos do projeto
- [ ] Câmera abre e placa é detectada em dispositivo iOS físico
- [ ] Câmera abre e placa é detectada em dispositivo Android físico

---

## Links relacionados

- [[Tasks/2026-04-06-ocr-reimplementacao-tesseract|Task anterior (Tesseract) — supersedida]]
- [[Tasks/2026-03-16-ocr-extract-placa|Task do extractPlaca]]
- [[DevLog/2026-04-06-ocr-vision-mlkit|Dev Log desta task]]
