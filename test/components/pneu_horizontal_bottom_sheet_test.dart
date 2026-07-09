import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/components/pneu_horizontal_bottom_sheet.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/pneu_acao.dart';
import 'package:frota_facil_mobile/models/pneu_movimentacao.dart';
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

/// Host com um botão que abre a sheet horizontal. Recebe a combinação
/// origem→destino a testar e um onResult que captura o valor com que a sheet
/// fecha (espelha o buildHost de pneu_movimentacao_bottom_sheet_test.dart).
Widget buildHost({
  required http.Client client,
  PneuAcao origem = PneuAcao.estoque,
  PneuAcao destino = PneuAcao.conserto,
  void Function(bool?)? onResult,
}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider()..setToken('tok'),
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final r = await showPneuHorizontalSheet(
                context,
                buildPneu(),
                origem,
                destino,
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

/// MockClient que ROTEIA por método/URL da requisição. O MockClient do
/// package:http intercepta cada chamada e devolve a Response que retornarmos
/// aqui — sem rede real. Os GET entregam as listas de apoio (fornecedores /
/// motivos de sucateamento) conforme o path; o POST de movimentação captura o
/// corpo enviado em [onPost] e responde sucesso no contrato {sucesso, mensagem}.
MockClient roteador(void Function(Map<String, dynamic>) onPost) {
  return MockClient((req) async {
    if (req.method == 'GET') {
      // Chaves camelCase minúsculo, iguais às que Fornecedor.fromJson espera.
      if (req.url.path.contains('getfornecedor')) {
        return http.Response(
          jsonEncode([
            {
              'cgccpfforne': '11111111111111',
              'razaosocial': 'FORN A',
              'nomefantasia': 'A',
            }
          ]),
          200,
        );
      }
      // Chaves que MotivoSucateamento.fromJson espera (codsuc/descricao).
      if (req.url.path.contains('getsucata')) {
        return http.Response(
          jsonEncode([
            {'codsuc': 7, 'descricao': 'DESGASTE'}
          ]),
          200,
        );
      }
      // Demais GET (não esperados nestes fluxos): lista vazia.
      return http.Response(jsonEncode([]), 200);
    }
    // POST /pneu/movimentarpneu — captura o corpo e responde sucesso.
    onPost(jsonDecode(req.body) as Map<String, dynamic>);
    return http.Response(
      jsonEncode({'sucesso': true, 'mensagem': 'OK'}),
      200,
    );
  });
}

void main() {
  // Smoke test: garante que a sheet horizontal (a maior/mais complexa) constrói
  // sem crashar com o pneu pré-selecionado e renderiza a barra de ações. O teste
  // de payload completo (com seleção de fornecedor/motivo por combinação
  // origem→destino) fica como próximo passo.
  testWidgets('sheet horizontal (estoque→conserto) abre e mostra os botões',
      (tester) async {
    useLargeViewport(tester);

    // Responde [] a qualquer GET (fornecedores/motivos, se carregados).
    final mock = MockClient((req) async => http.Response(jsonEncode([]), 200));

    await tester.pumpWidget(buildHost(client: mock));

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  // ── Payload por combinação origem→destino ────────────────────────────────
  // Cada teste abre a sheet com o pneu pré-selecionado (buildPneu), preenche
  // só os campos visíveis daquela combinação e confirma o corpo do POST no
  // contrato camelCase minúsculo. Em todos, kmentrada sai null: o fluxo
  // horizontal move entre localizações, nunca envolve KM de veículo.

  testWidgets('conserto→estoque envia valor e observação (motivosaida)',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    bool? resultado;
    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.conserto,
        destino: PneuAcao.estoque,
        onResult: (r) => resultado = r,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Valor do Conserto: o formatter monta "1.500,00" a partir dos dígitos.
    await tester.enterText(
      find.widgetWithText(TextFormField, '0,00'),
      '150000',
    );
    // Sem campo "motivo" nesta combinação, a observação vira o motivosaida.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Observações (opcional)'),
      'devolvido do conserto',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['nropneu'], 12345);
    expect(sentBody!['codfil'], 1);
    expect(sentBody!['localizacao'], 'ESTOQUE');
    expect(sentBody!['valor'], 1500.0);
    expect(sentBody!['motivosaida'], 'devolvido do conserto');
    expect(sentBody!['codmotivosucat'], isNull);
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
    expect(resultado, isNotNull);
  });

  testWidgets('estoque→recapagem envia motivo e valor zero', (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.estoque,
        destino: PneuAcao.recapagem,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Estoque→Recapagem mostra o campo "Motivo" (texto livre), sem Valor.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descreva o motivo'),
      'programada',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'RECAPAGEM');
    expect(sentBody!['motivosaida'], 'programada');
    // Sem campo de valor: o service envia 0.
    expect(sentBody!['valor'], 0);
    expect(sentBody!['codmotivosucat'], isNull);
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('conserto→recapagem envia fornecedor e valor', (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.conserto,
        destino: PneuAcao.recapagem,
      ),
    );

    await tester.tap(find.text('Abrir'));
    // pumpAndSettle aguarda o GET de fornecedores (disparado no initState).
    await tester.pumpAndSettle();

    // Toca no campo Fornecedor pra abrir o sheet de busca...
    await tester.ensureVisible(find.text('Selecione o fornecedor'));
    await tester.tap(find.text('Selecione o fornecedor'));
    await tester.pumpAndSettle();
    // ...e escolhe o item da lista.
    await tester.tap(find.text('FORN A'));
    await tester.pumpAndSettle();

    // Valor da Recauchutagem.
    await tester.enterText(
      find.widgetWithText(TextFormField, '0,00'),
      '25000',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'RECAPAGEM');
    expect(sentBody!['cgccpfforne'], '11111111111111');
    expect(sentBody!['valor'], 250.0);
    expect(sentBody!['codmotivosucat'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('estoque→sucata envia codmotivosucat do dropdown',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.estoque,
        destino: PneuAcao.sucata,
      ),
    );

    await tester.tap(find.text('Abrir'));
    // pumpAndSettle aguarda o GET de motivos de sucateamento.
    await tester.pumpAndSettle();

    // Abre o DropdownButtonFormField (toca no widget, não no hint — o texto do
    // hint fica dentro da decoração e o tap nele "escapa" o alvo) e seleciona.
    final dropdown = find.byType(DropdownButtonFormField<MotivoSucateamento>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    // O texto do item é "7 - DESGASTE" (MotivoSucateamento.label). Uso .last
    // pra pegar a instância no menu suspenso, não a do campo fechado.
    await tester.tap(find.text('7 - DESGASTE').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'SUCATA');
    expect(sentBody!['codmotivosucat'], 7);
    expect(sentBody!['valor'], 0);
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('sucata→venda envia valor e motivo com localizacao VENDA',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.sucata,
        destino: PneuAcao.venda,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Venda mostra Valor da Venda + Motivo (a observação não aparece).
    await tester.enterText(
      find.widgetWithText(TextFormField, '0,00'),
      '99900',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descreva o motivo'),
      'venda avulsa',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'VENDA');
    expect(sentBody!['valor'], 999.0);
    expect(sentBody!['motivosaida'], 'venda avulsa');
    expect(sentBody!['codmotivosucat'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('estoque→venda envia valor e motivo com localizacao VENDA',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.estoque,
        destino: PneuAcao.venda,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Venda mostra Valor da Venda + Motivo (observação não aparece).
    await tester.enterText(find.widgetWithText(TextFormField, '0,00'), '50000');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descreva o motivo'),
      'venda balcao',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'VENDA');
    expect(sentBody!['valor'], 500.0);
    expect(sentBody!['motivosaida'], 'venda balcao');
    expect(sentBody!['codmotivosucat'], isNull);
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('conserto→sucata envia valor do conserto e codmotivosucat',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.conserto,
        destino: PneuAcao.sucata,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle(); // aguarda o GET de motivos de sucateamento

    // Valor do Conserto (origem conserto) + motivo de sucateamento (dropdown).
    await tester.enterText(find.widgetWithText(TextFormField, '0,00'), '30000');
    final dropdown = find.byType(DropdownButtonFormField<MotivoSucateamento>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 - DESGASTE').last);
    await tester.pumpAndSettle();
    // Sem campo "motivo" nesta combinação: a observação vira o motivosaida.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Observações (opcional)'),
      'sucateado pos conserto',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'SUCATA');
    expect(sentBody!['valor'], 300.0);
    expect(sentBody!['codmotivosucat'], 7);
    expect(sentBody!['motivosaida'], 'sucateado pos conserto');
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('recapagem→estoque envia valor da recauchutagem e observação',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.recapagem,
        destino: PneuAcao.estoque,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Valor da Recauchutagem (origem recapagem). O switch "Proibido futura
    // recauchutagem" aparece mas é UI-only — o backend não recebe essa flag.
    await tester.enterText(find.widgetWithText(TextFormField, '0,00'), '12000');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Observações (opcional)'),
      'retorno da recap',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'ESTOQUE');
    expect(sentBody!['valor'], 120.0);
    expect(sentBody!['motivosaida'], 'retorno da recap');
    expect(sentBody!['codmotivosucat'], isNull);
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('recapagem→sucata envia valor e codmotivosucat', (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.recapagem,
        destino: PneuAcao.sucata,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle(); // aguarda o GET de motivos de sucateamento

    await tester.enterText(find.widgetWithText(TextFormField, '0,00'), '8000');
    final dropdown = find.byType(DropdownButtonFormField<MotivoSucateamento>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 - DESGASTE').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'SUCATA');
    expect(sentBody!['valor'], 80.0);
    expect(sentBody!['codmotivosucat'], 7);
    // Observação deixada em branco → motivosaida nulo.
    expect(sentBody!['motivosaida'], isNull);
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });

  testWidgets('recapagem→venda envia valor e motivo com localizacao VENDA',
      (tester) async {
    useLargeViewport(tester);

    Map<String, dynamic>? sentBody;
    final mock = roteador((body) => sentBody = body);

    await tester.pumpWidget(
      buildHost(
        client: mock,
        origem: PneuAcao.recapagem,
        destino: PneuAcao.venda,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // valorLabel prioriza a origem: recapagem→venda mostra "Valor da
    // Recauchutagem" (mesmo com destino Venda), e o campo Motivo da venda.
    await tester.enterText(find.widgetWithText(TextFormField, '0,00'), '45000');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descreva o motivo'),
      'vendido usado',
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmar'));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(sentBody, isNotNull);
    expect(sentBody!['localizacao'], 'VENDA');
    expect(sentBody!['valor'], 450.0);
    expect(sentBody!['motivosaida'], 'vendido usado');
    expect(sentBody!['codmotivosucat'], isNull);
    expect(sentBody!['cgccpfforne'], isNull);
    expect(sentBody!['kmentrada'], isNull);
  });
}
