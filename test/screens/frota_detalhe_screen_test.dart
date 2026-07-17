import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/components/diagrama_eixos.dart';
import 'package:frota_facil_mobile/components/diagrama_eixos/primitives.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/screens/frota_detalhe_screen.dart';

import '../helpers/test_viewport.dart';

/// [_pneu] com outro número e posição; os demais campos não afetam o layout.
Pneu _pneuEm(String nroPneu, String localEixo) =>
    _pneu.copyWith(nroPneu: nroPneu, localEixo: localEixo);

const _pneu = Pneu(
  nroPneu: '1',
  nroSerie: 'SR123456',
  marca: 'Pirelli',
  modelo: 'Modelo A',
  dimensao: '295/80R22.5',
  tipo: 'Radial',
  situacao: 'Em uso',
  localEixo: '1E',
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
    testWidgets('exibe dados do veículo', (tester) async {
      usePhoneViewport(tester);
      final veiculo = Veiculo(
        placa: 'ABC1D23',
        nroFrota: '001',
        marca: 'Marca Y',
        modelo: 'Modelo X',
        ano: '2020',
        anoModelo: '2021',
        cor: 'Branco',
        tipo: 'Caminhão',
        codEsqEixo: '1',
        pneus: [_pneu],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      expect(find.text('ABC1D23 - Frota 001'), findsOneWidget);
      expect(find.text('Marca Y'), findsOneWidget);
      expect(find.text('Modelo X'), findsOneWidget);
      expect(find.text('2020/2021'), findsOneWidget);
      expect(find.text('Branco'), findsOneWidget);
      expect(find.text('Caminhão'), findsOneWidget);
    });

    testWidgets('exibe número do pneu no diagrama', (tester) async {
      usePhoneViewport(tester);
      final veiculo = Veiculo(
        placa: 'ABC1D23',
        nroFrota: '001',
        marca: 'Marca Y',
        modelo: 'Modelo X',
        ano: '2020',
        anoModelo: '',
        cor: 'Branco',
        tipo: 'Caminhão',
        codEsqEixo: '1',
        pneus: [_pneu],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets(
        'veículo sem pneus mas com esquema conhecido desenha o chassi vazio',
        (tester) async {
      usePhoneViewport(tester);
      // 'A' (TOCO) → 2 eixos, mesmo sem nenhum pneu montado.
      final veiculo = Veiculo(
        placa: 'XYZ9K88',
        nroFrota: '002',
        marca: 'Marca Z',
        modelo: 'Modelo W',
        ano: '2022',
        anoModelo: '2023',
        cor: 'Preto',
        tipo: 'Van',
        codEsqEixo: 'A',
        pneus: [],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      expect(find.text('XYZ9K88 - Frota 002'), findsOneWidget);
      // O diagrama agora é desenhado: indicador 'FRENTE' e os 2 eixos.
      expect(find.text('FRENTE'), findsOneWidget);
      expect(find.text('E1'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
    });

    testWidgets(
        'veículo com pneu em só um eixo desenha os demais eixos do esquema',
        (tester) async {
      usePhoneViewport(tester);
      // Esquema 'A' (TOCO) = 2 eixos, mas só o eixo 1 tem pneu (_pneu, '1E').
      final veiculo = Veiculo(
        placa: 'ABC1D23',
        nroFrota: '001',
        marca: 'Marca Y',
        modelo: 'Modelo X',
        ano: '2020',
        anoModelo: '2021',
        cor: 'Branco',
        tipo: 'Caminhão',
        codEsqEixo: 'A',
        pneus: [_pneu],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      // O pneu do eixo 1 aparece, e o eixo 2 (sem pneu) também é desenhado.
      expect(find.text('1'), findsOneWidget); // nº do pneu montado
      expect(find.text('E1'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
    });

    testWidgets('diagrama não fica sob a barra de navegação do Android',
        (tester) async {
      useViewport(tester, kCelularComBarraNavegacao);
      final veiculo = Veiculo(
        placa: 'ABC1D23',
        nroFrota: '001',
        marca: 'Marca Y',
        modelo: 'Modelo X',
        ano: '2020',
        anoModelo: '2021',
        cor: 'Branco',
        tipo: 'Caminhão',
        codEsqEixo: 'A',
        pneus: [_pneu],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      // Regressão vista em aparelho físico: esta tela é um Column com o
      // diagrama num Expanded e NENHUM scroll. Sem recuar o rodapé, o diagrama
      // se estica até o último pixel e o eixo de baixo fica sob a barra de
      // navegação — invisível, sem toque e sem scroll que o revele.
      final limite =
          kCelularComBarraNavegacao.tamanhoLogico.height - kAlturaBarraNavegacao;
      expect(
        tester.getRect(find.byType(DiagramaEixos)).bottom,
        lessThanOrEqualTo(limite),
      );
    });

    // Veículo real de homologação (placa FBW5J92): esquema 'D' = 4 eixos, sendo
    // 3 de rodado duplo — o chassi mais largo do app — mais os 2 estepes.
    Veiculo veiculoComEstepes() => Veiculo(
          placa: 'FBW5J92',
          nroFrota: '9999',
          marca: 'AUDI',
          modelo: 'A3',
          ano: '2020',
          anoModelo: '2021',
          cor: 'Branco',
          tipo: 'Caminhão',
          codEsqEixo: 'D',
          pneus: [
            _pneuEm('1334', '2EE'),
            _pneuEm('937', '2EI'),
            _pneuEm('1361', 'X1'),
            _pneuEm('1380', 'X2'),
          ],
        );

    /// Os `PneuTile`s da faixa de estepe (os slots X1/X2). Os slots não têm mais
    /// rótulo visual, então a âncora é a própria faixa: contam-se os tiles
    /// dentro dela.
    Finder estepeTiles() => find.descendant(
          of: find.byType(EstepeBand),
          matching: find.byType(PneuTile),
        );

    testWidgets('estepes aparecem na faixa própria', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculoComEstepes())),
      );

      expect(find.text('ESTEPE'), findsOneWidget);
      // 2 slots na faixa, sem rótulo individual.
      expect(estepeTiles(), findsNWidgets(2));
      // Os estepes são pneus montados como os outros: mostram o número.
      expect(find.text('1361'), findsOneWidget);
      expect(find.text('1380'), findsOneWidget);
    });

    testWidgets('a faixa de estepe fica ACIMA do diagrama de eixos',
        (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculoComEstepes())),
      );

      // O pedido do produto: estepe no topo, não ao lado. O rótulo ESTEPE e o
      // número do estepe (1361) têm de ficar verticalmente acima do 1º eixo.
      final estepeY = tester.getCenter(find.text('ESTEPE')).dy;
      final estepePneuY = tester.getCenter(find.text('1361')).dy;
      final e1Y = tester.getCenter(find.text('E1')).dy;
      expect(estepeY, lessThan(e1Y),
          reason: 'o rótulo ESTEPE deve ficar acima do 1º eixo');
      expect(estepePneuY, lessThan(e1Y),
          reason: 'os slots de estepe devem ficar acima dos eixos');
    });

    testWidgets('os 2 slots de estepe aparecem mesmo sem nenhum estepe',
        (tester) async {
      usePhoneViewport(tester);
      // Sem os slots vazios não haveria como MONTAR um pneu no estepe.
      final veiculo = Veiculo(
        placa: 'ABC1D23',
        nroFrota: '001',
        marca: 'Marca Y',
        modelo: 'Modelo X',
        ano: '2020',
        anoModelo: '2021',
        cor: 'Branco',
        tipo: 'Caminhão',
        codEsqEixo: 'A',
        pneus: [_pneu],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      expect(find.text('ESTEPE'), findsOneWidget);
      expect(estepeTiles(), findsNWidgets(2));
    });

    testWidgets('chassi mais largo + estepes no celular pequeno sem overflow',
        (tester) async {
      // Celular pequeno (320) é o piso do Android. Com a faixa ACIMA (e não ao
      // lado), o estepe não disputa mais largura com os eixos — os dois pneus
      // somam ~60pt e sobra folga de sobra. O que importa agora é (1) nada
      // estoura e (2) os rótulos dos 4 eixos mantêm a largura de design, já que
      // o chassi recebe a faixa horizontal inteira.
      useViewport(tester, kCelularPequeno);
      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculoComEstepes())),
      );

      expect(tester.takeException(), isNull,
          reason: 'a faixa de estepe não pode estourar o diagrama');

      final rotulos = find.byType(EixoLabel);
      expect(rotulos, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        expect(
          tester.getSize(rotulos.at(i)).width,
          closeTo(26, 0.5),
          reason: 'o rótulo do eixo E${i + 1} não pode ter sido espremido',
        );
      }
    });

    testWidgets(
        'veículo sem pneus e esquema desconhecido não desenha diagrama',
        (tester) async {
      usePhoneViewport(tester);
      // '1' não corresponde a nenhum esquema → sem esqueleto pra desenhar.
      final veiculo = Veiculo(
        placa: 'XYZ9K88',
        nroFrota: '002',
        marca: 'Marca Z',
        modelo: 'Modelo W',
        ano: '2022',
        anoModelo: '2023',
        cor: 'Preto',
        tipo: 'Van',
        codEsqEixo: '1',
        pneus: [],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      expect(find.text('XYZ9K88 - Frota 002'), findsOneWidget);
      expect(find.text('FRENTE'), findsNothing);
    });
  });
}
