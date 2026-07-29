import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/components/pneu_acoes_dialog.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';

import '../helpers/test_viewport.dart';

/// Constrói um [Pneu] na [localizacao] dada; os demais campos não afetam quais
/// cards de ação o diálogo habilita (isso depende só da localização).
///
/// [localEixo] permite simular um pneu montado num eixo (`'1E'`, default) ou
/// num estepe (`'X1'`/`'X2'`) quando [localizacao] é `'FROTA'`.
Pneu _pneuEm(String localizacao, {String? localEixo}) => Pneu(
      nroPneu: '1250',
      nroSerie: 'SN1',
      marca: 'Pirelli',
      modelo: 'Modelo A',
      dimensao: '295/80R22.5',
      tipo: 'Radial',
      situacao: 'Em uso',
      // Pneu montado carrega o slot; fora da frota, vazio.
      localEixo: localEixo ?? (localizacao == 'FROTA' ? '1E' : ''),
      codEsqEixo: '1',
      localizacao: localizacao,
      nroDot: '4523',
      indRecapagem: 'N',
      vidaPneu: '80',
      kmRodado: '50000',
      kmAcumulador: '40000',
      kmAtuVei: '150000',
      kmRodado0: '0',
      kmRodado1: '0',
      kmRodado2: '0',
      kmRodado3: '0',
      kmRodado4: '0',
      kmRodado5: '0',
      dataCompra: '2023-01-15',
      dataAtzKm: '2024-06-01',
      codFil: '01',
      nroFrota: '001',
      placa: 'ABC1D23',
    );

const _veiculo = Veiculo(
  placa: 'ABC1D23',
  nroFrota: '001',
  marca: 'Volvo',
  modelo: 'FH',
  ano: '2020',
  anoModelo: '2020',
  cor: 'Branco',
  tipo: 'Caminhão',
  codEsqEixo: 'ESQ01',
  pneus: [],
);

Future<void> _abrirDialog(
  WidgetTester tester,
  Pneu pneu, {
  Veiculo? veiculo,
  List<String> eixoSlotsVazios = const [],
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showPneuAcoesDialog(
              context,
              pneu,
              veiculo: veiculo,
              eixoSlotsVazios: eixoSlotsVazios,
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

/// Cada card de ação é um `InkWell`; quando desabilitado, seu `onTap` é null.
/// Localiza o card pelo rótulo (ex.: 'ESTOQUE') e diz se está habilitado.
bool _cardHabilitado(WidgetTester tester, String rotulo) {
  final inkWell = tester.widget<InkWell>(
    find.ancestor(of: find.text(rotulo), matching: find.byType(InkWell)).first,
  );
  return inkWell.onTap != null;
}

void main() {
  group('showPneuAcoesDialog', () {
    testWidgets('pneu FROTA oferece Estoque como destino habilitado',
        (tester) async {
      usePhoneViewport(tester);
      await _abrirDialog(tester, _pneuEm('FROTA'));

      // Regressão: um pneu montado (FROTA) precisa poder ser desmontado para o
      // estoque. Antes, um pneu recém-montado mantinha a etiqueta de origem
      // (ESTOQUE) e o card Estoque aparecia como localização atual — cinza —,
      // travando a desmontagem até um refetch do veículo.
      expect(_cardHabilitado(tester, 'ESTOQUE'), isTrue);
    });

    testWidgets('pneu em ESTOQUE desabilita o card Estoque (localização atual)',
        (tester) async {
      usePhoneViewport(tester);
      await _abrirDialog(tester, _pneuEm('ESTOQUE'));

      expect(_cardHabilitado(tester, 'ESTOQUE'), isFalse);
    });
  });

  group('showPneuAcoesDialog — opção Eixo (estepe → eixo)', () {
    testWidgets('pneu de eixo (não estepe) nunca oferece o card Eixo',
        (tester) async {
      usePhoneViewport(tester);
      await _abrirDialog(
        tester,
        _pneuEm('FROTA', localEixo: '1E'),
        veiculo: _veiculo,
        eixoSlotsVazios: const ['2E', '2D'],
      );

      expect(find.text('EIXO'), findsNothing);
    });

    testWidgets('estepe sem veículo/slots informados não oferece o card Eixo',
        (tester) async {
      usePhoneViewport(tester);
      await _abrirDialog(tester, _pneuEm('FROTA', localEixo: 'X1'));

      expect(find.text('EIXO'), findsNothing);
    });

    testWidgets(
        'estepe com veículo e alguma posição de eixo livre oferece o card Eixo',
        (tester) async {
      usePhoneViewport(tester);
      await _abrirDialog(
        tester,
        _pneuEm('FROTA', localEixo: 'X1'),
        veiculo: _veiculo,
        eixoSlotsVazios: const ['2E'],
      );

      expect(find.text('EIXO'), findsOneWidget);
      expect(_cardHabilitado(tester, 'EIXO'), isTrue);
    });

    testWidgets('com um único eixo livre, tocar Eixo abre direto a montagem',
        (tester) async {
      usePhoneViewport(tester);
      await _abrirDialog(
        tester,
        _pneuEm('FROTA', localEixo: 'X1'),
        veiculo: _veiculo,
        eixoSlotsVazios: const ['2E'],
      );

      await tester.tap(find.text('EIXO'));
      await tester.pumpAndSettle();

      // Sem diálogo de escolha (só há um destino): vai direto pro formulário
      // de montagem, com a origem "Estepe" e a posição de destino no header.
      expect(find.text('Mover para qual eixo?'), findsNothing);
      expect(find.text('ESTEPE'), findsOneWidget);
      expect(find.text('Posição 2E'), findsOneWidget);
    });

    testWidgets('com mais de um eixo livre, tocar Eixo pede qual posição',
        (tester) async {
      usePhoneViewport(tester);
      await _abrirDialog(
        tester,
        _pneuEm('FROTA', localEixo: 'X1'),
        veiculo: _veiculo,
        eixoSlotsVazios: const ['2E', '2D'],
      );

      await tester.tap(find.text('EIXO'));
      await tester.pumpAndSettle();

      expect(find.text('Mover para qual eixo?'), findsOneWidget);
      expect(find.text('Posição 2E'), findsOneWidget);
      expect(find.text('Posição 2D'), findsOneWidget);
      // Texto por extenso em destaque — é o que o motorista lê no dia a dia,
      // o código ("Posição 2E"/"2D") vira só um detalhe pequeno abaixo.
      expect(find.text('Eixo 2 - Esquerdo'), findsOneWidget);
      expect(find.text('Eixo 2 - Direito'), findsOneWidget);

      await tester.tap(find.text('Posição 2D'));
      await tester.pumpAndSettle();

      expect(find.text('ESTEPE'), findsOneWidget);
      expect(find.text('Posição 2D'), findsOneWidget);
    });
  });
}
