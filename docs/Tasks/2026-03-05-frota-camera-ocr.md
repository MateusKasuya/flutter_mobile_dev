---
tags: [tipo/task, dominio/frota]
date: 2026-03-05
status: planejada
branch: feat/frota-camera-ocr
---

# Task — Camera + OCR da placa

[[Tasks/_index|Tasks]]

---

## Contexto

A `FrotaBuscaScreen` ja permite digitar a placa manualmente. Agora adicionamos um FloatingActionButton que abre a camera para tirar foto da placa e reconhece o texto via OCR, preenchendo o campo automaticamente.

## Objetivo

FAB na `FrotaBuscaScreen` que abre a camera, captura uma foto, extrai o texto da placa via OCR e preenche o campo de placa automaticamente.

---

## Branch

```bash
git checkout -b feat/frota-camera-ocr
```

## Arquivos a criar

- *(nenhum)*

## Arquivos a modificar

- `pubspec.yaml` — adicionar dependencias `image_picker` e `google_mlkit_text_recognition`
- `lib/screens/frota_busca_screen.dart` — adicionar FAB com camera + OCR

---

## Implementacao

### Passo 1 — Adicionar dependencias

Executar no terminal:

```bash
flutter pub add image_picker google_mlkit_text_recognition
```

**Explicacoes:**

- **`image_picker`** — pacote oficial do Flutter para capturar fotos da camera ou selecionar da galeria. Abstrai as diferencas entre Android e iOS. Retorna um `XFile` com o caminho da imagem.

- **`google_mlkit_text_recognition`** — pacote do Google ML Kit para reconhecimento de texto em imagens (OCR). Roda localmente no dispositivo (nao precisa de internet). Suporta texto latino (placas brasileiras) por padrao.

---

### Passo 2 — Configuracao iOS (Info.plist)

Adicionar em `ios/Runner/Info.plist`, dentro do `<dict>` principal:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da camera para fotografar a placa do veiculo</string>
```

**Explicacao:**

- **`NSCameraUsageDescription`** — obrigatorio no iOS. O sistema exibe essa mensagem ao usuario na primeira vez que o app pede acesso a camera. Sem essa chave, o app crasha ao tentar abrir a camera.

---

### Passo 3 — Adicionar FAB e logica de OCR na FrotaBuscaScreen

Modificar `lib/screens/frota_busca_screen.dart`. Adicionar os imports no topo:

```dart
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
```

Adicionar um metodo `_scanPlaca` no `_FrotaBuscaScreenState`:

```dart
Future<void> _scanPlaca() async {
  final picker = ImagePicker();
  final photo = await picker.pickImage(source: ImageSource.camera);
  if (photo == null) return;

  final inputImage = InputImage.fromFilePath(photo.path);
  final textRecognizer = TextRecognizer();

  try {
    final recognized = await textRecognizer.processImage(inputImage);
    final text = recognized.text.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

    if (text.isNotEmpty && mounted) {
      setState(() {
        _placaController.text = text;
      });
    }
  } finally {
    textRecognizer.close();
  }
}
```

Adicionar o `floatingActionButton` no `Scaffold`:

```dart
return Scaffold(
  appBar: AppBar(title: const Text('Buscar Veiculo')),
  body: // ... (corpo existente permanece igual)
  floatingActionButton: FloatingActionButton(
    onPressed: _scanPlaca,
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Colors.white,
    child: const Icon(Icons.camera_alt),
  ),
);
```

**Explicacoes:**

- **`ImagePicker().pickImage(source: ImageSource.camera)`** — abre a camera nativa do dispositivo e retorna um `XFile?`. Retorna `null` se o usuario cancelar (por isso o `if (photo == null) return`). `ImageSource.camera` indica camera ao vivo; a alternativa seria `ImageSource.gallery` para galeria.

- **`InputImage.fromFilePath(photo.path)`** — converte o caminho do arquivo da foto para o formato que o ML Kit espera. O `XFile.path` retorna o caminho absoluto do arquivo temporario onde a foto foi salva.

- **`TextRecognizer()`** — instancia o reconhecedor de texto do ML Kit. Usa o modelo de script latino por padrao, que reconhece caracteres A-Z e 0-9 (perfeito para placas brasileiras).

- **`recognized.text`** — o ML Kit retorna todo o texto encontrado na imagem. Para uma foto de placa, geralmente retorna a placa com posssiveis espacos ou hifens.

- **`replaceAll(RegExp(r'[\s\-]'), '')`** — remove espacos e hifens do texto reconhecido. Placas podem ser lidas como "ABC-1D23" ou "ABC 1D23", mas queremos "ABC1D23".

- **`textRecognizer.close()`** — libera os recursos nativos do reconhecedor. Importante fazer no `finally` para evitar vazamento de memoria, mesmo se ocorrer erro no processamento.

- **`FloatingActionButton` com icone de camera** — posicionado no canto inferior direito (padrao). O icone `camera_alt` eh intuitivo para a funcao de "tirar foto".

---

### Passo 4 — Estado final do arquivo completo

Apos as alteracoes, o `lib/screens/frota_busca_screen.dart` deve ficar:

```dart
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/veiculo.dart';
import '../services/frota_service.dart' as frota_service;
import '../utils/app_toast.dart';
import 'frota_detalhe_screen.dart';

class FrotaBuscaScreen extends StatefulWidget {
  final String token;
  final Future<Veiculo> Function(String token, String placa) fetchFn;

  const FrotaBuscaScreen({
    super.key,
    required this.token,
    this.fetchFn = frota_service.fetchVeiculo,
  });

  @override
  State<FrotaBuscaScreen> createState() => _FrotaBuscaScreenState();
}

class _FrotaBuscaScreenState extends State<FrotaBuscaScreen> {
  final _placaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final veiculo = await widget.fetchFn(
        widget.token,
        _placaController.text.trim().toUpperCase(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FrotaDetalheScreen(veiculo: veiculo),
        ),
      );
    } catch (e) {
      showErrorToast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanPlaca() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final inputImage = InputImage.fromFilePath(photo.path);
    final textRecognizer = TextRecognizer();

    try {
      final recognized = await textRecognizer.processImage(inputImage);
      final text =
          recognized.text.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

      if (text.isNotEmpty && mounted) {
        setState(() {
          _placaController.text = text;
        });
      }
    } finally {
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Veiculo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Placa do veiculo',
                  hintText: 'Ex: ABC1D23',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a placa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _buscar,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanPlaca,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
```

---

## Criterios de aceite

- [ ] Dependencias `image_picker` e `google_mlkit_text_recognition` instaladas
- [ ] `NSCameraUsageDescription` configurado no Info.plist do iOS
- [ ] FAB com icone de camera visivel na tela de busca
- [ ] Tocar no FAB abre a camera nativa
- [ ] Apos capturar foto, o texto reconhecido preenche o campo de placa
- [ ] Cancelar a camera nao causa erro
- [ ] `TextRecognizer` eh fechado apos uso (no `finally`)
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-pneus-lista|Lista de pneus do veiculo]]
- [[Tasks/2026-03-05-frota-tests|Testes do modulo Frota]]
- [[DevLog/]]
