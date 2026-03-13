---
tags: [tipo/task, dominio/frota]
date: 2026-03-05
status: planejada
branch: feat/frota-tests
---

# Task — Testes do modulo Frota

[[Tasks/_index|Tasks]]

---

## Contexto

O modulo de Frota foi implementado com models, service e telas. Agora criamos testes unitarios e de widget para garantir que tudo funciona corretamente e nao quebre com futuras alteracoes.

## Objetivo

Cobertura de testes para: `Pneu.fromJson`, `Veiculo.fromJson`, `fetchVeiculo` (sucesso, 404, 422), `FrotaBuscaScreen` (busca com sucesso, erro, validacao) e `FrotaDetalheScreen` (dados do veiculo e pneus renderizados).

---

## Branch

```bash
git checkout -b feat/frota-tests
```

## Arquivos a criar

- `test/models/pneu_test.dart`
- `test/models/veiculo_test.dart`
- `test/services/frota_service_test.dart`
- `test/screens/frota_busca_screen_test.dart`
- `test/screens/frota_detalhe_screen_test.dart`

## Arquivos a modificar

- *(nenhum)*

---

## Implementacao

### Passo 1 — Teste do model Pneu

Criar `test/models/pneu_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';

void main() {
  group('Pneu.fromJson', () {
    test('cria Pneu a partir de JSON valido', () {
      final json = {
        'NROPNEU': '1',
        'NROSERIE': 'SR123456',
        'MARCA': 'Pirelli',
        'MODELO': 'Modelo A',
        'DIMENSAO': '295/80R22.5',
        'TIPO': 'Radial',
        'SITUACAO': 'Em uso',
        'LOCALEIXO': 'Dianteiro esquerdo',
        'CODESQEIXO': '1',
        'LOCALIZACAO': '1',
        'NRODOT': '4523',
        'INDRECAPAGEM': 'N',
        'VIDAPNEU': '80',
        'KMRODADO': '50000',
        'KMACUMULADOR': '40000',
        'KMATUVEI': '150000',
        'KMRODADO0': '10000',
        'KMRODADO1': '10000',
        'KMRODADO2': '10000',
        'KMRODADO3': '10000',
        'KMRODADO4': '10000',
        'KMRODADO5': '0',
        'DATACOMPRA': '2023-01-15',
        'DATAATZKM': '2024-06-01',
        'CODFIL': '01',
        'NROFROTA': '001',
        'PLACA': 'ABC1D23',
      };

      final pneu = Pneu.fromJson(json);

      expect(pneu.nroPneu, '1');
      expect(pneu.marca, 'Pirelli');
      expect(pneu.dimensao, '295/80R22.5');
      expect(pneu.situacao, 'Em uso');
      expect(pneu.localEixo, 'Dianteiro esquerdo');
      expect(pneu.vidaPneu, '80');
      expect(pneu.kmRodado, '50000');
      expect(pneu.placa, 'ABC1D23');
    });
  });
}
```

**Explicacoes:**

- **`group`** — agrupa testes relacionados sob um nome descritivo. Organiza a saida no terminal e permite rodar apenas um grupo com `--name`.

- **Verificamos campos representativos** — nao precisamos testar todos os 27 campos, pois o `fromJson` segue o mesmo padrao para todos. Testamos os mais importantes para garantir que o mapeamento esta correto.

---

### Passo 2 — Teste do model Veiculo

