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

  factory Pneu.fromJson(Map<String, dynamic> json) {
    return Pneu(
      nroPneu: (json['NROPNEU'] ?? '') as String,
      nroSerie: (json['NROSERIE'] ?? '') as String,
      marca: (json['MARCA'] ?? '') as String,
      modelo: (json['MODELO'] ?? '') as String,
      dimensao: (json['DIMENSAO'] ?? '') as String,
      tipo: (json['TIPO'] ?? '') as String,
      situacao: (json['SITUACAO'] ?? '') as String,
      localEixo: (json['LOCALEIXO'] ?? '') as String,
      codEsqEixo: (json['CODESQEIXO'] ?? '') as String,
      localizacao: (json['LOCALIZACAO'] ?? '') as String,
      nroDot: (json['NRODOT'] ?? '') as String,
      indRecapagem: (json['INDRECAPAGEM'] ?? '') as String,
      vidaPneu: (json['VIDAPNEU'] ?? '') as String,
      kmRodado: (json['KMRODADO'] ?? '') as String,
      kmAcumulador: (json['KMACUMULADOR'] ?? '') as String,
      kmAtuVei: (json['KMATUVEI'] ?? '') as String,
      kmRodado0: (json['KMRODADO0'] ?? '') as String,
      kmRodado1: (json['KMRODADO1'] ?? '') as String,
      kmRodado2: (json['KMRODADO2'] ?? '') as String,
      kmRodado3: (json['KMRODADO3'] ?? '') as String,
      kmRodado4: (json['KMRODADO4'] ?? '') as String,
      kmRodado5: (json['KMRODADO5'] ?? '') as String,
      dataCompra: (json['DATACOMPRA'] ?? '') as String,
      dataAtzKm: (json['DATAATZKM'] ?? '') as String,
      codFil: (json['CODFIL'] ?? '') as String,
      nroFrota: (json['NROFROTA'] ?? '') as String,
      placa: (json['PLACA'] ?? '') as String,
    );
  }
}
