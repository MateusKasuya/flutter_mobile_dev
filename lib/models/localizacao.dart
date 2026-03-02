class Localizacao {
  final int quantidade;
  final String nome;

  const Localizacao({required this.quantidade, required this.nome});

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      quantidade: json['QTLOCALIZACAO'] as int,
      nome: json['LOCALIZACAO'] as String,
    );
  }
}
