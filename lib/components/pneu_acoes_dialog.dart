import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/veiculo.dart';
import '../screens/pneu_lista_screen.dart';
import '../services/pneu_service.dart' as pneu_service;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/breakpoints.dart';
import '../utils/eixo_utils.dart';
import 'pneu_entrada_bottom_sheet.dart';
import 'pneu_horizontal_bottom_sheet.dart';
import 'pneu_movimentacao_bottom_sheet.dart';
import 'shared/close_x_painter.dart';

/// Retorna a [PneuAcao] correspondente à localização do pneu,
/// ou null quando o pneu está montado num veículo (localização desconhecida).
PneuAcao? _origemFromLocalizacao(String localizacao) {
  // Aqui "não encontrado" é um caso legítimo (pneu montado num veículo tem
  // localização desconhecida), não um erro. firstWhere lançaria StateError
  // quando nada casa — usar exceção como fluxo normal é caro e obscuro; um
  // loop que retorna null no fim expressa a intenção diretamente.
  final alvo = localizacao.toUpperCase();
  for (final acao in PneuAcao.values) {
    if (acao.label.toUpperCase() == alvo) return acao;
  }
  return null;
}

/// Retorna true para pares origem→destino proibidos pelas regras de negócio.
bool _isProibido(PneuAcao origem, PneuAcao destino) {
  if (origem == PneuAcao.conserto && destino == PneuAcao.venda) return true;
  if (origem == PneuAcao.recapagem && destino == PneuAcao.venda) return true;
  if (origem == PneuAcao.sucata && destino != PneuAcao.venda) return true;
  if (origem == PneuAcao.venda) return true;
  return false;
}

