import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/screens/pneu_lista_screen.dart';

Pneu buildPneu({required String nroPneu, required String localizacao}) {
  return Pneu(
    nroPneu: nroPneu,
    nroSerie: '',
    marca: 'Pirelli',
    modelo: 'FR85',
    dimensao: '295/80R22.5',
    tipo: 'Radial',
    situacao: 'N',
    localEixo: '',
    codEsqEixo: '',
    localizacao: localizacao,
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
    codFil: '1',
    nroFrota: '',
    placa: '',
  );
}

void main() {
  Widget buildApp(Future<List<Pneu>> Function(String) fetchFn) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..setToken('test-token'),
      child: MaterialApp(
        home: PneuListaScreen(fetchFn: fetchFn),
      ),
    );
  }

  testWidgets('não lista pneus em frota (movimentação é da tela Frotas)',
      (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => [
        buildPneu(nroPneu: '111', localizacao: 'ESTOQUE'),
        buildPneu(nroPneu: '222', localizacao: 'FROTA'),
        // Caixa mista pra garantir que o filtro não depende do
        // maiúsculo/minúsculo vindo da API.
        buildPneu(nroPneu: '333', localizacao: 'Frota'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pneu #111'), findsOneWidget);
    expect(find.text('Pneu #222'), findsNothing);
    expect(find.text('Pneu #333'), findsNothing);
  });

  testWidgets('todos os pneus em frota → estado vazio "Nenhum pneu disponível"',
      (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => [
        buildPneu(nroPneu: '222', localizacao: 'FROTA'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum pneu disponível'), findsOneWidget);
    expect(find.text('Pneu #222'), findsNothing);
  });

  testWidgets('pneus fora da frota continuam aparecendo normalmente',
      (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => [
        buildPneu(nroPneu: '111', localizacao: 'ESTOQUE'),
        buildPneu(nroPneu: '444', localizacao: 'CONSERTO'),
        buildPneu(nroPneu: '555', localizacao: 'RECAPAGEM'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pneu #111'), findsOneWidget);
    expect(find.text('Pneu #444'), findsOneWidget);
    // O ListView.builder só constrói os cards visíveis na viewport do
    // teste; rola até o terceiro card antes de procurá-lo. O scrollable é
    // apontado explicitamente porque o TextField de busca também tem um
    // Scrollable interno e o finder padrão exige que haja um só.
    await tester.scrollUntilVisible(
      find.text('Pneu #555'),
      200,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Pneu #555'), findsOneWidget);
  });
}
