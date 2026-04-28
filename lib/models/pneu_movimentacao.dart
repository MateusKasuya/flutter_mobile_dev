import 'pneu_acao.dart';

class MotivoSucateamento {
  final int codigo;
  final String descricao;

  const MotivoSucateamento(this.codigo, this.descricao);

  String get label => '$codigo - $descricao';

  factory MotivoSucateamento.fromJson(Map<String, dynamic> json) {
    return MotivoSucateamento(
      (json['CODSUC'] ?? 0) as int,
      (json['DESCRICAO'] ?? '') as String,
    );
  }

  // Igualdade por código permite ao DropdownButtonFormField reidentificar
  // a seleção quando a lista é recarregada (instâncias diferentes, mesmo CODSUC).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotivoSucateamento && other.codigo == codigo;

  @override
  int get hashCode => codigo.hashCode;
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
