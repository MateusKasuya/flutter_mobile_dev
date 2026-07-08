class MotivoSucateamento {
  final int codigo;
  final String descricao;

  const MotivoSucateamento(this.codigo, this.descricao);

  String get label => '$codigo - $descricao';

  // As chaves seguem o contrato atual da API (camelCase minúsculo),
  // documentado em /api-frota/swagger/v1/swagger.json.
  factory MotivoSucateamento.fromJson(Map<String, dynamic> json) {
    return MotivoSucateamento(
      // num.tryParse tolera codsuc vindo como String ou número; a
      // interpolação normaliza o tipo e .toInt() trunca doubles. Uma linha
      // malformada vira 0 em vez de quebrar o parsing da lista inteira.
      (num.tryParse('${json['codsuc']}') ?? 0).toInt(),
      (json['descricao'] ?? '') as String,
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
