import 'pneu_acao.dart';
import 'pneu_movimentacao.dart';

class PneuMovHorizontal {
  final String nroPneu;
  final PneuAcao origem;
  final PneuAcao destino;
  final String data;
  final String? valor;
  final String? motivo;
  final String? fornecedorRecap;
  final MotivoSucateamento? motivoSucateamento;
  final bool proibidoFuturaRecap;
  final String observacao;

  const PneuMovHorizontal({
    required this.nroPneu,
    required this.origem,
    required this.destino,
    required this.data,
    required this.observacao,
    required this.proibidoFuturaRecap,
    this.valor,
    this.motivo,
    this.fornecedorRecap,
    this.motivoSucateamento,
  });
}