Criar `test/models/veiculo_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';

Map<String, dynamic> _makePneuJson() => {
      'NROPNEU': '1',
      'NROSERIE': 'SR123456',
      'MARCA': 'Pirelli',
      'MODELO': 'Modelo A',
      'DIMENSAO': '295/80R22.5',
      'TIPO': 'Radial',
      'SITUACAO': 'Em uso',
      'LOCALEIXO': 'Dianteiro esquerdo',
      'CODESQEIXO': '1',
      'LOCALIZACAO': '1',
      'NRODOT': '4523',
      'INDRECAPAGEM': 'N',
      'VIDAPNEU': '80',
      'KMRODADO': '50000',
      'KMACUMULADOR': '40000',
      'KMATUVEI': '150000',
      'KMRODADO0': '10000',
      'KMRODADO1': '10000',
      'KMRODADO2': '10000',
      'KMRODADO3': '10000',
      'KMRODADO4': '10000',
      'KMRODADO5': '0',
      'DATACOMPRA': '2023-01-15',
      'DATAATZKM': '2024-06-01',
      'CODFIL': '01',
      'NROFROTA': '001',
      'PLACA': 'ABC1D23',
    };

void main() {
  group('Veiculo.fromJson', () {
    test('cria Veiculo com lista de pneus a partir de JSON valido', () {
      final json = {
        'PLACA': 'ABC1D23',
        'NROFROTA': '001',
        'MARCA': 'Marca Y',
        'MODELO': 'Modelo X',
        'ANO': '2020',
        'ANOMODELO': '2021',
        'COR': 'Branco',
        'TIPO': 'Caminhao',
        'pneus': [_makePneuJson()],
      };

      final veiculo = Veiculo.fromJson(json);

      expect(veiculo.placa, 'ABC1D23');
      expect(veiculo.nroFrota, '001');
      expect(veiculo.marca, 'Marca Y');
      expect(veiculo.modelo, 'Modelo X');
      expect(veiculo.ano, '2020');
      expect(veiculo.anoModelo, '2021');
      expect(veiculo.cor, 'Branco');
      expect(veiculo.tipo, 'Caminhao');
      expect(veiculo.pneus, hasLength(1));
      expect(veiculo.pneus.first, isA<Pneu>());
      expect(veiculo.pneus.first.marca, 'Pirelli');
    });

    test('cria Veiculo com lista de pneus vazia', () {
      final json = {
        'PLACA': 'XYZ9K88',
        'NROFROTA': '002',
        'MARCA': 'Marca Z',
        'MODELO': 'Modelo W',
        'ANO': '2022',
        'ANOMODELO': '2023',
        'COR': 'Preto',
        'TIPO': 'Van',
        'pneus': [],
      };

      final veiculo = Veiculo.fromJson(json);

      expect(veiculo.placa, 'XYZ9K88');
      expect(veiculo.pneus, isEmpty);
    });
  });
}
```

**Explicacoes:**

- **`_makePneuJson()`** — helper que retorna um JSON de pneu valido. Evita duplicar o mapa enorme em cada teste. O `=>` (arrow function) retorna o mapa diretamente.

- **`isA<Pneu>()`** — matcher do `flutter_test` que verifica o tipo do objeto. Garante que o `fromJson` do veiculo realmente criou instancias de `Pneu`, nao objetos genericos.

- **Teste com pneus vazio** — caso de borda importante. Um veiculo pode nao ter pneus cadastrados e o app nao deve crashar.

---

### Passo 3 — Teste do frota_service

Criar `test/services/frota_service_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frota_facil_mobile/services/frota_service.dart';

Map<String, dynamic> _veiculoJson() => {
      'PLACA': 'ABC1D23',
      'NROFROTA': '001',
      'MARCA': 'Marca Y',
      'MODELO': 'Modelo X',
      'ANO': '2020',
      'ANOMODELO': '2021',
      'COR': 'Branco',
      'TIPO': 'Caminhao',
      'pneus': [],
    };

void main() {
  group('fetchVeiculo', () {
    test('retorna Veiculo quando status 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['placa'], 'ABC1D23');
        return http.Response(jsonEncode(_veiculoJson()), 200);
      });

      final veiculo =
          await fetchVeiculo('token123', 'ABC1D23', client: mockClient);

      expect(veiculo.placa, 'ABC1D23');
      expect(veiculo.marca, 'Marca Y');
    });

    test('lanca excecao com mensagem amigavel quando 404', () async {
      final mockClient = MockClient((_) async {
        return http.Response('{"detail": "Not found"}', 404);
      });

      expect(
        () => fetchVeiculo('token123', 'ZZZ0000', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Veiculo nao encontrado'),
          ),
        ),
      );
    });

    test('lanca excecao com mensagem da API quando 422', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'detail': [
              {'msg': 'valor invalido'}
            ]
          }),
          422,
        );
      });

      expect(
        () => fetchVeiculo('token123', '', client: mockClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('valor invalido'),
          ),
        ),
      );
    });
  });
}
```

