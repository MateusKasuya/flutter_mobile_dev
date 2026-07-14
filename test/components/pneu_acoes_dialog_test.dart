import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/components/pneu_acoes_dialog.dart';
import 'package:frota_facil_mobile/models/pneu.dart';

import '../helpers/test_viewport.dart';

/// Constrói um [Pneu] na [localizacao] dada; os demais campos não afetam quais
/// cards de ação o diálogo habilita (isso depende só da localização).
Pneu _pneuEm(String localizacao) => Pneu(
      nroPneu: '1250',
      nroSerie: 'SN1',
      marca: 'Pirelli',
      modelo: 'Modelo A',
      dimensao: '295/80R22.5',
      tipo: 'Radial',
      situacao: 'Em uso',
      // Pneu montado carrega o slot; fora da frota, vazio.
      localEixo: localizacao == 'FROTA' ? '1E' : '',
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

Future<void> _abrirDialog(WidgetTester tester, Pneu pneu) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showPneuAcoesDialog(context, pneu),
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
}