/// [veiculo] e [eixoSlotsVazios] só importam para um pneu que já é um estepe
/// montado (`X1`/`X2`) — nesse caso, havendo alguma posição de eixo livre no
/// próprio veículo, aparece uma opção extra "Eixo" para movê-lo direto para
/// lá (ex.: usar o estepe para substituir um pneu furado), sem precisar
/// desmontá-lo antes para uma localização fora do veículo.
void showPneuAcoesDialog(
  BuildContext context,
  Pneu pneu, {
  Veiculo? veiculo,
  List<String> eixoSlotsVazios = const [],
  void Function(Pneu pneu)? onConfirmed,
  void Function(String localEixoDestino, Pneu pneu)? onMovidoParaEixo,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final isTablet =
          MediaQuery.of(dialogContext).size.width >= kTabletBreakpoint;
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.textHint, width: 1),
        ),
        child: SizedBox(
          width: isTablet ? 390 : 340,
          height: isTablet ? 340 : 320,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(25, isTablet ? 41 : 32, 25, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Pneu ${pneu.nroPneu}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Center(
                      child: Text(
                        'Selecione uma opção',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelNumbers.copyWith(
                          color: AppColors.textPlaceholder,
                        ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    _buildAcoesGrid(
                      // Contexto de FORA do dialog (sobrevive ao pop): o card
                      // "Eixo" ainda espera o usuário escolher uma posição
                      // antes de abrir a montagem, e por essa hora o contexto
                      // do próprio dialog já pode ter sido desmontado (mesmo
                      // cuidado de showSlotVazioAcoesDialog/dialogContext).
                      context,
                      dialogContext,
                      pneu,
                      veiculo: veiculo,
                      eixoSlotsVazios: eixoSlotsVazios,
                      onConfirmed: onConfirmed,
                      onMovidoParaEixo: onMovidoParaEixo,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: isTablet ? 354 : 304,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(dialogContext),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CustomPaint(painter: CloseXPainter()),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildAcoesGrid(
  BuildContext context,
  BuildContext dialogContext,
  Pneu pneu, {
  Veiculo? veiculo,
  List<String> eixoSlotsVazios = const [],
  void Function(Pneu pneu)? onConfirmed,
  void Function(String localEixoDestino, Pneu pneu)? onMovidoParaEixo,
}) {
  final origem = _origemFromLocalizacao(pneu.localizacao);

  bool isAtual(PneuAcao acao) =>
      acao.label.toUpperCase() == pneu.localizacao.toUpperCase();

  bool isDisabled(PneuAcao acao) {
    if (isAtual(acao)) return true;
    if (origem != null && _isProibido(origem, acao)) return true;
    return false;
  }

  final cards = <_AcaoCard>[
    for (final acao in PneuAcao.values)
      _AcaoCard(
        acao: acao,
        disabled: isDisabled(acao),
        onTap: () {
          Navigator.pop(dialogContext);
          _confirmAction(context, pneu, acao, onConfirmed: onConfirmed);
        },
      ),
  ];

  // "Eixo" só faz sentido pra um estepe (X1/X2) já montado no MESMO veículo,
  // e só quando há posição de eixo livre pra receber ele.
  if (veiculo != null &&
      eixoSlotsVazios.isNotEmpty &&
      estepeSlotIndex(pneu.localEixo) != null) {
    cards.add(
      _AcaoCard(
        acao: const EixoDestino(),
        onTap: () {
          Navigator.pop(dialogContext);
          _escolherEixoEMover(
            context,
            pneu,
            veiculo,
            eixoSlotsVazios,
            onMovidoParaEixo: onMovidoParaEixo,
          );
        },
      ),
    );
  }

  // Linhas de até 3 cards, mesmo espaçamento (10px) dos cards originais.
  final rows = <Widget>[];
  for (var i = 0; i < cards.length; i += 3) {
    if (rows.isNotEmpty) rows.add(const SizedBox(height: 10));
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var j = i; j < i + 3 && j < cards.length; j++) ...[
            if (j > i) const SizedBox(width: 10),
            cards[j],
          ],
        ],
      ),
    );
  }
  return Column(children: rows);
}

class _AcaoCard extends StatelessWidget {
  final OrigemVisual acao;
  final VoidCallback onTap;
  final bool disabled;

  const _AcaoCard({
    required this.acao,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = disabled ? Colors.grey.shade400 : acao.color;
    final bgColor = disabled
        ? effectiveColor.withValues(alpha: 0.08)
        : (acao.bgColor ?? effectiveColor.withValues(alpha: 0.08));
    final borderColor = disabled
        ? effectiveColor.withValues(alpha: 0.35)
        : (acao.borderColor ?? effectiveColor.withValues(alpha: 0.35));
    final iconColor = disabled
        ? effectiveColor
        : (acao.borderColor ?? effectiveColor);
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Transform.flip(
                    flipX: acao.mirrorX,
                    child: acao.asset != null
                        ? SvgPicture.asset(
                            acao.asset!,
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : Icon(acao.icon, color: iconColor, size: 24),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 58,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  acao.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.footer.copyWith(
                    fontWeight: FontWeight.w600,
                    color: disabled ? Colors.grey.shade400 : AppColors.textBody,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Escolhe pra qual posição de eixo mover o estepe [pneu] já montado (direto
/// se só houver um slot livre; com um dialog de escolha se houver mais de
/// um) e abre o mesmo formulário de montagem usado para estoque/conserto/
/// recapagem, com a origem de exibição "Estepe" e
/// `localizacaoOrigemOverride: 'FROTA'` — o pneu já está montado no veículo,
/// só troca de posição (X1/X2 → eixo).
void _escolherEixoEMover(
  BuildContext context,
  Pneu pneu,
  Veiculo veiculo,
  List<String> eixoSlotsVazios, {
  void Function(String localEixoDestino, Pneu pneu)? onMovidoParaEixo,
}) async {
  final destino = eixoSlotsVazios.length == 1
      ? eixoSlotsVazios.first
      : await _showEscolhaEixoDialog(context, eixoSlotsVazios);
  if (destino == null) return;
  if (!context.mounted) return;

  final entrada = await showPneuEntradaSheet(
    context,
    pneu,
    veiculo,
    destino,
    veiculo.codEsqEixo,
    const EstepeOrigem(),
    localizacaoOrigemOverride: 'FROTA',
  );
  if (entrada != null) {
    onMovidoParaEixo?.call(destino, pneu);
  }
}

Future<String?> _showEscolhaEixoDialog(
  BuildContext context,
  List<String> eixoSlotsVazios,
) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.textHint, width: 1),
      ),
      child: SizedBox(
        width: 340,
        height: 420,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 32, 25, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Mover para qual eixo?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(height: 11),
              Center(
                child: Text(
                  'Selecione a posição de destino',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelNumbers.copyWith(
                    color: AppColors.textPlaceholder,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final slot in eixoSlotsVazios)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, slot),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primaryBorder,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Texto por extenso em destaque — é o que o
                                  // motorista de fato lê no dia a dia; o
                                  // código bruto (ex.: "2EI") não diz nada
                                  // pra quem não conhece a nomenclatura
                                  // interna do app, então vira só um detalhe
                                  // pequeno abaixo.
                                  Text(
                                    descreverEixoSlot(slot),
                                    style: AppTextStyles.buttonSecondary,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Posição $slot',
                                    style: AppTextStyles.footer.copyWith(
                                      color: AppColors.textPlaceholder,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Dialog de escolha da origem (estoque/conserto/recapagem) para montar um
/// pneu na posição [localEixo] do [veiculo] — que precisa chegar até aqui
/// porque o POST de montagem exige placa e nº de frota.
void showSlotVazioAcoesDialog(
  BuildContext context,
  String localEixo,
  Veiculo veiculo, {
  void Function(String localEixo, Pneu pneu)? onConfirmed,
}) {
  const acoesInsercao = [
    PneuAcao.estoque,
    PneuAcao.conserto,
    PneuAcao.recapagem,
  ];

  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.textHint, width: 1),
      ),
      child: SizedBox(
        width: 340,
        height: 210,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 32, 25, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Posição $localEixo',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Center(
                    child: Text(
                      'Selecione a origem do pneu',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelNumbers.copyWith(
                        color: AppColors.textPlaceholder,
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < acoesInsercao.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        _AcaoCard(
                          acao: acoesInsercao[i],
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _navegarParaListaPneus(
                              context,
                              localEixo,
                              veiculo,
                              acoesInsercao[i],
                              onConfirmed: onConfirmed,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              left: 304,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(dialogContext),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CustomPaint(painter: CloseXPainter()),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _navegarParaListaPneus(
  BuildContext context,
  String localEixo,
  Veiculo veiculo,
  PneuAcao acao, {
  void Function(String localEixo, Pneu pneu)? onConfirmed,
}) async {
  final filtro = acao.label.toUpperCase();

  final selectedPneu = await Navigator.push<Pneu>(
    context,
    MaterialPageRoute(
      builder: (_) => PneuListaScreen(
        selectionMode: true,
        title: 'Pneus em ${acao.label}',
        fetchFn: (token) async {
          final todos = await pneu_service.fetchPneus(token);
          return todos
              .where((p) => p.localizacao.toUpperCase() == filtro)
              .toList();
        },
      ),
    ),
  );

  if (selectedPneu != null) {
    if (!context.mounted) return;
    // O POST /pneu/movimentarpneu (e os toasts de sucesso/erro) acontece
    // dentro do próprio sheet; ele só retorna não-nulo se a API confirmou.
    final entrada = await showPneuEntradaSheet(
      context,
      selectedPneu,
      veiculo,
      localEixo,
      // O esquema de eixos é do VEÍCULO (fonte de verdade), não do pneu de
      // estoque — o codEsqEixo do pneu em estoque costuma vir vazio e faria a
      // montagem enviar codesqeixo nulo.
      veiculo.codEsqEixo,
      acao,
    );
    if (entrada != null) {
      onConfirmed?.call(localEixo, selectedPneu);
    }
  }
}

void _confirmAction(
  BuildContext context,
  Pneu pneu,
  PneuAcao destino, {
  void Function(Pneu pneu)? onConfirmed,
}) async {
  final origem = _origemFromLocalizacao(pneu.localizacao);

  if (origem == null) {
    // Pneu está montado num veículo → formulário de saída do veículo.
    // O POST /pneu/movimentarpneu (e os toasts de sucesso/erro) acontece
    // dentro do próprio sheet; ele só retorna não-nulo se a API confirmou.
    final movimentacao = await showPneuMovimentacaoSheet(
      context,
      pneu,
      destino,
    );
    if (movimentacao != null) {
      onConfirmed?.call(pneu);
    }
  } else {
    // Pneu em estoque/conserto/recauchutagem/sucata → movimentação horizontal.
    // O POST /pneu/movimentarpneu (e os toasts de sucesso/erro) acontece
    // dentro do próprio sheet; ele só retorna não-nulo se a API confirmou.
    final mov = await showPneuHorizontalSheet(context, pneu, origem, destino);
    if (mov != null) {
      onConfirmed?.call(pneu);
    }
  }
}