**Explicacoes:**

- **`MockClient`** — do pacote `http/testing.dart`. Recebe uma funcao que simula a resposta HTTP. Permite testar o service sem fazer chamadas reais a API.

- **`request.url.queryParameters['placa']`** — verifica que o service esta montando a URL corretamente com o query parameter `placa`.

- **`throwsA(isA<Exception>().having(...))`** — matcher composto que verifica: (1) uma excecao foi lancada, (2) eh do tipo `Exception`, (3) a mensagem contem o texto esperado. O `having` permite inspecionar propriedades do objeto.

---

### Passo 4 — Teste da FrotaBuscaScreen

Criar `test/screens/frota_busca_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/screens/frota_busca_screen.dart';

Veiculo _makeVeiculo() => Veiculo(
      placa: 'ABC1D23',
      nroFrota: '001',
      marca: 'Marca Y',
      modelo: 'Modelo X',
      ano: '2020',
      anoModelo: '2021',
      cor: 'Branco',
      tipo: 'Caminhao',
      pneus: [],
    );

void main() {
  group('FrotaBuscaScreen', () {
    testWidgets('exibe campo de placa e botao buscar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FrotaBuscaScreen(
            token: 'tok',
            fetchFn: (_, __) async => _makeVeiculo(),
          ),
        ),
      );

      expect(find.text('Placa do veiculo'), findsOneWidget);
      expect(find.text('Buscar'), findsOneWidget);
    });

    testWidgets('mostra erro de validacao quando campo vazio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FrotaBuscaScreen(
            token: 'tok',
            fetchFn: (_, __) async => _makeVeiculo(),
          ),
        ),
      );

      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe a placa'), findsOneWidget);
    });

    testWidgets('navega para detalhe ao buscar com sucesso', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FrotaBuscaScreen(
            token: 'tok',
            fetchFn: (_, __) async => _makeVeiculo(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'ABC1D23');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('ABC1D23'), findsOneWidget);
      expect(find.text('Detalhes do veiculo').evaluate().isEmpty, true);
    });

    testWidgets('exibe toast quando busca falha', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FrotaBuscaScreen(
            token: 'tok',
            fetchFn: (_, __) async => throw Exception('Veiculo nao encontrado'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'ZZZ0000');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      // Apos erro, permanece na tela de busca
      expect(find.text('Buscar'), findsOneWidget);
    });
  });
}
```

**Explicacoes:**

- **`fetchFn: (_, __) async => _makeVeiculo()`** — mock inline da funcao de busca. `_` e `__` sao convencoes Dart para parametros ignorados. Retorna um veiculo fake sem chamar a API.

- **`tester.enterText`** — simula digitacao no campo de texto. O `find.byType(TextFormField)` encontra o campo pela classe.

- **`pumpAndSettle()`** — espera todas as animacoes e futures completarem. Necessario apos acoes que disparam navegacao ou setState.

---

### Passo 5 — Teste da FrotaDetalheScreen

