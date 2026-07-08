import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/components/pneu_horizontal_bottom_sheet.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/pneu_acao.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';

/// Viewport de tablet largo/alto para o modal caber sem overflow no teste.
void useLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1024, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Ignora overflow de layout (fonte de teste mais larga que a Montserrat real).
void ignoreOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
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

Widget buildHost({required http.Client client}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider()..setToken('tok'),
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showPneuHorizontalSheet(
              context,
              buildPneu(),
              PneuAcao.estoque,
              PneuAcao.conserto,
              client: client,
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // Smoke test: garante que a sheet horizontal (a maior/mais complexa) constrói
  // sem crashar com o pneu pré-selecionado e renderiza a barra de ações. O teste
  // de payload completo (com seleção de fornecedor/motivo por combinação
  // origem→destino) fica como próximo passo.
  testWidgets('sheet horizontal (estoque→conserto) abre e mostra os botões',
      (tester) async {
    useLargeViewport(tester);
    ignoreOverflowErrors();

    // Responde [] a qualquer GET (fornecedores/motivos, se carregados).
    final mock = MockClient((req) async => http.Response(jsonEncode([]), 200));

    await tester.pumpWidget(buildHost(client: mock));

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });
}
