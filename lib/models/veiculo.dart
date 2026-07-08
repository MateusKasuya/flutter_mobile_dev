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

  /// Código do esquema de eixos do veículo (campo `CODESQEIXO` da API).
  ///
  /// Vem no nível do veículo (não só nos pneus), então um veículo sem
  /// nenhum pneu ainda sabe qual é a configuração de eixos do chassi.
  /// A letra é interpretada por `EsquemaEixo.fromCodigo`.
  final String codEsqEixo;

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
    required this.codEsqEixo,
    required this.pneus,
  });

  // As chaves seguem o contrato atual da API (camelCase minúsculo),
  // documentado em /api-frota/swagger/v1/swagger.json.
  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      placa: (json['placa'] ?? '') as String,
      nroFrota: (json['nrofrota'] ?? '') as String,
      marca: (json['marca'] ?? '') as String,
      modelo: (json['modelo'] ?? '') as String,
      ano: (json['ano'] ?? '') as String,
      anoModelo: (json['anomodelo'] ?? '') as String,
      cor: (json['cor'] ?? '') as String,
      tipo: (json['tipo'] ?? '') as String,
      codEsqEixo: (json['codesqeixo'] ?? '') as String,
      // 'pneus' é nullable no contrato da API; veículo sem pneus vira lista vazia.
      pneus: (json['pneus'] as List? ?? const [])
          .map((e) => Pneu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
