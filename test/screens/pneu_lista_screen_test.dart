import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/screens/pneu_lista_screen.dart';

Pneu buildPneu({
  required String nroPneu,
  required String localizacao,
  String placa = '',
}) {
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
    placa: placa,
  );
}

/// Intercepta os toasts e devolve a lista (viva) das mensagens exibidas.
///
/// O toast do app é NATIVO: o pacote `fluttertoast` fala com Android/iOS por um
/// MethodChannel — um canal de mensagens entre o Dart e o código da plataforma.
/// Em widget test não existe plataforma nenhuma do outro lado do canal, então a
/// chamada estouraria `MissingPluginException`; como `showErrorToast` não espera
/// o retorno, o erro viraria uma falha assíncrona solta que derruba o teste.
/// Aqui registramos um handler de mentira no lugar do lado nativo: ele só anota
/// a mensagem e responde ok — o que de quebra deixa asseverar o texto do aviso.
List<String> _capturarToasts(WidgetTester tester) {
  const canal = MethodChannel('PonnamKarthik/fluttertoast');
  final mensagens = <String>[];
  final messenger = tester.binding.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(canal, (call) async {
    if (call.method == 'showToast') {
      mensagens.add((call.arguments as Map)['msg'] as String);
    }
    return true;
  });
  // Desfaz o mock ao fim do teste para não vazar para os seguintes.
  addTearDown(() => messenger.setMockMethodCallHandler(canal, null));

  return mensagens;
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

  testWidgets('lista pneus montados em frota — a consulta é livre',
      (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => [
        buildPneu(nroPneu: '111', localizacao: 'ESTOQUE'),
        buildPneu(nroPneu: '222', localizacao: 'FROTA'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pneu #111'), findsOneWidget);
    expect(find.text('Pneu #222'), findsOneWidget);
  });

  testWidgets('sem pneu nenhum → estado vazio "Nenhum pneu cadastrado"',
      (tester) async {
    await tester.pumpWidget(buildApp((_) async => []));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum pneu cadastrado'), findsOneWidget);
  });

  testWidgets('toque em pneu montado avisa e não abre as ações',
      (tester) async {
    final toasts = _capturarToasts(tester);
    await tester.pumpWidget(
      buildApp((_) async => [
        buildPneu(nroPneu: '222', localizacao: 'FROTA', placa: 'ABC1D23'),
        // Caixa mista e sem placa: o bloqueio não depende do maiúsculo/
        // minúsculo vindo da API, e sem placa o aviso cai no texto genérico.
        buildPneu(nroPneu: '333', localizacao: 'Frota'),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pneu #222'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pneu #333'));
    await tester.pumpAndSettle();

    // Depois de exibir, o fluttertoast agenda um Future.delayed com a duração
    // do toast para limpar um flag interno dele. O relógio do teste é falso e
    // não anda sozinho: sem adiantá-lo, o teste termina com esse timer ainda
    // pendente e o binding falha com "A Timer is still pending". 10s cobrem
    // com folga os 5s que o showErrorToast pede.
    await tester.pump(const Duration(seconds: 10));

    // 'Selecione uma opção' é o subtítulo do diálogo de ações: ele não pode
    // ter aberto para um pneu montado.
    expect(find.text('Selecione uma opção'), findsNothing);
    expect(toasts, [
      'Pneu montado no veículo ABC1D23. Movimente pela tela Frotas.',
      'Pneu montado em veículo. Movimente pela tela Frotas.',
    ]);
  });

  testWidgets('toque em pneu fora da frota abre as ações normalmente',
      (tester) async {
    final toasts = _capturarToasts(tester);
    await tester.pumpWidget(
      buildApp((_) async => [
        buildPneu(nroPneu: '111', localizacao: 'ESTOQUE'),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pneu #111'));
    await tester.pumpAndSettle();

    expect(find.text('Selecione uma opção'), findsOneWidget);
    expect(toasts, isEmpty);
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
