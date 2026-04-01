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

  const Eixo({
    required this.numero,
    this.esquerdoExterno,
    this.esquerdoInterno,
    this.direitoExterno,
    this.direitoInterno,
  });

  /// Retorna `true` se o eixo possui rodado duplo (2 pneus de cada lado).
  bool get rodadoDuplo => esquerdoInterno != null || direitoInterno != null;
}
