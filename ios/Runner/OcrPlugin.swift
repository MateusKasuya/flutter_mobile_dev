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
      result(FlutterMethodNotImplemented)
      return
    }

    guard let args = call.arguments as? [String: Any],
          let imagePath = args["imagePath"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "imagePath obrigatório", details: nil))
      return
    }

    let fileUrl = URL(fileURLWithPath: imagePath)
    guard let image = CIImage(contentsOf: fileUrl) else {
      result(FlutterError(code: "IMAGE_ERROR", message: "Não foi possível carregar a imagem", details: nil))
      return
    }

    let request = VNRecognizeTextRequest { req, error in
      if let error = error {
        result(FlutterError(code: "OCR_ERROR", message: error.localizedDescription, details: nil))
        return
      }

      let observations = req.results as? [VNRecognizedTextObservation] ?? []
      let text = observations
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: "\n")

      result(text)
    }

    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false

    let handler = VNImageRequestHandler(ciImage: image, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        result(FlutterError(code: "OCR_ERROR", message: error.localizedDescription, details: nil))
      }
    }
  }
}
