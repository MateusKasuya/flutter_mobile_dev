import 'pneu_acao.dart';

class MotivoSucateamento {
  final int codigo;
  final String descricao;

  const MotivoSucateamento(this.codigo, this.descricao);

  String get label => '$codigo - $descricao';

  static const List<MotivoSucateamento> valores = [
    MotivoSucateamento(1, 'Deslocamento de Borracha'),
    MotivoSucateamento(3, 'Estourado'),
    MotivoSucateamento(4, 'Não recapável'),
    MotivoSucateamento(5, 'Sem Condições de uso'),
    MotivoSucateamento(7, 'Defeito no conserto'),
    MotivoSucateamento(10, 'Talão quebrado'),
    MotivoSucateamento(12, 'Bolha interna/externa'),
    MotivoSucateamento(15, 'Ajuste de estoque'),
    MotivoSucateamento(18, 'Deslocamento de arame'),
  ];
}

class PneuMovimentacao {
  final String nroPneu;
  final String dataEnvio;
  final String dataRetorno;
  final String kmEntrada;
  final String kmSaida;
  final MotivoSucateamento? motivoSucateamento;
  final String observacao;
  final PneuAcao acao;

  const PneuMovimentacao({
    required this.nroPneu,
    required this.dataEnvio,
    required this.dataRetorno,
    required this.kmEntrada,
    required this.kmSaida,
    required this.observacao,
    required this.acao,
    this.motivoSucateamento,
  });
}
