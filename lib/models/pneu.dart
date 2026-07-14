class Pneu {
  final String nroPneu;
  final String nroSerie;
  final String marca;
  final String modelo;
  final String dimensao;
  final String tipo;
  final String situacao;
  final String localEixo;
  final String codEsqEixo;
  final String localizacao;
  final String nroDot;
  final String indRecapagem;
  final String vidaPneu;
  final String kmRodado;
  final String kmAcumulador;
  final String kmAtuVei;
  final String kmRodado0;
  final String kmRodado1;
  final String kmRodado2;
  final String kmRodado3;
  final String kmRodado4;
  final String kmRodado5;
  final String dataCompra;
  final String dataAtzKm;
  final String codFil;
  final String nroFrota;
  final String placa;

  const Pneu({
    required this.nroPneu,
    required this.nroSerie,
    required this.marca,
    required this.modelo,
    required this.dimensao,
    required this.tipo,
    required this.situacao,
    required this.localEixo,
    required this.codEsqEixo,
    required this.localizacao,
    required this.nroDot,
    required this.indRecapagem,
    required this.vidaPneu,
    required this.kmRodado,
    required this.kmAcumulador,
    required this.kmAtuVei,
    required this.kmRodado0,
    required this.kmRodado1,
    required this.kmRodado2,
    required this.kmRodado3,
    required this.kmRodado4,
    required this.kmRodado5,
    required this.dataCompra,
    required this.dataAtzKm,
    required this.codFil,
    required this.nroFrota,
    required this.placa,
  });

  /// Cópia deste pneu com os campos informados sobrescritos; os demais são
  /// preservados. Útil para refletir localmente uma mudança já confirmada na
  /// API sem recarregar tudo — ex.: ao montar um pneu, marcá-lo como `FROTA`.
  Pneu copyWith({
    String? nroPneu,
    String? nroSerie,
    String? marca,
    String? modelo,
    String? dimensao,
    String? tipo,
    String? situacao,
    String? localEixo,
    String? codEsqEixo,
    String? localizacao,
    String? nroDot,
    String? indRecapagem,
    String? vidaPneu,
    String? kmRodado,
    String? kmAcumulador,
    String? kmAtuVei,
    String? kmRodado0,
    String? kmRodado1,
    String? kmRodado2,
    String? kmRodado3,
    String? kmRodado4,
    String? kmRodado5,
    String? dataCompra,
    String? dataAtzKm,
    String? codFil,
    String? nroFrota,
    String? placa,
  }) {
    return Pneu(
      nroPneu: nroPneu ?? this.nroPneu,
      nroSerie: nroSerie ?? this.nroSerie,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      dimensao: dimensao ?? this.dimensao,
      tipo: tipo ?? this.tipo,
      situacao: situacao ?? this.situacao,
      localEixo: localEixo ?? this.localEixo,
      codEsqEixo: codEsqEixo ?? this.codEsqEixo,
      localizacao: localizacao ?? this.localizacao,
      nroDot: nroDot ?? this.nroDot,
      indRecapagem: indRecapagem ?? this.indRecapagem,
      vidaPneu: vidaPneu ?? this.vidaPneu,
      kmRodado: kmRodado ?? this.kmRodado,
      kmAcumulador: kmAcumulador ?? this.kmAcumulador,
      kmAtuVei: kmAtuVei ?? this.kmAtuVei,
      kmRodado0: kmRodado0 ?? this.kmRodado0,
      kmRodado1: kmRodado1 ?? this.kmRodado1,
      kmRodado2: kmRodado2 ?? this.kmRodado2,
      kmRodado3: kmRodado3 ?? this.kmRodado3,
      kmRodado4: kmRodado4 ?? this.kmRodado4,
      kmRodado5: kmRodado5 ?? this.kmRodado5,
      dataCompra: dataCompra ?? this.dataCompra,
      dataAtzKm: dataAtzKm ?? this.dataAtzKm,
      codFil: codFil ?? this.codFil,
      nroFrota: nroFrota ?? this.nroFrota,
      placa: placa ?? this.placa,
    );
  }

  // As chaves seguem o contrato atual da API (camelCase minúsculo),
  // documentado em /api-frota/swagger/v1/swagger.json.
  factory Pneu.fromJson(Map<String, dynamic> json) {
    return Pneu(
      nroPneu: (json['nropneu'] ?? '') as String,
      nroSerie: (json['nroserie'] ?? '') as String,
      marca: (json['marca'] ?? '') as String,
      modelo: (json['modelo'] ?? '') as String,
      dimensao: (json['dimensao'] ?? '') as String,
      tipo: (json['tipo'] ?? '') as String,
      situacao: (json['situacao'] ?? '') as String,
      localEixo: (json['localeixo'] ?? '') as String,
      codEsqEixo: (json['codesqeixo'] ?? '') as String,
      localizacao: (json['localizacao'] ?? '') as String,
      nroDot: (json['nrodot'] ?? '') as String,
      indRecapagem: (json['indrecapagem'] ?? '') as String,
      vidaPneu: (json['vidapneu'] ?? '') as String,
      kmRodado: (json['kmrodado'] ?? '') as String,
      kmAcumulador: (json['kmacumulador'] ?? '') as String,
      kmAtuVei: (json['kmatuvei'] ?? '') as String,
      // O 'O' maiúsculo antes do dígito não é erro: é como a API converte
      // KMRODADO0..5 para camelCase (ela para de rebaixar a letra que
      // antecede um caractere não-maiúsculo, no caso o número).
      kmRodado0: (json['kmrodadO0'] ?? '') as String,
      kmRodado1: (json['kmrodadO1'] ?? '') as String,
      kmRodado2: (json['kmrodadO2'] ?? '') as String,
      kmRodado3: (json['kmrodadO3'] ?? '') as String,
      kmRodado4: (json['kmrodadO4'] ?? '') as String,
      kmRodado5: (json['kmrodadO5'] ?? '') as String,
      dataCompra: (json['datacompra'] ?? '') as String,
      dataAtzKm: (json['dataatzkm'] ?? '') as String,
      codFil: (json['codfil'] ?? '') as String,
      nroFrota: (json['nrofrota'] ?? '') as String,
      placa: (json['placa'] ?? '') as String,
    );
  }
}
