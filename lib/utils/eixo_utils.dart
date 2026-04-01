import '../models/eixo.dart';
import '../models/pneu.dart';

/// Organiza uma lista de [Pneu] em [Eixo]s a partir do campo [localEixo].
///
/// O [localEixo] segue o padrão `{eixo}{lado}{posição}`:
/// - `1D` → Eixo 1, Direito (simples)
/// - `2EI` → Eixo 2, Esquerdo Interno (duplo)
///
/// Pneus com [localEixo] vazio são ignorados.
/// O resultado é ordenado por número do eixo (1, 2, 3...).
List<Eixo> buildEixoLayout(List<Pneu> pneus) {
  final Map<int, Map<String, Pneu>> eixoMap = {};

  for (final pneu in pneus) {
    if (pneu.localEixo.isEmpty) continue;

    final numero = int.parse(pneu.localEixo[0]);
    final posicao = pneu.localEixo.substring(1); // "D", "E", "DE", "DI", "EE", "EI"

    eixoMap.putIfAbsent(numero, () => {});
    eixoMap[numero]![posicao] = pneu;
  }

  return eixoMap.entries.map((entry) {
    final p = entry.value;
    return Eixo(
      numero: entry.key,
      esquerdoExterno: p['EE'] ?? p['E'],
      esquerdoInterno: p['EI'],
      direitoExterno: p['DE'] ?? p['D'],
      direitoInterno: p['DI'],
    );
  }).toList()
    ..sort((a, b) => a.numero.compareTo(b.numero));
}
