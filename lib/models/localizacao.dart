class Localizacao {
  final int quantidade;
  final String nome;

  const Localizacao({required this.quantidade, required this.nome});

  // As chaves seguem o contrato atual da API (camelCase minúsculo),
  // documentado em /api-frota/swagger/v1/swagger.json.
  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      quantidade: (json['qtlocalizacao'] ?? 0) as int,
      nome: (json['localizacao'] ?? '') as String,
    );
  }
}
