import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/models/veiculo.dart';
import 'package:frota_facil_mobile/screens/frota_detalhe_screen.dart';

const _pneu = Pneu(
  nroPneu: '1',
  nroSerie: 'SR123456',
  marca: 'Pirelli',
  modelo: 'Modelo A',
  dimensao: '295/80R22.5',
  tipo: 'Radial',
  situacao: 'Em uso',
  localEixo: 'Dianteiro esquerdo',
  codEsqEixo: '1',
  localizacao: '1',
  nroDot: '4523',
  indRecapagem: 'N',
  vidaPneu: '80',
  kmRodado: '50000',
  kmAcumulador: '40000',
  kmAtuVei: '150000',
  kmRodado0: '10000',
  kmRodado1: '10000',
  kmRodado2: '10000',
  kmRodado3: '10000',
  kmRodado4: '10000',
  kmRodado5: '0',
  dataCompra: '2023-01-15',
  dataAtzKm: '2024-06-01',
  codFil: '01',
  nroFrota: '001',
  placa: 'ABC1D23',
);

void main() {
  group('FrotaDetalheScreen', () {
    testWidgets('exibe dados do veículo e pneu', (tester) async {
      final veiculo = Veiculo(
        placa: 'ABC1D23',
        nroFrota: '001',
        marca: 'Marca Y',
        modelo: 'Modelo X',
        ano: '2020',
        anoModelo: '2021',
        cor: 'Branco',
        tipo: 'Caminhão',
        pneus: [_pneu],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      expect(find.text('ABC1D23 - Frota 001'), findsOneWidget);
      expect(find.text('Marca Y'), findsOneWidget);
      expect(find.text('Modelo X'), findsOneWidget);
      expect(find.text('2020/2021'), findsOneWidget);
      expect(find.text('Branco'), findsOneWidget);
      expect(find.text('Caminhão'), findsOneWidget);
      expect(find.text('Pneus (1)'), findsOneWidget);
      expect(find.text('Dianteiro esquerdo'), findsOneWidget);
      expect(find.text('Pirelli'), findsOneWidget);
      expect(find.text('295/80R22.5'), findsOneWidget);
    });

    testWidgets('exibe Pneus (0) quando veículo sem pneus', (tester) async {
      final veiculo = Veiculo(
        placa: 'XYZ9K88',
        nroFrota: '002',
        marca: 'Marca Z',
        modelo: 'Modelo W',
        ano: '2022',
        anoModelo: '2023',
        cor: 'Preto',
        tipo: 'Van',
        pneus: [],
      );

      await tester.pumpWidget(
        MaterialApp(home: FrotaDetalheScreen(veiculo: veiculo)),
      );

      expect(find.text('XYZ9K88 - Frota 002'), findsOneWidget);
      expect(find.text('Pneus (0)'), findsOneWidget);
    });
  });
}
