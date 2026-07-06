import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/screens/frota_busca_screen.dart';

import '../helpers/test_viewport.dart';

Veiculo _makeVeiculo() => const Veiculo(
      placa: 'ABC1D23',
      nroFrota: '001',
      marca: 'Marca Y',
      modelo: 'Modelo X',
      ano: '2020',
      anoModelo: '2021',
      cor: 'Branco',
      tipo: 'Caminhão',
      pneus: [],
    );

Widget _wrap(Widget child) {
  return ChangeNotifierProvider<AuthProvider>(
    create: (_) => AuthProvider()..setToken('tok'),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('FrotaBuscaScreen', () {
    testWidgets('exibe campo de placa e botão buscar', (tester) async {
      await tester.pumpWidget(
        _wrap(FrotaBuscaScreen(fetchFn: (a, b) async => _makeVeiculo())),
      );

      expect(find.text('Placa do veículo'), findsOneWidget);
      expect(find.text('Buscar'), findsOneWidget);
    });

    testWidgets('mostra erro de validação quando campo vazio', (tester) async {
      await tester.pumpWidget(
        _wrap(FrotaBuscaScreen(fetchFn: (a, b) async => _makeVeiculo())),
      );

      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe a placa'), findsOneWidget);
    });

    testWidgets('navega para detalhe ao buscar com sucesso', (tester) async {
      // Viewport de celular: a navegação abre a FrotaDetalheScreen, cujo
      // layout de tablet não cabe no viewport padrão de teste (800x600).
      usePhoneViewport(tester);
      await tester.pumpWidget(
        _wrap(FrotaBuscaScreen(fetchFn: (a, b) async => _makeVeiculo())),
      );

      await tester.enterText(find.byType(TextFormField), 'ABC1D23');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      // No header do detalhe a placa aparece concatenada com a frota,
      // então buscamos o texto completo (find.text exige match exato).
      expect(find.text('ABC1D23 - Frota 001'), findsOneWidget);
    });

    testWidgets('permanece na tela de busca quando busca falha', (tester) async {
      await tester.pumpWidget(
        _wrap(FrotaBuscaScreen(
          fetchFn: (a, b) async => throw Exception('Veiculo nao encontrado'),
        )),
      );

      await tester.enterText(find.byType(TextFormField), 'ZZZ0000');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('Buscar'), findsOneWidget);
    });
  });
}
