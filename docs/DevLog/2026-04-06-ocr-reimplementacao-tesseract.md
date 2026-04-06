---
tags: [tipo/devlog, dominio/frota]
date: 2026-04-06
---

# Dev Log — 06/04/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-04-06-ocr-reimplementacao-tesseract|Reimplementar OCR de placa com Tesseract]]
[[Tasks/2026-04-06-ocr-reimplementacao-tests|Testes da integração OCR com Tesseract]]

## O que foi feito

- Substituído `google_mlkit_text_recognition` (sem suporte iOS) por `flutter_tesseract_ocr`
- Adicionado `assets/tessdata/eng.traineddata` (~4MB) como asset do app
- Reimplementado `_scanPlaca()` na `FrotaBuscaScreen` usando `image_picker` + Tesseract
- Adicionada injeção de dependência (`pickImageFn`, `ocrFn`) na `FrotaBuscaScreen` — mesmo padrão do `fetchFn` já existente
- Adicionada `NSCameraUsageDescription` no `Info.plist` do iOS
- Removido smoke test padrão do Flutter que referenciava `MyApp` inexistente
- Criados 5 testes de widget cobrindo: placa Mercosul, placa antiga, câmera cancelada, OCR sem placa, OCR com erro

## Decisões tomadas

- **Tesseract em vez de ML Kit**: ML Kit não tem suporte oficial para iOS no pacote `google_mlkit_text_recognition`. Tesseract é cross-platform, offline e baseado em motor open-source consolidado.
- **PSM 6**: Page Segmentation Mode 6 ("bloco único de texto") é o mais adequado para placas — texto compacto e uniforme. Modos como PSM 11 (texto esparso) aumentariam o ruído.
- **Injeção de dependência**: `pickImageFn` e `ocrFn` foram injetados no construtor para permitir mocks nos testes sem câmera real, seguindo o padrão já estabelecido com `fetchFn`.

## Problemas encontrados

Nenhum problema relevante. O smoke test `test/widget_test.dart` referenciava `MyApp` que não existe mais — foi substituído por arquivo vazio.

## Aprendizados

- `flutter_tesseract_ocr` requer que o arquivo `eng.traineddata` seja empacotado como asset — o motor não inclui os modelos no binário.
- Em Flutter, `assets/` com barra cobre apenas arquivos diretos no diretório, não subdiretórios. Foi necessário adicionar `assets/tessdata/` explicitamente no `pubspec.yaml`.

## Próximos passos

- Testar em dispositivo físico iOS e Android para validar permissão de câmera e qualidade do OCR em condições reais
- Avaliar se PSM 6 é suficiente ou se é necessário pré-processar a imagem (crop, contraste) para melhorar a taxa de acerto
