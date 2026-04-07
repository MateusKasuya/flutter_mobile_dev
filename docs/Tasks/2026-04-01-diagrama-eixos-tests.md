---
tags: [tipo/task, dominio/frota]
date: 2026-04-01
status: concluída
branch: feat/diagrama-eixos-tests
---

# Task — Testes do diagrama de eixos

[[Tasks/_index|Tasks]]

---

## Contexto

O diagrama de eixos introduziu: model `Eixo`, função `buildEixoLayout`, widget `DiagramaEixos` com drag-and-drop, enum `PneuAcao` e integração na `FrotaDetalheScreen`. Precisamos de testes unitários para o parser e testes de widget para o diagrama e as zonas de ação.

## Objetivo

Cobertura de testes para:
- `buildEixoLayout`: parsing de `LOCALEIXO`, rodado simples e duplo, ordenação, edge cases
- `DiagramaEixos`: renderização, callback `onPneuTap`, comportamento do `LongPressDraggable`

---

## Branch

```bash
git checkout -b feat/diagrama-eixos-tests
```

## Arquivos a criar

- `test/utils/eixo_utils_test.dart`
- `test/components/diagrama_eixos_test.dart`

## Arquivos a modificar

- *(nenhum)*

---

## Implementação

### Passo 1 — Testes unitários de `buildEixoLayout`

Criar `test/utils/eixo_utils_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/utils/eixo_utils.dart';

/// Helper para criar um Pneu com apenas os campos relevantes para o teste.
Pneu _makePneu(String nroPneu, String localEixo) {
  return Pneu(
    nroPneu: nroPneu,
    nroSerie: '',
    marca: '',
    modelo: '',
    dimensao: '',
    tipo: '',
    situacao: '',
    localEixo: localEixo,
    codEsqEixo: 'A',
    localizacao: '',
    nroDot: '',
    indRecapagem: '',
    vidaPneu: '',
    kmRodado: '',
    kmAcumulador: '',
    kmAtuVei: '',
    kmRodado0: '',
    kmRodado1: '',
    kmRodado2: '',
    kmRodado3: '',
    kmRodado4: '',
    kmRodado5: '',
    dataCompra: '',
    dataAtzKm: '',
    codFil: '',
    nroFrota: '',
    placa: '',
  );
}

void main() {
  group('buildEixoLayout', () {
    test('organiza TOCO com 6 pneus em 2 eixos', () {
      final pneus = [
        _makePneu('1272', '2EE'),
        _makePneu('1280', '2DE'),
        _makePneu('1334', '2DI'),
        _makePneu('1353', '2EI'),
        _makePneu('2396', '1D'),
        _makePneu('2397', '1E'),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos.length, 2);

      // Eixo 1 — simples
      expect(eixos[0].numero, 1);
      expect(eixos[0].rodadoDuplo, false);
      expect(eixos[0].direitoExterno?.nroPneu, '2396');
      expect(eixos[0].esquerdoExterno?.nroPneu, '2397');
      expect(eixos[0].direitoInterno, isNull);
      expect(eixos[0].esquerdoInterno, isNull);

      // Eixo 2 — duplo
      expect(eixos[1].numero, 2);
      expect(eixos[1].rodadoDuplo, true);
      expect(eixos[1].direitoExterno?.nroPneu, '1280');
      expect(eixos[1].direitoInterno?.nroPneu, '1334');
      expect(eixos[1].esquerdoExterno?.nroPneu, '1272');
      expect(eixos[1].esquerdoInterno?.nroPneu, '1353');
    });

    test('resultado é ordenado por número do eixo', () {
      final pneus = [
        _makePneu('100', '2DE'),
        _makePneu('200', '1D'),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos[0].numero, 1);
      expect(eixos[1].numero, 2);
    });

    test('ignora pneus com localEixo vazio', () {
      final pneus = [
        _makePneu('100', '1D'),
        _makePneu('200', ''),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos.length, 1);
      expect(eixos[0].direitoExterno?.nroPneu, '100');
    });

    test('retorna lista vazia quando não há pneus', () {
      final eixos = buildEixoLayout([]);
      expect(eixos, isEmpty);
    });

    test('eixo com apenas um lado preenchido funciona', () {
      final pneus = [
        _makePneu('100', '1D'),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos.length, 1);
      expect(eixos[0].direitoExterno?.nroPneu, '100');
      expect(eixos[0].esquerdoExterno, isNull);
    });
  });
}
```

**Explicações:**

- **`_makePneu` helper** — cria um `Pneu` com apenas `nroPneu` e `localEixo` preenchidos. Necessário porque todos os campos são `required`.

- **Teste principal (TOCO)** — replica o JSON real da API. Verifica cada pneu na posição correta.

- **Edge cases** — ordenação, `localEixo` vazio, lista vazia, eixo parcialmente preenchido.

---

### Passo 2 — Testes de widget do `DiagramaEixos`

