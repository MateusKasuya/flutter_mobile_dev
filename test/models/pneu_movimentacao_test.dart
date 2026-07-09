import 'package:flutter_test/flutter_test.dart';

import 'package:frota_facil_mobile/models/pneu_movimentacao.dart';

void main() {
  // B10: codsuc pode chegar como String ou número; o fromJson normaliza para
  // int (ou 0), sem quebrar o parsing da lista de motivos.
  group('MotivoSucateamento.fromJson (parsing tolerante do B10)', () {
    test('codsuc como int', () {
      final m = MotivoSucateamento.fromJson(
        {'codsuc': 7, 'descricao': 'DESGASTE'},
      );
      expect(m.codigo, 7);
      expect(m.descricao, 'DESGASTE');
    });

    test('codsuc como String numérica', () {
      final m = MotivoSucateamento.fromJson({'codsuc': '9', 'descricao': 'FURO'});
      expect(m.codigo, 9);
    });

    test('codsuc como double é truncado', () {
      final m = MotivoSucateamento.fromJson({'codsuc': 3.7, 'descricao': 'X'});
      expect(m.codigo, 3);
    });

    test('codsuc ausente/null vira 0 (não quebra o parsing da lista)', () {
      final m = MotivoSucateamento.fromJson({'descricao': 'SEM CODIGO'});
      expect(m.codigo, 0);
      expect(m.descricao, 'SEM CODIGO');
    });

    test('descricao ausente vira string vazia', () {
      final m = MotivoSucateamento.fromJson({'codsuc': 1});
      expect(m.descricao, '');
    });

    // O == por código deixa o DropdownButtonFormField reidentificar a seleção
    // quando a lista é recarregada (instâncias diferentes, mesmo codsuc).
    test('igualdade por código: mesmo codsuc = igual', () {
      final a = MotivoSucateamento.fromJson({'codsuc': 7, 'descricao': 'A'});
      final b = MotivoSucateamento.fromJson({'codsuc': 7, 'descricao': 'B'});
      expect(a, equals(b));
    });
  });
}
