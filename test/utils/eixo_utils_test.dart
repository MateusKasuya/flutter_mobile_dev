import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';
import 'package:frota_facil_mobile/utils/eixo_utils.dart';

/// Helper para criar um Pneu com apenas os campos relevantes para o teste.
Pneu _makePneu(String nroPneu, String localEixo, [String codEsqEixo = '']) {
  return Pneu(
    nroPneu: nroPneu,
    nroSerie: '',
    marca: '',
    modelo: '',
    dimensao: '',
    tipo: '',
    situacao: '',
    localEixo: localEixo,
    codEsqEixo: codEsqEixo,
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

    test(
        'codEsqEixo vazio cai no código do pneu e monta o chassi completo (B7)',
        () {
      // Regressão: veículo sem codEsqEixo (''), mas os pneus carregam o código
      // de um esquema conhecido (D = 4 eixos). O esqueleto deve ser idêntico ao
      // de chamar com 'D' explícito — sem isso, o esqueleto usaria '' e
      // divergiria do frame que o widget desenha (que já aplica esse fallback).
      final pneus = [_makePneu('500', '1E', 'D')];

      final comVazio = buildEixoLayout(pneus, '');
      final comExplicito = buildEixoLayout(pneus, 'D');

      // Chassi completo do esquema D: 4 eixos, 1 simples + 3 duplos.
      expect(comVazio.map((e) => e.numero), [1, 2, 3, 4]);
      expect(comVazio.map((e) => e.rodadoDuplo), [false, true, true, true]);

      // Deve bater com o resultado de passar o código explicitamente.
      expect(comVazio.map((e) => e.numero), comExplicito.map((e) => e.numero));
      expect(
        comVazio.map((e) => e.rodadoDuplo),
        comExplicito.map((e) => e.rodadoDuplo),
      );

      // O pneu montado continua no lugar.
      expect(comVazio[0].esquerdoExterno?.nroPneu, '500');
    });

    test('pneu num eixo além do esquema não desaparece', () {
      // Esquema N = 1 eixo, mas há um pneu no eixo 2 (dado divergente).
      final eixos = buildEixoLayout([_makePneu('900', '2D')], 'N');

      expect(eixos.map((e) => e.numero), [1, 2]);
      expect(eixos[1].direitoExterno?.nroPneu, '900');
    });
  });

  group('estepeSlotIndex', () {
    test('X1 e X2 viram os slots 0 e 1', () {
      expect(estepeSlotIndex('X1'), 0);
      expect(estepeSlotIndex('X2'), 1);
    });

    test('aceita caixa baixa e espaços (dado da API não é confiável)', () {
      expect(estepeSlotIndex('x1'), 0);
      expect(estepeSlotIndex(' X2 '), 1);
    });

    test('posição de eixo não é estepe', () {
      expect(estepeSlotIndex('1D'), isNull);
      expect(estepeSlotIndex('2EI'), isNull);
      expect(estepeSlotIndex(''), isNull);
    });

    test('estepe fora dos 2 slots suportados é descartado', () {
      // Não há onde desenhar X0/X3 — melhor ignorar que quebrar o layout.
      expect(estepeSlotIndex('X0'), isNull);
      expect(estepeSlotIndex('X3'), isNull);
      // 'X' sozinho (dado legado) não casa o padrão.
      expect(estepeSlotIndex('X'), isNull);
    });
  });

  group('buildEstepeLayout', () {
    test('devolve sempre 2 slots, na ordem X1, X2', () {
      // Dados reais da placa FBW5J92 em homologação: 2 pneus no eixo 2 e os
      // estepes em X1/X2.
      final pneus = [
        _makePneu('1334', '2EE'),
        _makePneu('937', '2EI'),
        _makePneu('1361', 'X1'),
        _makePneu('1380', 'X2'),
      ];

      final estepes = buildEstepeLayout(pneus);

      expect(estepes, hasLength(kMaxEstepes));
      expect(estepes[0]?.nroPneu, '1361');
      expect(estepes[1]?.nroPneu, '1380');
    });

    test('slot sem estepe fica null, e os 2 slots existem mesmo sem nenhum', () {
      expect(buildEstepeLayout([_makePneu('1361', 'X2')]), [null, isNotNull]);
      expect(buildEstepeLayout([_makePneu('100', '1D')]), [null, null]);
      expect(buildEstepeLayout([]), [null, null]);
    });
  });

  group('buildEixoLayout x estepe', () {
    test('estepe não vira eixo', () {
      // Regressão: 'X1' no 1º caractere não é número; se o parse tentasse
      // int.parse('X') a tela inteira caía. O estepe tem lugar próprio
      // (buildEstepeLayout) e some do layout de eixos.
      final eixos = buildEixoLayout([
        _makePneu('1334', '2EE'),
        _makePneu('1361', 'X1'),
        _makePneu('1380', 'X2'),
      ]);

      expect(eixos.map((e) => e.numero), [2]);
    });
  });
}
