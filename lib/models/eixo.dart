import 'pneu.dart';

/// Representa um eixo do veículo com seus pneus posicionados.
///
/// Para rodado simples (ex: eixo dianteiro), apenas [esquerdoExterno]
/// e [direitoExterno] são preenchidos.
/// Para rodado duplo (ex: eixo traseiro), os quatro campos podem
/// ser preenchidos.
class Eixo {
  final int numero;
  final Pneu? esquerdoExterno;
  final Pneu? esquerdoInterno;
  final Pneu? direitoExterno;
  final Pneu? direitoInterno;

  /// `true` se o eixo possui rodado duplo (2 pneus de cada lado).
  ///
  /// Armazenado como campo para preservar o tipo mesmo quando posições
  /// ficam vazias após ações sobre os pneus.
  final bool rodadoDuplo;

  Eixo({
    required this.numero,
    this.esquerdoExterno,
    this.esquerdoInterno,
    this.direitoExterno,
    this.direitoInterno,
    bool? rodadoDuplo,
  }) : rodadoDuplo =
           rodadoDuplo ?? (esquerdoInterno != null || direitoInterno != null);

  /// Retorna uma cópia do eixo com [pneu] removido da sua posição,
  /// preservando [rodadoDuplo] para manter o layout de slots.
  Eixo withoutPneu(Pneu pneu) => Eixo(
    numero: numero,
    rodadoDuplo: rodadoDuplo,
    esquerdoExterno: esquerdoExterno == pneu ? null : esquerdoExterno,
    esquerdoInterno: esquerdoInterno == pneu ? null : esquerdoInterno,
    direitoExterno: direitoExterno == pneu ? null : direitoExterno,
    direitoInterno: direitoInterno == pneu ? null : direitoInterno,
  );

  /// Retorna uma cópia do eixo com [pneu] inserido na [posicao] indicada.
  /// [posicao] é o sufixo do localEixo: `"E"`, `"EE"`, `"EI"`, `"D"`, `"DE"`, `"DI"`.
  Eixo withPneuAt(String posicao, Pneu pneu) => Eixo(
    numero: numero,
    rodadoDuplo: rodadoDuplo,
    esquerdoExterno:
        (posicao == 'E' || posicao == 'EE') ? pneu : esquerdoExterno,
    esquerdoInterno: posicao == 'EI' ? pneu : esquerdoInterno,
    direitoExterno:
        (posicao == 'D' || posicao == 'DE') ? pneu : direitoExterno,
    direitoInterno: posicao == 'DI' ? pneu : direitoInterno,
  );
}
