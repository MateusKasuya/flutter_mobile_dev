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

// Comportamento da barra de botões fixa (Cancelar/Confirmar) diante do que o
// sistema desenha por cima do sheet. Ela vive FORA do SingleChildScrollView,
// então nada a resgata se for encoberta: não rola. Dois intrusos, e o
// MediaQuery os expõe em campos DIFERENTES — tratar um não cobre o outro:
//
// - o TECLADO (`viewInsets`): a barra precisa não estourar o layout quando ele
//   reduz o espaço, e permanecer visível acima dele;
// - a BARRA DE NAVEGAÇÃO do Android (`padding`): permanente, desenhada por cima
//   porque o app roda edge-to-edge (exigência do targetSdk >= 35).
//
// Os testes exercem o cenário mais apertado: celular alto e estreito, no menor
// sheet de cada família.

// Celular alto/estreito em pontos lógicos (classe iPhone 14 Pro, dpr 1).
const double _screenH = 852;
const double _screenW = 390;
// Altura típica de um teclado de texto num phone alto (com barra de sugestões).
const double _teclado = 340;
// Linha superior do teclado: abaixo dela nada deve ficar visível.
const double _linhaTeclado = _screenH - _teclado; // 512
// Altura típica da barra de 3 botões do Android (a pílula de gesto é ~24pt;
// usamos o caso pior).
const double _barraNavegacao = 48;

// Celular BAIXO, para os testes de barra de navegação (568 é o piso prático do
// Android — mesma altura do perfil 'celular pequeno' da matriz responsiva).
//
// A altura baixa não é decoração, é a condição do teste: o sheet tem uma altura
// MÍNIMA de design, e quando o formulário é menor que ela a diferença sobra
// embaixo da barra de botões. Essa folga acidental já afasta os botões da barra
// de navegação e esconde a regressão — num celular alto o teste passa mesmo com
// o bug presente. Aqui o formulário PREENCHE o sheet, a folga some e a barra de
// botões encosta de fato no rodapé, que é quando o recuo importa.
const double _screenHBaixo = 568;
// Linha superior da barra de navegação: abaixo dela nada deve ficar visível.
const double _linhaBarraNavegacao = _screenHBaixo - _barraNavegacao; // 520

void _phoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(_screenW, _screenH);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Celular baixo COM a barra de navegação do sistema no rodapé (sem teclado).
void _phoneBaixoComBarraNavegacao(WidgetTester tester) {
  tester.view.physicalSize = const Size(_screenW, _screenHBaixo);
  tester.view.devicePixelRatio = 1.0; // lógico == físico
  const barra = FakeViewPadding(bottom: _barraNavegacao);
  tester.view.padding = barra;
  tester.view.viewPadding = barra;
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

  // A barra de navegação do Android é desenhada POR CIMA do sheet: sem recuar o
  // rodapé, os botões nascem parcialmente embaixo dela — encobertos, sem toque e
  // sem scroll que os revele.
  //
  // Cada entrada usa a ação de formulário mais LONGO da sua família (sucata, que
  // tem o campo extra de motivo): junto com o celular baixo, é o que garante que
  // o formulário preencha o sheet e a barra de botões encoste no rodapé — ver a
  // nota em _screenHBaixo.
  final sheets = <String, void Function(BuildContext)>{
    'horizontal': (ctx) => showPneuHorizontalSheet(
        ctx, _pneu(), PneuAcao.estoque, PneuAcao.sucata,
        client: mockVazio),
    'entrada': (ctx) => showPneuEntradaSheet(
        ctx, _pneu(), _veiculo(), '1DE', 'ESQ01', PneuAcao.estoque,
        client: mockVazio),
    'movimentação': (ctx) => showPneuMovimentacaoSheet(
        ctx, _pneu(), PneuAcao.sucata,
        client: mockVazio),
  };

  for (final sheet in sheets.entries) {
    testWidgets('${sheet.key}: botões acima da barra de navegação do Android',
        (tester) async {
      _phoneBaixoComBarraNavegacao(tester);
      await tester.pumpWidget(_host(mockVazio, sheet.value));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'recuar o rodapé não pode estourar o layout do sheet');
      // Medimos o BOTÃO, não o texto dentro dele: o rótulo é centralizado numa
      // caixa de 56pt de altura, então carrega ~20pt de folga própria que
      // mascara o problema — o texto escapa da barra enquanto a base do botão,
      // que é a área de toque, continua embaixo dela.
      expect(tester.getRect(find.widgetWithText(FilledButton, 'Confirmar')).bottom,
          lessThanOrEqualTo(_linhaBarraNavegacao),
          reason: 'Confirmar deve ficar inteiro acima da barra de navegação');
      expect(
          tester.getRect(find.widgetWithText(OutlinedButton, 'Cancelar')).bottom,
          lessThanOrEqualTo(_linhaBarraNavegacao),
          reason: 'Cancelar deve ficar inteiro acima da barra de navegação');
    });
  }

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
