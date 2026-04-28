class Fornecedor {
  final String cgcCpf;
  final String razaoSocial;
  final String nomeFantasia;

  const Fornecedor({
    required this.cgcCpf,
    required this.razaoSocial,
    required this.nomeFantasia,
  });

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      cgcCpf: (json['CGCCPFFORNE'] ?? '') as String,
      razaoSocial: (json['RAZAOSOCIAL'] ?? '') as String,
      nomeFantasia: (json['NOMEFANTASIA'] ?? '') as String,
    );
  }

  // Necessário para o DropdownButtonFormField reconhecer o item selecionado
  // após reload da lista (compara por identidade do CNPJ/CPF, não da instância).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fornecedor && other.cgcCpf == cgcCpf;

  @override
  int get hashCode => cgcCpf.hashCode;
}