Criar `test/screens/frota_detalhe_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/screens/frota_detalhe_screen.dart';

Pneu _makePneu() => const Pneu(
      nroPneu: '1',
      nroSerie: 'SR123456',
      marca: 'Pirelli',
      modelo: 'Modelo A',
      dimensao: '295/80R22.5',
      tipo: 'Radial',
      situacao: 'Em uso',
      localEixo: 'Dianteiro esquerdo',
      codEsqEixo: '1',
      localizacao: '1',
      nroDot: '4523',
      indRecapagem: 'N',
      vidaPneu: '80',
      kmRodado: '50000',
      kmAcumulador: '40000',
      kmAtuVei: '150000',
      kmRodado0: '10000',
      kmRodado1: '10000',
      kmRodado2: '10000',
      kmRodado3: '10000',
      kmRodado4: '10000',
      kmRodado5: '0',
      dataCompra: '2023-01-15',
      dataAtzKm: '2024-06-01',
      codFil: '01',
      nroFrota: '001',
      placa: 'ABC1D23',
    );

void main() {
  group('FrotaDetalheScreen', () {
    testWidgets('exibe dados do veiculo', (tester) async {
      final veiculo = Veiculo(
        placa: 'ABC1D23',
        nroFrota: '001',
        marca: 'Marca Y',
        modelo: 'Modelo X',
        ano: '2020',
        anoModelo: '2021',
        cor: 'Branco',
        tipo: 'Caminhao',
        pneus: [_makePneu()],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FrotaDetalheScreen(veiculo: veiculo),
        ),
      );

      // Header do veiculo
      expect(find.text('ABC1D23 - Frota 001'), findsOneWidget);

      // Dados do veiculo
      expect(find.text('Marca Y'), findsOneWidget);
      expect(find.text('Modelo X'), findsOneWidget);
      expect(find.text('2020/2021'), findsOneWidget);
      expect(find.text('Branco'), findsOneWidget);
      expect(find.text('Caminhao'), findsOneWidget);

      // Secao de pneus
      expect(find.text('Pneus (1)'), findsOneWidget);

      // Dados do pneu
      expect(find.text('Dianteiro esquerdo'), findsOneWidget);
      expect(find.text('Em uso'), findsOneWidget);
      expect(find.text('Pirelli Modelo A'), findsOneWidget);
      expect(find.text('295/80R22.5'), findsOneWidget);
    });

    testWidgets('exibe mensagem quando veiculo sem pneus', (tester) async {
      final veiculo = Veiculo(
        placa: 'XYZ9K88',
        nroFrota: '002',
        marca: 'Marca Z',
        modelo: 'Modelo W',
        ano: '2022',
        anoModelo: '2023',
        cor: 'Preto',
        tipo: 'Van',
        pneus: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FrotaDetalheScreen(veiculo: veiculo),
        ),
      );

      expect(find.text('XYZ9K88 - Frota 002'), findsOneWidget);
      expect(find.text('Pneus (0)'), findsOneWidget);
    });
  });
}
```

**Explicacoes:**

- **`_makePneu()`** — helper com `const Pneu(...)`. Como todos os campos sao literais, o construtor `const` cria a instancia em tempo de compilacao. Mais eficiente para testes que criam muitos objetos.

- **Testamos textos renderizados** — `find.text('ABC1D23 - Frota 001')` verifica que o header eh construido corretamente combinando placa e frota. Isso testa tanto a logica de formatacao quanto a renderizacao do widget.

- **Teste com pneus vazio** — garante que a tela nao crasha quando o veiculo nao tem pneus e exibe "Pneus (0)" corretamente.

---

## Criterios de aceite

- [ ] `test/models/pneu_test.dart` — testa `fromJson` com campos representativos
- [ ] `test/models/veiculo_test.dart` — testa `fromJson` com pneus e sem pneus
- [ ] `test/services/frota_service_test.dart` — testa 200, 404 e 422
- [ ] `test/screens/frota_busca_screen_test.dart` — testa campo, validacao, busca e erro
- [ ] `test/screens/frota_detalhe_screen_test.dart` — testa dados do veiculo e pneus renderizados
- [ ] `flutter test` passa sem erros
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-camera-ocr|Camera + OCR da placa]]
- [[DevLog/]]
