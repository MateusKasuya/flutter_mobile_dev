import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/utils/eixo_utils.dart';

/// Helper para criar um Pneu com apenas os campos relevantes para o teste.
Pneu _makePneu(String nroPneu, String localEixo) {
  return Pneu(
    nroPneu: nroPneu,
    nroSerie: '',
    marca: '',
    modelo: '',
    dimensao: '',
    tipo: '',
    situacao: '',
    localEixo: localEixo,
    codEsqEixo: 'A',
    localizacao: '',
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
    codFil: '',
    nroFrota: '',
    placa: '',
  );
}

void main() {
  group('buildEixoLayout', () {
    test('organiza TOCO com 6 pneus em 2 eixos', () {
      final pneus = [
        _makePneu('1272', '2EE'),
        _makePneu('1280', '2DE'),
        _makePneu('1334', '2DI'),
        _makePneu('1353', '2EI'),
        _makePneu('2396', '1D'),
        _makePneu('2397', '1E'),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos.length, 2);

      // Eixo 1 — simples
      expect(eixos[0].numero, 1);
      expect(eixos[0].rodadoDuplo, false);
      expect(eixos[0].direitoExterno?.nroPneu, '2396');
      expect(eixos[0].esquerdoExterno?.nroPneu, '2397');
      expect(eixos[0].direitoInterno, isNull);
      expect(eixos[0].esquerdoInterno, isNull);

      // Eixo 2 — duplo
      expect(eixos[1].numero, 2);
      expect(eixos[1].rodadoDuplo, true);
      expect(eixos[1].direitoExterno?.nroPneu, '1280');
      expect(eixos[1].direitoInterno?.nroPneu, '1334');
      expect(eixos[1].esquerdoExterno?.nroPneu, '1272');
      expect(eixos[1].esquerdoInterno?.nroPneu, '1353');
    });

    test('resultado é ordenado por número do eixo', () {
      final pneus = [
        _makePneu('100', '2DE'),
        _makePneu('200', '1D'),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos[0].numero, 1);
      expect(eixos[1].numero, 2);
    });

    test('ignora pneus com localEixo vazio', () {
      final pneus = [
        _makePneu('100', '1D'),
        _makePneu('200', ''),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos.length, 1);
      expect(eixos[0].direitoExterno?.nroPneu, '100');
    });

    test('retorna lista vazia quando não há pneus', () {
      final eixos = buildEixoLayout([]);
      expect(eixos, isEmpty);
    });

    test('ignora pneu cujo localEixo não começa com número (ex: "X")', () {
      // Dado legado/estepe: localEixo sem eixo numerado não pode quebrar a
      // tela (int.parse('X') lançaria FormatException).
      final pneus = [
        _makePneu('100', '1D'),
        _makePneu('999', 'X'),
        _makePneu('888', 'XD'),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos.length, 1);
      expect(eixos[0].numero, 1);
      expect(eixos[0].direitoExterno?.nroPneu, '100');
    });

    test('eixo com apenas um lado preenchido funciona', () {
      final pneus = [
        _makePneu('100', '1D'),
      ];

      final eixos = buildEixoLayout(pneus);

      expect(eixos.length, 1);
      expect(eixos[0].direitoExterno?.nroPneu, '100');
      expect(eixos[0].esquerdoExterno, isNull);
    });
  });

  group('buildEixoLayout com esquema (codEsqEixo)', () {
    test('TOCO (A) sem pneus gera 2 eixos vazios: simples + duplo', () {
      final eixos = buildEixoLayout([], 'A');

      expect(eixos.length, 2);

      expect(eixos[0].numero, 1);
      expect(eixos[0].rodadoDuplo, false);
      expect(eixos[1].numero, 2);
      expect(eixos[1].rodadoDuplo, true);

      // Todos os slots começam vazios (nenhum pneu montado).
      for (final e in eixos) {
        expect(e.esquerdoExterno, isNull);
        expect(e.esquerdoInterno, isNull);
        expect(e.direitoExterno, isNull);
        expect(e.direitoInterno, isNull);
      }
    });

    test('truckD (D) sem pneus gera 4 eixos: 1 simples + 3 duplos', () {
      final eixos = buildEixoLayout([], 'D');

      expect(eixos.map((e) => e.numero), [1, 2, 3, 4]);
      expect(eixos.map((e) => e.rodadoDuplo), [false, true, true, true]);
    });

    test('código minúsculo é aceito (delega ao fromCodigo)', () {
      final eixos = buildEixoLayout([], 'p');
      expect(eixos.length, 4);
      expect(eixos.every((e) => e.rodadoDuplo), true);
    });

    test('código desconhecido sem pneus retorna lista vazia', () {
      expect(buildEixoLayout([], '1'), isEmpty);
      expect(buildEixoLayout([], ''), isEmpty);
    });

    test('completa eixos faltantes: pneu só no eixo 1 de um esquema D', () {
      // Esquema D = 4 eixos, mas só o eixo 1 tem pneu montado.
      final eixos = buildEixoLayout([_makePneu('500', '1E')], 'D');

      // Os 4 eixos aparecem, não só o que tem pneu.
      expect(eixos.map((e) => e.numero), [1, 2, 3, 4]);

      // Eixo 1: pneu montado no externo esquerdo; resto vazio.
      expect(eixos[0].esquerdoExterno?.nroPneu, '500');
      expect(eixos[0].rodadoDuplo, false);

      // Eixos 2–4: vazios, mas presentes e com o rodado do esquema (duplos).
      for (final e in eixos.sublist(1)) {
        expect(e.rodadoDuplo, true);
        expect(e.esquerdoExterno, isNull);
        expect(e.direitoExterno, isNull);
      }
    });

    test('pneu num eixo além do esquema não desaparece', () {
      // Esquema N = 1 eixo, mas há um pneu no eixo 2 (dado divergente).
      final eixos = buildEixoLayout([_makePneu('900', '2D')], 'N');

      expect(eixos.map((e) => e.numero), [1, 2]);
      expect(eixos[1].direitoExterno?.nroPneu, '900');
    });
  });
}
