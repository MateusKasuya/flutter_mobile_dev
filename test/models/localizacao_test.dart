import 'package:flutter_test/flutter_test.dart';

import 'package:frota_facil_mobile/models/localizacao.dart';

void main() {
  // B10: o fromJson tolera qtlocalizacao vindo como String, número ou ausente,
  // caindo em 0 em vez de derrubar a lista inteira com CastError.
  group('Localizacao.fromJson (parsing tolerante do B10)', () {
    test('qtlocalizacao como int', () {
      final l = Localizacao.fromJson(
        {'qtlocalizacao': 12, 'localizacao': 'ESTOQUE'},
      );
      expect(l.quantidade, 12);
      expect(l.nome, 'ESTOQUE');
    });

    test('qtlocalizacao como String numérica', () {
      final l = Localizacao.fromJson(
        {'qtlocalizacao': '34', 'localizacao': 'CONSERTO'},
      );
      expect(l.quantidade, 34);
    });

    test('qtlocalizacao como double é truncado', () {
      final l = Localizacao.fromJson(
        {'qtlocalizacao': 5.9, 'localizacao': 'SUCATA'},
      );
      expect(l.quantidade, 5);
    });

    test('qtlocalizacao ausente/null vira 0 (não derruba a lista)', () {
      final l = Localizacao.fromJson({'localizacao': 'VENDA'});
      expect(l.quantidade, 0);
      expect(l.nome, 'VENDA');
    });

    test('qtlocalizacao não-numérico vira 0', () {
      final l = Localizacao.fromJson(
        {'qtlocalizacao': 'abc', 'localizacao': 'RECAPAGEM'},
      );
      expect(l.quantidade, 0);
    });

    test('localizacao ausente vira string vazia', () {
      final l = Localizacao.fromJson({'qtlocalizacao': 1});
      expect(l.nome, '');
    });
  });
}
