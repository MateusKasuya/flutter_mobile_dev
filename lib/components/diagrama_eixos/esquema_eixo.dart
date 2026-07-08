/// Tipos de esquema de eixo suportados pelo diagrama.
///
/// O código bruto é a letra que vem em `Pneu.codEsqEixo` (campo `CODESQEIXO`
/// da API). Cada letra representa uma configuração de chassi/eixos diferente.
enum EsquemaEixo {
  toco,        // A — caminhão TOCO (1 eixo simples + 1 eixo duplo)
  moto,        // M — motocicleta
  passeio,     // F — passeio / caminhonete
  bitruck,     // H — bitruck / ônibus
  truckG,      // G — truck / cavalo (3 eixos: simples, duplo, simples)
  truckB,      // B — truck / cavalo (3 eixos: 1 simples + 2 duplos)
  truckO,      // O — truck / cavalo (3 eixos: 2 simples + 1 duplo)
  truckD,      // D — truck / cavalo (4 eixos: 1 simples + 3 duplos)
  carretinha,  // N — carretinha
  carreta1J,   // J — carreta 1 eixo
  carreta2E,   // E — carreta 2 eixos
  carreta2K,   // K — carreta 2 eixos (variante)
  carreta3C,   // C — carreta 3 eixos
  carreta3L,   // L — carreta 3 eixos (variante)
  carreta4P;   // P — carreta 4 eixos

  /// Configuração de rodado de cada eixo, do dianteiro (E1) ao traseiro.
  ///
  /// `false` = rodado simples (1 pneu por lado); `true` = rodado duplo
  /// (2 pneus por lado). O tamanho da lista é o número de eixos do chassi.
  ///
  /// Serve para desenhar o "esqueleto" do diagrama (eixos com slots vazios)
  /// de um veículo **sem nenhum pneu**: aí não há como inferir a quantidade
  /// de eixos pelos pneus (como faz `buildEixoLayout`), então ela vem daqui.
  /// Tabela fornecida pela operação de frota.
  List<bool> get rodadoDuploPorEixo {
    switch (this) {
      case EsquemaEixo.toco: // A
        return const [false, true];
      case EsquemaEixo.moto: // M — 1 pneu central por eixo (ver FrameMoto)
        return const [false, false];
      case EsquemaEixo.passeio: // F
        return const [false, false];
      case EsquemaEixo.bitruck: // H
        return const [false, false, true, true];
      case EsquemaEixo.truckG: // G
        return const [false, true, false];
      case EsquemaEixo.truckB: // B
        return const [false, true, true];
      case EsquemaEixo.truckO: // O
        return const [false, false, true];
      case EsquemaEixo.truckD: // D
        return const [false, true, true, true];
      case EsquemaEixo.carretinha: // N
        return const [false];
      case EsquemaEixo.carreta1J: // J
        return const [true];
      case EsquemaEixo.carreta2E: // E
        return const [true, true];
      case EsquemaEixo.carreta2K: // K
        return const [true, true];
      case EsquemaEixo.carreta3C: // C
        return const [true, true, true];
      case EsquemaEixo.carreta3L: // L
        return const [true, true, true];
      case EsquemaEixo.carreta4P: // P
        return const [true, true, true, true];
    }
  }

  static EsquemaEixo? fromCodigo(String codigo) {
    switch (codigo.toUpperCase()) {
      case 'A':
        return toco;
      case 'M':
        return moto;
      case 'F':
        return passeio;
      case 'H':
        return bitruck;
      case 'G':
        return truckG;
      case 'B':
        return truckB;
      case 'O':
        return truckO;
      case 'D':
        return truckD;
      case 'N':
        return carretinha;
      case 'J':
        return carreta1J;
      case 'E':
        return carreta2E;
      case 'K':
        return carreta2K;
      case 'C':
        return carreta3C;
      case 'L':
        return carreta3L;
      case 'P':
        return carreta4P;
      default:
        return null;
    }
  }
}
