import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/models/pneu.dart';

void main() {
  group('Pneu.fromJson', () {
    test('cria Pneu a partir de JSON válido', () {
      final json = {
        'nropneu': '1',
        'nroserie': 'SR123456',
        'marca': 'Pirelli',
        'modelo': 'Modelo A',
        'dimensao': '295/80R22.5',
        'tipo': 'Radial',
        'situacao': 'Em uso',
        'localeixo': 'Dianteiro esquerdo',
        'codesqeixo': '1',
        'localizacao': '1',
        'nrodot': '4523',
        'indrecapagem': 'N',
        'vidapneu': '80',
        'kmrodado': '50000',
        'kmacumulador': '40000',
        'kmatuvei': '150000',
        // O 'O' maiúsculo é o formato real da API (camelCase de KMRODADO0..5).
        'kmrodadO0': '10000',
        'kmrodadO1': '10000',
        'kmrodadO2': '10000',
        'kmrodadO3': '10000',
        'kmrodadO4': '10000',
        'kmrodadO5': '0',
        'datacompra': '2023-01-15',
        'dataatzkm': '2024-06-01',
        'codfil': '01',
        'nrofrota': '001',
        'placa': 'ABC1D23',
      };

      final pneu = Pneu.fromJson(json);

      expect(pneu.nroPneu, '1');
      expect(pneu.marca, 'Pirelli');
      expect(pneu.dimensao, '295/80R22.5');
      expect(pneu.situacao, 'Em uso');
      expect(pneu.localEixo, 'Dianteiro esquerdo');
      expect(pneu.vidaPneu, '80');
      expect(pneu.kmRodado, '50000');
      expect(pneu.kmRodado0, '10000');
      expect(pneu.kmRodado5, '0');
      expect(pneu.placa, 'ABC1D23');
    });

    test('usa string vazia para campos ausentes no JSON', () {
      final pneu = Pneu.fromJson({});

      expect(pneu.nroPneu, '');
      expect(pneu.marca, '');
      expect(pneu.placa, '');
    });
  });

  group('Pneu.copyWith', () {
    const base = Pneu(
      nroPneu: '1250',
      nroSerie: 'SN1',
      marca: 'Pirelli',
      modelo: 'Modelo A',
      dimensao: '295/80R22.5',
      tipo: 'Radial',
      situacao: 'Em uso',
      localEixo: '',
      codEsqEixo: '1',
      localizacao: 'ESTOQUE',
      nroDot: '4523',
      indRecapagem: 'N',
      vidaPneu: '80',
      kmRodado: '50000',
      kmAcumulador: '40000',
      kmAtuVei: '150000',
      kmRodado0: '10000',
      kmRodado1: '9000',
      kmRodado2: '8000',
      kmRodado3: '7000',
      kmRodado4: '6000',
      kmRodado5: '0',
      dataCompra: '2023-01-15',
      dataAtzKm: '2024-06-01',
      codFil: '01',
      nroFrota: '001',
      placa: 'ABC1D23',
    );

    test('sobrescreve só os campos informados e preserva o resto', () {
      // Uso real da correção: ao montar, o pneu de estoque vira FROTA no slot.
      final montado = base.copyWith(localizacao: 'FROTA', localEixo: '2EI');

      expect(montado.localizacao, 'FROTA');
      expect(montado.localEixo, '2EI');

      // Amostra dos 25 campos restantes: seguem idênticos à origem.
      expect(montado.nroPneu, base.nroPneu);
      expect(montado.codFil, base.codFil);
      expect(montado.situacao, base.situacao);
      expect(montado.kmAtuVei, base.kmAtuVei);
      expect(montado.kmRodado0, base.kmRodado0);
      expect(montado.dataAtzKm, base.dataAtzKm);
      expect(montado.placa, base.placa);
    });

    test('sem argumentos, copia todos os campos', () {
      final copia = base.copyWith();

      expect(copia.nroPneu, base.nroPneu);
      expect(copia.localizacao, base.localizacao);
      expect(copia.localEixo, base.localEixo);
      expect(copia.kmRodado5, base.kmRodado5);
      expect(copia.nroFrota, base.nroFrota);
    });
  });
}
