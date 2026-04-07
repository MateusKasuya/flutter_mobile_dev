---
tags: [tipo/task, dominio/frota]
date: 2026-03-16
status: planejada
branch: feat/ocr-extract-placa-tests
---

# Task — Testes do extractPlaca

[[Tasks/_index|Tasks]]

---

## Contexto

O helper `extractPlaca` é crítico para o fluxo de OCR — se ele falhar, a busca automática por placa não funciona. Precisamos garantir que ele extrai corretamente a placa dos dois formatos brasileiros e ignora textos extras.

## Objetivo

Cobertura de testes unitários para `extractPlaca`: formatos Mercosul e antigo, textos extras, hífens/espaços, retorno `null` quando inválido.

---

## Branch

```bash
git checkout -b feat/ocr-extract-placa-tests
```

## Arquivos a criar

- `test/utils/placa_utils_test.dart`

## Arquivos a modificar

- *(nenhum)*

---

## Implementação

### Passo 1 — Criar testes do `extractPlaca`

Criar `test/utils/placa_utils_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/utils/placa_utils.dart';

void main() {
  group('extractPlaca', () {
    test('extrai placa Mercosul simples', () {
      expect(extractPlaca('ABC1D23'), 'ABC1D23');
    });

    test('extrai placa formato antigo', () {
      expect(extractPlaca('ABC1234'), 'ABC1234');
    });

    test('ignora texto BRASIL e extrai placa Mercosul', () {
      expect(extractPlaca('ABC1D23\nBRASIL'), 'ABC1D23');
    });

    test('ignora cidade e estado', () {
      expect(extractPlaca('ABC1D23\nSÃO PAULO\nSP\nBRASIL'), 'ABC1D23');
    });

    test('extrai placa antiga com cidade e estado', () {
      expect(extractPlaca('ABC1234\nRIO DE JANEIRO\nRJ\nBRASIL'), 'ABC1234');
    });

    test('remove hífens antes de validar', () {
      expect(extractPlaca('ABC-1D23'), 'ABC1D23');
    });

    test('remove hífens da placa antiga', () {
      expect(extractPlaca('ABC-1234'), 'ABC1234');
    });

    test('funciona com letras minúsculas', () {
      expect(extractPlaca('abc1d23'), 'ABC1D23');
    });

    test('retorna null quando texto não contém placa', () {
      expect(extractPlaca('BRASIL\nSÃO PAULO\nSP'), isNull);
    });

    test('retorna null para string vazia', () {
      expect(extractPlaca(''), isNull);
    });

    test('retorna null para texto aleatório', () {
      expect(extractPlaca('HELLO WORLD 123'), isNull);
    });

    test('extrai placa quando há múltiplas linhas com ruído', () {
      expect(
        extractPlaca('   BRASIL\n  ABC1D23  \nSÃO PAULO SP'),
        'ABC1D23',
      );
    });
  });
}
```

**Explicações:**

- **Cobertura dos dois formatos** — testamos `ABC1D23` (Mercosul) e `ABC1234` (antigo) separadamente para garantir que ambos os regex funcionam.

- **Textos extras reais** — "BRASIL", "SÃO PAULO", "SP", "RIO DE JANEIRO", "RJ" são os textos que realmente aparecem nas placas brasileiras. Testamos combinações realistas.

- **Hífens** — placas antigas frequentemente aparecem com hífen ("ABC-1234") e o OCR pode capturar esse caractere. O helper deve removê-lo antes de validar.

- **Case insensitive** — o OCR pode retornar letras minúsculas em alguns dispositivos. Testamos que o helper faz `.toUpperCase()` internamente.

- **Retornos `null`** — testamos os três cenários de falha: texto sem placa, string vazia e texto aleatório.

- **Espaços e whitespace** — testamos que espaços extras antes/depois dos tokens não atrapalham a extração.

---

## Critérios de aceite

- [ ] `test/utils/placa_utils_test.dart` criado com 12 testes
- [ ] Cobre formato Mercosul e antigo
- [ ] Cobre textos extras (BRASIL, cidade, estado)
- [ ] Cobre hífens, minúsculas e whitespace
- [ ] Cobre retornos `null`
- [ ] `flutter test test/utils/placa_utils_test.dart` passa sem erros
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-16-ocr-extract-placa|Extração inteligente de placa do OCR]]
- [[DevLog/]]