Criar `test/components/diagrama_eixos_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/components/diagrama_eixos.dart';
import 'package:frota_facil_mobile/models/eixo.dart';
import 'package:frota_facil_mobile/models/pneu.dart';

Pneu _makePneu(String nroPneu, String localEixo) {
  return Pneu(
    nroPneu: nroPneu,
    nroSerie: '',
    marca: 'GOODYEAR',
    modelo: 'K MAX S',
    dimensao: '275/80',
    tipo: 'RADIAL LISO',
    situacao: 'N',
    localEixo: localEixo,
    codEsqEixo: 'A',
    localizacao: 'FROTA',
    nroDot: '',
    indRecapagem: 'S',
    vidaPneu: '1',
    kmRodado: '0',
    kmAcumulador: '0',
    kmAtuVei: '0',
    kmRodado0: '0',
    kmRodado1: '0',
    kmRodado2: '',
    kmRodado3: '',
    kmRodado4: '',
    kmRodado5: '',
    dataCompra: '',
    dataAtzKm: '',
    codFil: '100',
    nroFrota: '499',
    placa: 'ACN8908',
  );
}

void main() {
  group('DiagramaEixos', () {
    testWidgets('exibe números dos pneus', (tester) async {
      final eixos = [
        Eixo(
          numero: 1,
          esquerdoExterno: _makePneu('2397', '1E'),
          direitoExterno: _makePneu('2396', '1D'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DiagramaEixos(eixos: eixos)),
        ),
      );

      expect(find.text('2397'), findsOneWidget);
      expect(find.text('2396'), findsOneWidget);
    });

    testWidgets('exibe indicador de frente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramaEixos(
              eixos: [
                Eixo(
                  numero: 1,
                  direitoExterno: _makePneu('100', '1D'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Frente'), findsOneWidget);
    });

    testWidgets('exibe labels dos eixos', (tester) async {
      final eixos = [
        Eixo(
          numero: 1,
          direitoExterno: _makePneu('100', '1D'),
          esquerdoExterno: _makePneu('200', '1E'),
        ),
        Eixo(
          numero: 2,
          direitoExterno: _makePneu('300', '2DE'),
          direitoInterno: _makePneu('400', '2DI'),
          esquerdoExterno: _makePneu('500', '2EE'),
          esquerdoInterno: _makePneu('600', '2EI'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DiagramaEixos(eixos: eixos)),
        ),
      );

      expect(find.text('E1'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
    });

    testWidgets('exibe 4 pneus em eixo duplo', (tester) async {
      final eixos = [
        Eixo(
          numero: 2,
          direitoExterno: _makePneu('1280', '2DE'),
          direitoInterno: _makePneu('1334', '2DI'),
          esquerdoExterno: _makePneu('1272', '2EE'),
          esquerdoInterno: _makePneu('1353', '2EI'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DiagramaEixos(eixos: eixos)),
        ),
      );

      expect(find.text('1280'), findsOneWidget);
      expect(find.text('1334'), findsOneWidget);
      expect(find.text('1272'), findsOneWidget);
      expect(find.text('1353'), findsOneWidget);
    });

    testWidgets('onPneuTap é chamado ao tocar num pneu', (tester) async {
      Pneu? tappedPneu;
      final pneu = _makePneu('2396', '1D');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramaEixos(
              eixos: [Eixo(numero: 1, direitoExterno: pneu)],
              onPneuTap: (p) => tappedPneu = p,
            ),
          ),
        ),
      );

      await tester.tap(find.text('2396'));
      expect(tappedPneu, isNotNull);
      expect(tappedPneu!.nroPneu, '2396');
    });

    testWidgets('não renderiza nada quando lista de eixos está vazia',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DiagramaEixos(eixos: [])),
        ),
      );

      expect(find.text('Frente'), findsNothing);
    });

    testWidgets('long press inicia drag do pneu', (tester) async {
      final pneu = _makePneu('2396', '1D');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramaEixos(
              eixos: [Eixo(numero: 1, direitoExterno: pneu)],
            ),
          ),
        ),
      );

      // Inicia long press para ativar o drag
      final gesture = await tester.startGesture(
          tester.getCenter(find.text('2396')));
      await tester.pump(const Duration(milliseconds: 600));

      // Durante o drag, o feedback deve estar visível
      // e o placeholder cinza deve aparecer no lugar original
      // (o LongPressDraggable cria uma cópia como feedback)
      expect(find.text('2396'), findsWidgets);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
```

**Explicações:**

- **Teste de tap** — `tester.tap` simula um toque rápido e verifica que `onPneuTap` é chamado com o `Pneu` correto.

- **Teste de long press / drag** — `tester.startGesture` inicia um toque contínuo. Após 600ms (tempo do long press), o `LongPressDraggable` ativa e cria o feedback. `findsWidgets` (plural) verifica que existem múltiplas instâncias do texto "2396" (o original/placeholder + o feedback flutuante).

- **`gesture.up()` + `pumpAndSettle()`** — solta o dedo e aguarda todas as animações terminarem. Necessário para limpar o estado do drag e evitar que o teste vaze para o próximo.

---

## Critérios de aceite

- [ ] `test/utils/eixo_utils_test.dart` criado com 5 testes
- [ ] `test/components/diagrama_eixos_test.dart` criado com 7 testes
- [ ] Cobre parsing de TOCO (rodado simples + duplo)
- [ ] Cobre ordenação, localEixo vazio, lista vazia
- [ ] Cobre renderização dos números, labels e indicador de frente
- [ ] Cobre callback `onPneuTap` no toque rápido
- [ ] Cobre ativação do `LongPressDraggable`
- [ ] `flutter test` passa sem erros
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-04-01-eixo-layout-model|Modelo Eixo e parser de LOCALEIXO]]
- [[Tasks/2026-04-01-diagrama-eixos-widget|Widget do diagrama de eixos]]
- [[Tasks/2026-04-01-diagrama-eixos-integracao|Integração do diagrama na FrotaDetalheScreen]]
- [[DevLog/]]
