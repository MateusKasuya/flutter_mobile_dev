/// Tipos de esquema de eixo suportados pelo diagrama.
///
/// O código bruto é a letra que vem em `Pneu.codEsqEixo` (campo `CODESQEIXO`
/// da API). Cada letra representa uma configuração de chassi/eixos diferente.
enum EsquemaEixo {
  toco,        // A — caminhão TOCO (1 eixo simples + 1 eixo duplo)
  moto,        // M — motocicleta
  passeio,     // F — passeio / caminhonete
  bitruck,     // H — bitruck / ônibus
  truckG,      // G — truck / cavalo
  truckB,      // B — truck / cavalo 2 eixos
  truckO,      // O — truck / cavalo 2 eixos (variante)
  truckD,      // D — truck / cavalo 3 eixos
  carretinha,  // N — carretinha
  carreta1J,   // J — carreta 1 eixo
  carreta2E,   // E — carreta 2 eixos
  carreta2K,   // K — carreta 2 eixos (variante)
  carreta3C,   // C — carreta 3 eixos
  carreta3L,   // L — carreta 3 eixos (variante)
  carreta4P;   // P — carreta 4 eixos

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
