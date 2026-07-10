import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/components/pneu_entrada_bottom_sheet.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/pneu_acao.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';

/// Viewport de tablet largo/alto para o modal caber sem overflow no teste.
void useLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1024, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

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
    localizacao: 'ESTOQUE',
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

Veiculo buildVeiculo({String placa = 'ABC1D23', String nroFrota = '77'}) {
  return Veiculo(
    placa: placa,
    nroFrota: nroFrota,
    marca: '',
    modelo: '',
    ano: '',
    anoModelo: '',
    cor: '',
    tipo: '',
    codEsqEixo: '',
    pneus: const [],
  );
}

Widget buildHost({
  required http.Client client,
  required Pneu pneu,
  required Veiculo veiculo,
  String localEixo = '1DE',
  String codEsqEixo = 'ESQ01',
  PneuAcao origem = PneuAcao.estoque,
  void Function(bool?)? onResult,
}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider()..setToken('tok'),
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final r = await showPneuEntradaSheet(
                context,
                pneu,
                veiculo,
                localEixo,
                codEsqEixo,
                origem,
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
  testWidgets('montagem envia o payload de montagem no contrato da API',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? body;
    final mock = MockClient((req) async {
      body = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'sucesso': true, 'mensagem': 'OK'}),
        200,
      );
    });

    bool? resultado;
    await tester.pumpWidget(
      buildHost(
        client: mock,
        pneu: buildPneu(nroPneu: '12345', codFil: '1'),
        veiculo: buildVeiculo(placa: 'ABC1D23', nroFrota: '77'),
        onResult: (r) => resultado = r,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Informe o KM do veículo'),
      '100000',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(body, isNotNull);
    expect(body!['nropneu'], 12345);
    expect(body!['codfil'], 1);
    expect(body!['localeixo'], '1DE');
    expect(body!['codesqeixo'], 'ESQ01');
    expect(body!['placa'], 'ABC1D23');
    expect(body!['nrofrota'], 77);
    expect(body!['kmentrada'], '100000');
    // Montagem também envia a localização de ORIGEM do pneu, em maiúsculas
    // (a API exige o campo em toda movimentação).
    expect(body!['localizacao'], 'ESTOQUE');
    expect(resultado, isNotNull);
  });

  testWidgets('nroFrota vazio bloqueia a montagem (guard do M4)',
      (tester) async {
    useLargeViewport(tester);

    var chamou = false;
    final mock = MockClient((req) async {
      chamou = true;
      return http.Response(
        jsonEncode({'sucesso': true, 'mensagem': 'OK'}),
        200,
      );
    });

    await tester.pumpWidget(
      buildHost(
        client: mock,
        pneu: buildPneu(),
        veiculo: buildVeiculo(nroFrota: ''), // veículo sem nº de frota
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Informe o KM do veículo'),
      '100000',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // O guard aborta antes do POST e mantém a sheet aberta.
    expect(chamou, false);
    expect(find.text('Confirmar'), findsOneWidget);
  });
}
