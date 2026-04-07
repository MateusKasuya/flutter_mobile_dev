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
      // GestureDetector com onDoubleTap adia o onTap pelo timeout de duplo clique
      await tester.pump(const Duration(milliseconds: 500));
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

    testWidgets('double tap chama onPneuDoubleTap', (tester) async {
      Pneu? doubleTappedPneu;
      final pneu = _makePneu('2396', '1D');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramaEixos(
              eixos: [Eixo(numero: 1, direitoExterno: pneu)],
              onPneuDoubleTap: (p) => doubleTappedPneu = p,
            ),
          ),
        ),
      );

      await tester.tap(find.text('2396'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2396'));
      await tester.pumpAndSettle();

      expect(doubleTappedPneu, isNotNull);
      expect(doubleTappedPneu!.nroPneu, '2396');
    });
  });
}
