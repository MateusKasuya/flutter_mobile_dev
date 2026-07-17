import '../components/diagrama_eixos/esquema_eixo.dart';
import '../models/eixo.dart';
import '../models/pneu.dart';

/// Quantidade de slots de estepe que o diagrama mostra, sempre.
///
/// A API identifica estepe pelo `localeixo` `X1`/`X2` (confirmado em
/// homologação na placa FBW5J92, que traz os dois). Não há campo no esquema de
/// eixos dizendo quantos estepes o veículo comporta, então fixamos 2 — que é o
/// teto da operação. Os slots aparecem mesmo vazios, para permitir montar um
/// pneu no estepe pelo diagrama.
const int kMaxEstepes = 2;

/// Índice do slot de estepe de um [localEixo]: 0 para `X1`, 1 para `X2`.
///
/// Devolve null quando não é estepe (`1D`, `2EI`, vazio...) ou quando o número
/// está fora dos [kMaxEstepes] slots suportados (`X0`, `X3`) — nesse caso o
/// pneu não tem onde ser desenhado e é ignorado, em vez de quebrar o layout.
int? estepeSlotIndex(String localEixo) {
  final match = RegExp(r'^X(\d+)$').firstMatch(localEixo.trim().toUpperCase());
  if (match == null) return null;
  final numero = int.parse(match.group(1)!);
  if (numero < 1 || numero > kMaxEstepes) return null;
  return numero - 1;
}

/// Estepes de [pneus] na ordem dos slots: índice 0 = `X1`, 1 = `X2`.
///
/// Sempre devolve [kMaxEstepes] posições; `null` = slot vazio.
List<Pneu?> buildEstepeLayout(List<Pneu> pneus) {
  final slots = List<Pneu?>.filled(kMaxEstepes, null);
  for (final pneu in pneus) {
    final slot = estepeSlotIndex(pneu.localEixo);
    if (slot != null) slots[slot] = pneu;
  }
  return slots;
}

/// Organiza uma lista de [Pneu] em [Eixo]s a partir do campo [localEixo].
///
/// O [localEixo] segue o padrão `{eixo}{lado}{posição}`:
/// - `1D` → Eixo 1, Direito (simples)
/// - `2EI` → Eixo 2, Esquerdo Interno (duplo)
///
/// Se [codEsqEixo] corresponder a um esquema conhecido, o chassi inteiro é
/// montado: **todos** os eixos do esquema aparecem — com o rodado
/// (simples/duplo) definido por ele —, mesmo os que ainda não têm nenhum
/// pneu; os pneus existentes só preenchem os slots. Assim um veículo sem
/// pneus, ou com pneus em apenas alguns eixos, ainda mostra o layout completo.
///
/// Se [codEsqEixo] for vazio/desconhecido, vale o comportamento antigo: os
/// eixos são inferidos só dos pneus (eixo sem pneu não aparece, e o rodado
/// duplo é deduzido da presença de pneu interno).
///
/// Pneus com [localEixo] vazio são ignorados.
/// O resultado é ordenado por número do eixo (1, 2, 3...).
List<Eixo> buildEixoLayout(List<Pneu> pneus, [String codEsqEixo = '']) {
  final Map<int, Map<String, Pneu>> eixoMap = {};

  for (final pneu in pneus) {
    if (pneu.localEixo.isEmpty) continue;

    // localEixo esperado no padrão "{eixo}{posição}" (ex: "1D", "2EI"), com o
    // número do eixo no 1º caractere. Pneus fora desse padrão — estepe (`X1`,
    // `X2`, que vão para [buildEstepeLayout]) ou dado legado — não pertencem a
    // eixo nenhum, então são ignorados aqui em vez de quebrar o parse
    // (int.parse('X') lançaria FormatException e derrubaria a tela inteira).
    final numero = int.tryParse(pneu.localEixo[0]);
    if (numero == null) continue;

    final posicao = pneu.localEixo.substring(1); // "D", "E", "DE", "DI", "EE", "EI"

    eixoMap.putIfAbsent(numero, () => {});
    eixoMap[numero]![posicao] = pneu;
  }

  // Código efetivo do esquema. O veículo é a fonte de verdade, mas quando o
  // codEsqEixo dele vem vazio caímos no código do primeiro pneu que tiver um
  // preenchido — espelhando o mesmo fallback do widget DiagramaEixos. Sem isso
  // o esqueleto (aqui) usaria '' e divergiria do frame desenhado pelo widget.
  final cod = codEsqEixo.isNotEmpty
      ? codEsqEixo
      : pneus.map((p) => p.codEsqEixo).firstWhere(
            (c) => c.isNotEmpty,
            orElse: () => '',
          );

  // Rodado de cada eixo segundo o esquema do veículo (null se desconhecido).
  final rodadoEsquema = EsquemaEixo.fromCodigo(cod)?.rodadoDuploPorEixo;

  // Eixos a desenhar: os do esquema ∪ os que têm pneu. A união garante que um
  // pneu num eixo fora do esquema (dado divergente) não desapareça do diagrama.
  final numeros = <int>{
    for (var i = 1; i <= (rodadoEsquema?.length ?? 0); i++) i,
    ...eixoMap.keys,
  };

  return numeros.map((numero) {
    final p = eixoMap[numero] ?? const <String, Pneu>{};
    final temPneuInterno = p.containsKey('EI') || p.containsKey('DI');
    final duploEsquema =
        (rodadoEsquema != null && numero <= rodadoEsquema.length)
            ? rodadoEsquema[numero - 1]
            : false;

    return Eixo(
      numero: numero,
      // Duplo se o esquema disser que é OU se já houver pneu interno montado
      // (nunca escondemos um pneu por divergência entre esquema e dado real).
      rodadoDuplo: duploEsquema || temPneuInterno,
      esquerdoExterno: p['EE'] ?? p['E'],
      esquerdoInterno: p['EI'],
      direitoExterno: p['DE'] ?? p['D'],
      direitoInterno: p['DI'],
    );
  }).toList()
    ..sort((a, b) => a.numero.compareTo(b.numero));
}
