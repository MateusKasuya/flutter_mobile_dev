import 'pneu.dart';

class Veiculo {
  final String placa;
  final String nroFrota;
  final String marca;
  final String modelo;
  final String ano;
  final String anoModelo;
  final String cor;
  final String tipo;
  final List<Pneu> pneus;

  const Veiculo({
    required this.placa,
    required this.nroFrota,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.anoModelo,
    required this.cor,
    required this.tipo,
    required this.pneus,
  });

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      placa: json['PLACA'] as String,
      nroFrota: json['NROFROTA'] as String,
      marca: json['MARCA'] as String,
      modelo: json['MODELO'] as String,
      ano: json['ANO'] as String,
      anoModelo: json['ANOMODELO'] as String,
      cor: json['COR'] as String,
      tipo: json['TIPO'] as String,
      pneus: (json['pneus'] as List)
          .map((e) => Pneu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
