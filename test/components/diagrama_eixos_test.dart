import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frota_facil_mobile/components/diagrama_eixos.dart';
import 'package:frota_facil_mobile/components/diagrama_eixos/primitives.dart';
import 'package:frota_facil_mobile/models/eixo.dart';
import 'package:frota_facil_mobile/models/pneu.dart';

/// Largura que [numero] ocuparia na fonte do rótulo do pneu, sem nenhuma
/// restrição de caixa. `flutter_test_config.dart` carrega a Montserrat de
/// verdade, então esta medida é a mesma do aparelho.
double _larguraNatural(String numero, {required double fontSize}) {
  final tp = TextPainter(
    text: TextSpan(
      text: numero,
      style: GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return tp.width;
}

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

    testWidgets('número de 5 dígitos aparece inteiro no rodado duplo',
        (tester) async {
      // '99999' é o pior caso real: 5 dígitos, todos largos. Na fonte do
      // diagrama ele mede ~31pt contra os 28pt da caixa do rótulo, que tem a
      // largura do pneu. Rodado duplo porque é onde o vizinho fica a 9pt: não
      // há folga nenhuma pro número invadir.
      final eixos = [
        Eixo(
          numero: 1,
          rodadoDuplo: true,
          esquerdoExterno: _makePneu('99999', '1EE'),
          esquerdoInterno: _makePneu('88888', '1EI'),
          direitoExterno: _makePneu('77777', '1DE'),
          direitoInterno: _makePneu('66666', '1DI'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DiagramaEixos(eixos: eixos))),
      );

      // 1) Nada é CORTADO. Se o Text fosse espremido na caixa de 28pt, o
      //    parágrafo mediria 28 e o resto do último dígito viraria corte
      //    silencioso — TextOverflow.clip é o default e não gera erro nenhum,
      //    por isso nem a matriz responsiva pegava isso. Medindo a largura
      //    natural, provamos que ele foi disposto inteiro e que o encolhimento
      //    é por ESCALA (FittedBox), não por tesoura.
      final paragrafo = tester.renderObject<RenderBox>(find.text('99999'));
      expect(
        paragrafo.size.width,
        closeTo(_larguraNatural('99999', fontSize: 10), 0.5),
        reason: 'o número deve ser medido inteiro; espremido na caixa do pneu, '
            'o último dígito seria cortado em silêncio',
      );

      // 2) Já desenhado (escala aplicada), cabe na caixa do próprio pneu — não
      //    invade o pneu vizinho do rodado duplo.
      expect(
        tester.getRect(find.text('99999')).width,
        lessThanOrEqualTo(tireW + 0.01),
        reason: 'depois de escalado, o número não pode passar da largura do pneu',
      );
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

      // O componente renderiza o indicador como 'FRENTE' (maiúsculas).
      expect(find.text('FRENTE'), findsOneWidget);
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

      expect(find.text('FRENTE'), findsNothing);
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
