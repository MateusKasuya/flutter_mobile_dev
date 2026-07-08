class Localizacao {
  final int quantidade;
  final String nome;

  const Localizacao({required this.quantidade, required this.nome});

  // As chaves seguem o contrato atual da API (camelCase minúsculo),
  // documentado em /api-frota/swagger/v1/swagger.json.
  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      // num.tryParse aceita valores que chegam como String OU número; a
      // interpolação '${...}' normaliza qualquer tipo (double, null->'null')
      // para String antes do parse, e .toInt() trunca doubles. Assim uma
      // linha malformada vira 0 em vez de derrubar toda a lista com CastError.
      quantidade: (num.tryParse('${json['qtlocalizacao']}') ?? 0).toInt(),
      nome: (json['localizacao'] ?? '') as String,
    );
  }
}
