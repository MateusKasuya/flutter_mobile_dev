---
tags: [tipo/task, dominio/frota]
date: 2026-03-16
status: planejada
branch: feat/ocr-extract-placa
---

# Task — Extração inteligente de placa do OCR

[[Tasks/_index|Tasks]]

---

## Contexto

O OCR da câmera retorna todo o texto visível na imagem da placa. Além do número da placa em si, as placas brasileiras contêm textos extras como "BRASIL", nome da cidade e sigla do estado. O código atual concatena tudo numa string única, produzindo resultados inválidos como `"ABC1D23BRASILSÃOPAULOSP"`.

Além disso, existem dois formatos de placa no Brasil:
- **Antiga**: 3 letras + 4 números (ex: `ABC1234`)
- **Mercosul**: 3 letras + 1 número + 1 letra + 2 números (ex: `ABC1D23`)

Precisamos extrair apenas o token que corresponde a um padrão de placa válido.

## Objetivo

Criar um helper `extractPlaca` que recebe o texto bruto do OCR e retorna apenas a placa, ou `null` se nenhum padrão válido for encontrado. Integrar o helper no `_scanPlaca` da `FrotaBuscaScreen`.

---

## Branch

```bash
git checkout -b feat/ocr-extract-placa
```

## Arquivos a criar

- `lib/utils/placa_utils.dart` — helper `extractPlaca`

## Arquivos a modificar

- `lib/screens/frota_busca_screen.dart` — usar `extractPlaca` no `_scanPlaca`

---

## Implementação

### Passo 1 — Criar o helper `extractPlaca`

Criar `lib/utils/placa_utils.dart`:

```dart
/// Regex para placa no formato antigo: ABC1234
final _oldFormat = RegExp(r'^[A-Z]{3}[0-9]{4}$');

/// Regex para placa no formato Mercosul: ABC1D23
final _mercosulFormat = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

/// Extrai uma placa válida do texto bruto retornado pelo OCR.
///
/// O OCR pode retornar textos extras como "BRASIL", nome da cidade
/// e sigla do estado. Este helper quebra o texto em tokens, limpa
/// cada um e retorna o primeiro que corresponde a um formato de
/// placa brasileira (antiga ou Mercosul).
///
/// Retorna `null` se nenhum token válido for encontrado.
String? extractPlaca(String ocrText) {
  final tokens = ocrText
      .toUpperCase()
      .split(RegExp(r'[\s\n]+'))
      .map((t) => t.replaceAll(RegExp(r'[^A-Z0-9]'), ''))
      .where((t) => t.isNotEmpty);

  for (final token in tokens) {
    if (_mercosulFormat.hasMatch(token) || _oldFormat.hasMatch(token)) {
      return token;
    }
  }
  return null;
}
```

**Explicações:**

- **`split(RegExp(r'[\s\n]+'))`** — quebra o texto do OCR por espaços, tabs e quebras de linha. Cada "palavra" vira um token separado. Isso isola "ABC1D23", "BRASIL", "SÃO", "PAULO", "SP" em tokens distintos.

- **`replaceAll(RegExp(r'[^A-Z0-9]'), '')`** — remove de cada token tudo que não seja letra ou número. Hífens, pontos, acentos, caracteres especiais são descartados. "ABC-1D23" vira "ABC1D23".

- **`_mercosulFormat` e `_oldFormat`** — regex com `^` e `$` garantem match exato (o token inteiro precisa ser uma placa, não apenas conter uma). São variáveis top-level `final` para que o regex seja compilado uma única vez.

- **Mercosul primeiro** — verificamos o formato Mercosul antes do antigo porque `ABC1D23` poderia, em teoria, não confundir com `ABC1234`, mas a ordem garante preferência ao formato mais moderno.

- **Retorna `null`** — caso nenhum token corresponda a um padrão de placa. Isso permite que o chamador decida o que fazer (ex: mostrar toast de erro).

---

### Passo 2 — Integrar `extractPlaca` no `_scanPlaca`

No `lib/screens/frota_busca_screen.dart`, adicionar o import:

```dart
import '../utils/placa_utils.dart';
```

Substituir o corpo do `try` dentro de `_scanPlaca`:

**De:**

```dart
final recognized = await textRecognizer.processImage(inputImage);
final text =
    recognized.text.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

if (text.isNotEmpty && mounted) {
  setState(() {
    _placaController.text = text;
  });
  _buscar();
}
```

**Para:**

```dart
final recognized = await textRecognizer.processImage(inputImage);
final placa = extractPlaca(recognized.text);

if (placa != null && mounted) {
  setState(() {
    _placaController.text = placa;
  });
  _buscar();
} else if (mounted) {
  showErrorToast('Não foi possível identificar a placa na foto');
}
```

**Explicações:**

- **`extractPlaca(recognized.text)`** — delega toda a lógica de parsing para o helper. O `_scanPlaca` fica responsável apenas pelo fluxo (câmera → OCR → helper → UI).

- **`else if (mounted)` com toast** — se o helper retornar `null`, o usuário recebe feedback de que a foto não continha uma placa válida, em vez de silenciosamente não fazer nada.

---

### Passo 3 — Estado final do `_scanPlaca`

Após as alterações, o método deve ficar:

```dart
Future<void> _scanPlaca() async {
  final picker = ImagePicker();
  final photo = await picker.pickImage(source: ImageSource.camera);
  if (photo == null) return;

  final inputImage = InputImage.fromFilePath(photo.path);
  final textRecognizer = TextRecognizer();

  try {
    final recognized = await textRecognizer.processImage(inputImage);
    final placa = extractPlaca(recognized.text);

    if (placa != null && mounted) {
      setState(() {
        _placaController.text = placa;
      });
      _buscar();
    } else if (mounted) {
      showErrorToast('Não foi possível identificar a placa na foto');
    }
  } finally {
    textRecognizer.close();
  }
}
```

---

## Critérios de aceite

- [ ] `lib/utils/placa_utils.dart` criado com `extractPlaca`
- [ ] Reconhece formato antigo (`ABC1234`)
- [ ] Reconhece formato Mercosul (`ABC1D23`)
- [ ] Ignora textos extras ("BRASIL", cidade, estado)
- [ ] Retorna `null` quando nenhuma placa válida é encontrada
- [ ] `_scanPlaca` exibe toast quando OCR não encontra placa
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-camera-ocr|Camera + OCR da placa]]
- [[Tasks/2026-03-16-ocr-extract-placa-tests|Testes do extractPlaca]]
- [[DevLog/]]
