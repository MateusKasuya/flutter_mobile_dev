import 'pneu_acao.dart';

class PneuEntradaVeiculo {
  final String nroPneu;
  final String codEsqEixo;
  final String localEixo;
  final String dataEnvio;
  final String kmEntradaVeiculo;
  final PneuAcao origem;

  const PneuEntradaVeiculo({
    required this.nroPneu,
    required this.codEsqEixo,
    required this.localEixo,
    required this.dataEnvio,
    required this.kmEntradaVeiculo,
    required this.origem,
  });
}
