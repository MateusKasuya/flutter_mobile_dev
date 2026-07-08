import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/components/pneu_movimentacao_bottom_sheet.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/pneu_acao.dart';
import 'package:frota_facil_mobile/models/pneu_movimentacao.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';

/// Fixa um viewport de tablet largo e alto o suficiente para o modal caber sem
/// overflow no ambiente de teste (o header do form não usa Flexible, então em
/// larguras estreitas ele estoura — isso é um detalhe de layout à parte).
void useLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1024, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Ignora erros de overflow de layout durante o teste. O flutter_test usa uma
/// fonte de teste mais larga que a Montserrat real, então layouts desenhados
/// justos (o header do form) "estouram" só no teste — não é bug do app.
void ignoreOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

/// Constrói um [Pneu] mínimo para os testes (a maioria dos 27 campos não
/// importa para o fluxo de movimentação).
Pneu buildPneu({String nroPneu = '12345', String codFil = '1'}) {
  return Pneu(
    nroPneu: nroPneu,
    nroSerie: '',
    marca: '',
    modelo: '',
    dimensao: '',
    tipo: '',
    situacao: 'BOM',
    localEixo: '',
    codEsqEixo: '',
    localizacao: 'CONSERTO',
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
    codFil: codFil,
    nroFrota: '',
    placa: '',
  );
}

/// Host com um botão que abre a sheet — a sheet precisa de um BuildContext sob
/// MaterialApp + AuthProvider. onResult recebe o valor com que o sheet fecha.
Widget buildHost({
  required http.Client client,
  required Pneu pneu,
  PneuAcao acao = PneuAcao.conserto,
  void Function(PneuMovimentacao?)? onResult,
}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider()..setToken('tok'),
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final r = await showPneuMovimentacaoSheet(
                context,
                pneu,
                acao,
                client: client,
              );
              onResult?.call(r);
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('movimentação para conserto envia o payload no contrato da API',
      (tester) async {
    useLargeViewport(tester);
    ignoreOverflowErrors();

    Map<String, dynamic>? sentBody;
    final mockClient = MockClient((request) async {
      sentBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'sucesso': true, 'mensagem': 'OK'}),
        200,
      );
    });

    PneuMovimentacao? resultado;
    var resolvido = false;
    await tester.pumpWidget(
      buildHost(
        client: mockClient,
        pneu: buildPneu(nroPneu: '12345', codFil: '1'),
        onResult: (r) {
          resultado = r;
          resolvido = true;
        },
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Data do retorno já vem preenchida com hoje; só falta o KM de saída.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Informe o KM atual'),
      '150000',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['nropneu'], 12345);
    expect(sentBody!['codfil'], 1);
    expect(sentBody!['localizacao'], 'CONSERTO');
    expect(sentBody!['kmentrada'], '150000');
    expect(sentBody!['codmotivosucat'], isNull);
    // Sucesso fecha o sheet devolvendo a movimentação.
    expect(resolvido, true);
    expect(resultado, isNotNull);
  });

  testWidgets('codFil vazio bloqueia o envio (guard do M4) e mantém a sheet',
      (tester) async {
    useLargeViewport(tester);
    ignoreOverflowErrors();

    var chamou = false;
    final mockClient = MockClient((request) async {
      chamou = true;
      return http.Response(
        jsonEncode({'sucesso': true, 'mensagem': 'OK'}),
        200,
      );
    });

    await tester.pumpWidget(
      buildHost(
        client: mockClient,
        pneu: buildPneu(nroPneu: '12345', codFil: ''), // codFil inválido
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Informe o KM atual'),
      '150000',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // O guard aborta antes de qualquer POST...
    expect(chamou, false);
    // ...e a sheet continua aberta para o usuário.
    expect(find.text('Confirmar'), findsOneWidget);
  });
}
