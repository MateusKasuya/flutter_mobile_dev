import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/components/pneu_entrada_bottom_sheet.dart';
import 'package:frota_facil_mobile/components/pneu_horizontal_bottom_sheet.dart';
import 'package:frota_facil_mobile/components/pneu_movimentacao_bottom_sheet.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/pneu_acao.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';

// Comportamento da barra de botões fixa (Cancelar/Confirmar) com o teclado
// aberto: ela vive FORA do SingleChildScrollView, então precisa (1) não estourar
// o layout quando o teclado reduz o espaço e (2) permanecer visível ACIMA do
// teclado — o objetivo da mudança. Estes testes exercem o cenário mais apertado:
// celular alto e estreito com um teclado de 340pt (teclado de texto), no menor
// sheet de cada família.

// Celular alto/estreito em pontos lógicos (classe iPhone 14 Pro, dpr 1).
const double _screenH = 852;
const double _screenW = 390;
// Altura típica de um teclado de texto num phone alto (com barra de sugestões).
const double _teclado = 340;
// Linha superior do teclado: abaixo dela nada deve ficar visível.
const double _linhaTeclado = _screenH - _teclado; // 512

void _phoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(_screenW, _screenH);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Pneu _pneu() => Pneu(
      nroPneu: '12345', nroSerie: '', marca: '', modelo: '', dimensao: '',
      tipo: '', situacao: 'BOM', localEixo: '', codEsqEixo: '',
      localizacao: 'ESTOQUE', nroDot: '', indRecapagem: '', vidaPneu: '',
      kmRodado: '', kmAcumulador: '', kmAtuVei: '', kmRodado0: '', kmRodado1: '',
      kmRodado2: '', kmRodado3: '', kmRodado4: '', kmRodado5: '', dataCompra: '',
      dataAtzKm: '', codFil: '1', nroFrota: '', placa: '',
    );

Veiculo _veiculo() => Veiculo(
      placa: 'ABC1D23', nroFrota: '77', marca: '', modelo: '', ano: '',
      anoModelo: '', cor: '', tipo: '', codEsqEixo: '', pneus: const [],
    );

/// ScrollBehavior que força BouncingScrollPhysics (iOS) em qualquer plataforma —
/// usado no teste de arrasto pra que o "puxar pra baixo" no topo gere scroll
/// (bounce), condição pro onDrag disparar.
class _BouncingBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}

/// Host com um botão que dispara [open] (que abre o sheet sob teste).
Widget _host(
  http.Client client,
  void Function(BuildContext) open, {
  ScrollBehavior? scrollBehavior,
}) =>
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..setToken('tok'),
      child: MaterialApp(
        scrollBehavior: scrollBehavior,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => open(context),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

/// Sobe o teclado (inset de [_teclado]) e valida que a barra de botões não
/// estourou e continua visível acima da linha do teclado.
Future<void> _teclaSobeEBotoesVisiveis(WidgetTester tester) async {
  tester.view.viewInsets = const FakeViewPadding(bottom: _teclado);
  await tester.pump();

  expect(tester.takeException(), isNull,
      reason: 'a barra de botões fixa não pode estourar com o teclado aberto');
  expect(tester.getBottomLeft(find.text('Confirmar')).dy,
      lessThanOrEqualTo(_linhaTeclado),
      reason: 'Confirmar deve ficar acima do teclado');
  expect(tester.getBottomLeft(find.text('Cancelar')).dy,
      lessThanOrEqualTo(_linhaTeclado),
      reason: 'Cancelar deve ficar acima do teclado');
}

void main() {
  final mockVazio =
      MockClient((req) async => http.Response(jsonEncode([]), 200));

  testWidgets('horizontal (estoque→recapagem): repouso em 520 e botões acima '
      'do teclado', (tester) async {
    _phoneViewport(tester);
    await tester.pumpWidget(_host(
      mockVazio,
      (ctx) => showPneuHorizontalSheet(
        ctx, _pneu(), PneuAcao.estoque, PneuAcao.recapagem,
        client: mockVazio),
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Em repouso o sheet fica na altura de design (não cresceu sem teclado).
    expect(tester.getSize(find.byType(BottomSheet)).height, closeTo(520, 1));

    await _teclaSobeEBotoesVisiveis(tester);
  });

  testWidgets('entrada (montagem): repouso em 658 e botões acima do teclado',
      (tester) async {
    _phoneViewport(tester);
    await tester.pumpWidget(_host(
      mockVazio,
      (ctx) => showPneuEntradaSheet(
        ctx, _pneu(), _veiculo(), '1DE', 'ESQ01', PneuAcao.estoque,
        client: mockVazio),
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(BottomSheet)).height, closeTo(658, 1));

    await _teclaSobeEBotoesVisiveis(tester);
  });

  testWidgets('movimentação (conserto): botões acima do teclado', (tester) async {
    _phoneViewport(tester);
    await tester.pumpWidget(_host(
      mockVazio,
      (ctx) => showPneuMovimentacaoSheet(
        ctx, _pneu(), PneuAcao.conserto,
        client: mockVazio),
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await _teclaSobeEBotoesVisiveis(tester);
  });

  testWidgets('arrastar o formulário pra baixo fecha o teclado', (tester) async {
    // BouncingScrollPhysics: o arrasto-pra-baixo no topo gera um
    // ScrollUpdateNotification (o "bounce"), que dispara o
    // ScrollViewKeyboardDismissBehavior.onDrag — o gesto de "puxar o teclado
    // pra baixo" que o usuário descreveu (comportamento nativo do iOS).
    _phoneViewport(tester);
    await tester.pumpWidget(_host(
      mockVazio,
      (ctx) => showPneuMovimentacaoSheet(
        ctx, _pneu(), PneuAcao.conserto,
        client: mockVazio),
      scrollBehavior: _BouncingBehavior(),
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Foca o KM de saída: abre a conexão de input (teclado "visível").
    await tester.tap(find.widgetWithText(TextFormField, 'Informe o KM atual'));
    // Teclado aberto reduz o espaço → o formulário fica rolável (pré-condição
    // pra que o arrasto seja reconhecido como scroll).
    tester.view.viewInsets = const FakeViewPadding(bottom: _teclado);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue,
        reason: 'ao focar o campo, o teclado deve estar aberto');

    // Arrasta o scroll pra baixo — onDrag dispensa o teclado (fecha a conexão).
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, 250));
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isFalse,
        reason: 'arrastar pra baixo deve fechar o teclado');
  });
}
