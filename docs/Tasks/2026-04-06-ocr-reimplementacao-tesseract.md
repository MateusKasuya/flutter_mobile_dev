---
tags: [tipo/task, dominio/frota]
date: 2026-04-06
status: planejada
branch: feat/ocr-reimplementacao-tesseract
---

# Task — Reimplementar OCR de placa com Tesseract (cross-platform)

[[Tasks/_index|Tasks]]

---

## Contexto

A task anterior de OCR (`2026-03-05-frota-camera-ocr`) usava o pacote `google_mlkit_text_recognition`, que **não funciona no iOS**. Por isso, o método `_scanPlaca()` na `FrotaBuscaScreen` foi desabilitado e exibe apenas um toast de "indisponível".

Precisamos reimplementar o OCR usando uma solução cross-platform. A escolha é o **Tesseract OCR** via pacote `flutter_tesseract_ocr`, que:
- Funciona em Android e iOS
- Roda offline (sem dependência de serviços Google)
- É baseado no motor Tesseract (referência em OCR open-source)

A lógica de extração de placa (`extractPlaca` em `placa_utils.dart`) já está implementada e testada — só precisamos alimentá-la com o texto do Tesseract.

## Objetivo

Ao final desta task:
- O FAB de câmera na `FrotaBuscaScreen` abre a câmera, processa a imagem com Tesseract OCR e preenche o campo de placa automaticamente
- Funciona tanto em Android quanto em iOS
- Mostra feedback adequado ao usuário (loading, erros, placa não encontrada)

---

## Branch

```bash
git checkout -b feat/ocr-reimplementacao-tesseract
```

## Arquivos a criar

- `assets/tessdata/eng.traineddata` — arquivo de treinamento do Tesseract para inglês (letras e números são os mesmos)

## Arquivos a modificar

- `pubspec.yaml` — adicionar dependência `flutter_tesseract_ocr`
- `lib/screens/frota_busca_screen.dart` — reimplementar `_scanPlaca()` com Tesseract

---

## Implementação

### Passo 1 — Adicionar dependência e tessdata

Adicionar o pacote `flutter_tesseract_ocr` ao `pubspec.yaml`:

```bash
flutter pub add flutter_tesseract_ocr
```

Baixar o arquivo de treinamento do Tesseract (eng.traineddata) para reconhecimento de caracteres latinos:

```bash
mkdir -p assets/tessdata
curl -L -o assets/tessdata/eng.traineddata \
  https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata
```

Registrar o asset no `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/
    - assets/tessdata/
```

**Explicação:**
- `tessdata` é o diretório padrão onde o Tesseract procura seus modelos de treinamento
- `eng.traineddata` contém o modelo para caracteres latinos (letras A-Z e dígitos 0-9 — suficiente para placas brasileiras)
- Usamos a versão `tessdata_fast` que é menor (~4MB) e mais rápida, com precisão adequada para texto impresso como placas

---

### Passo 2 — Reimplementar `_scanPlaca()` na FrotaBuscaScreen

Substituir o método placeholder por uma implementação completa:

```dart
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/placa_utils.dart';
```

```dart
Future<void> _scanPlaca() async {
  // 1. Capturar imagem da câmera
  final picker = ImagePicker();
  final photo = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.rear,
    imageQuality: 85,
  );

  if (photo == null) return; // usuário cancelou

  // 2. Mostrar loading enquanto processa
  setState(() => _isLoading = true);

  try {
    // 3. Executar OCR com Tesseract
    final ocrText = await FlutterTesseractOcr.extractText(
      photo.path,
      language: 'eng',
      args: {
        "psm": "6",       // assume bloco único de texto
        "preserve_interword_spaces": "1",
      },
    );

    // 4. Extrair placa do texto bruto
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

**Explicação linha a linha:**

- `picker.pickImage(source: ImageSource.camera)` — abre a câmera nativa do dispositivo. `imageQuality: 85` reduz levemente a qualidade para processar mais rápido sem perder legibilidade.
- `FlutterTesseractOcr.extractText(photo.path, language: 'eng')` — envia a imagem para o motor Tesseract. O `language: 'eng'` indica qual modelo usar (o `eng.traineddata` que baixamos).
- `args: {"psm": "6"}` — Page Segmentation Mode 6 = "assume a single uniform block of text". Ideal para placas, que são um bloco compacto de texto. `preserve_interword_spaces` mantém espaços entre caracteres.
- `extractPlaca(ocrText)` — reutiliza o helper já existente que limpa o texto e busca padrões de placa brasileira (antiga `ABC1234` e Mercosul `ABC1D23`).
- O toast de sucesso/erro dá feedback imediato ao usuário.
- O `_isLoading` compartilhado com o botão Buscar desabilita interações durante o processamento.

---

### Passo 3 — Adicionar toast de sucesso

Verificar se `showSuccessToast` já existe em `app_toast.dart`. Se não existir, adicionar:

```dart
void showSuccessToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}
```

---

### Passo 4 — Verificar permissões de câmera

As permissões de câmera no `Info.plist` (iOS) já foram configuradas na task anterior. Verificar que `NSCameraUsageDescription` está presente.

No Android, `image_picker` já declara a permissão de câmera automaticamente.

---

## Critérios de aceite

- [ ] `flutter_tesseract_ocr` está no `pubspec.yaml` e instala sem erros
- [ ] `assets/tessdata/eng.traineddata` existe e está registrado nos assets
- [ ] FAB de câmera abre a câmera no Android
- [ ] FAB de câmera abre a câmera no iOS
- [ ] Foto de placa antiga (ABC1234) é reconhecida e preenche o campo
- [ ] Foto de placa Mercosul (ABC1D23) é reconhecida e preenche o campo
- [ ] Foto sem placa mostra toast "Nenhuma placa encontrada"
- [ ] Loading indicator aparece durante processamento
- [ ] Cancelar a câmera não causa erro
- [ ] `flutter analyze` passa sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-camera-ocr|Task original de Camera + OCR (ML Kit)]]
- [[Tasks/2026-03-16-ocr-extract-placa|Task do extractPlaca]]
- [[DevLog/2026-03-16-camera-ocr-placa|DevLog original do OCR]]
