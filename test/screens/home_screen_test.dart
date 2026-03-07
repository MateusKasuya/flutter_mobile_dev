import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frota_facil_mobile/models/localizacao.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/screens/home_screen.dart';
import 'package:frota_facil_mobile/screens/movimento_screen.dart';

void main() {
  Widget buildApp(Future<List<Localizacao>> Function(String) fetchFn) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..setToken('test-token'),
      child: MaterialApp(
        home: HomeScreen(fetchFn: fetchFn),
      ),
    );
  }

  final mockLocalizacoes = [
    const Localizacao(quantidade: 5, nome: 'ESTOQUE'),
    const Localizacao(quantidade: 10, nome: 'FROTA'),
    const Localizacao(quantidade: 3, nome: 'SUCATA'),
    const Localizacao(quantidade: 7, nome: 'VENDA'),
  ];

  testWidgets('exibe indicador de loading ao abrir', (tester) async {
    final completer = Completer<List<Localizacao>>();
    await tester.pumpWidget(
      buildApp((_) => completer.future),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(mockLocalizacoes);
    await tester.pumpAndSettle();
  });

  testWidgets('exibe 4 cards com nomes e quantidades após carregar',
      (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => mockLocalizacoes),
    );
    await tester.pumpAndSettle();

    expect(find.text('5'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('ESTOQUE'), findsOneWidget);
    expect(find.text('FROTA'), findsOneWidget);
    expect(find.text('SUCATA'), findsOneWidget);
    expect(find.text('VENDA'), findsOneWidget);
  });

  testWidgets('grid tem 2 colunas', (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => mockLocalizacoes),
    );
    await tester.pumpAndSettle();

    final gridView = tester.widget<GridView>(find.byType(GridView));
    expect(
      gridView.gridDelegate,
      isA<SliverGridDelegateWithFixedCrossAxisCount>(),
    );
    expect(
      (gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      2,
    );
  });

  testWidgets('quando service falha permanece na HomeScreen', (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => throw Exception('Erro da API')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('FAB Movimento está visível', (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => mockLocalizacoes),
    );
    await tester.pumpAndSettle();

    expect(find.text('Movimento'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
  });

  testWidgets('ao tocar no FAB navega para MovimentoScreen', (tester) async {
    await tester.pumpWidget(
      buildApp((_) async => mockLocalizacoes),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Movimento'));
    await tester.pumpAndSettle();

    expect(find.byType(MovimentoScreen), findsOneWidget);
  });
}
