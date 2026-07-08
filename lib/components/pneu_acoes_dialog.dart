import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/veiculo.dart';
import '../screens/pneu_lista_screen.dart';
import '../services/pneu_service.dart' as pneu_service;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'pneu_entrada_bottom_sheet.dart';
import 'pneu_horizontal_bottom_sheet.dart';
import 'pneu_movimentacao_bottom_sheet.dart';
import 'shared/close_x_painter.dart';

/// Retorna a [PneuAcao] correspondente à localização do pneu,
/// ou null quando o pneu está montado num veículo (localização desconhecida).
PneuAcao? _origemFromLocalizacao(String localizacao) {
  try {
    return PneuAcao.values.firstWhere(
      (a) => a.label.toUpperCase() == localizacao.toUpperCase(),
    );
  } catch (_) {
    return null;
  }
}

/// Retorna true para pares origem→destino proibidos pelas regras de negócio.
bool _isProibido(PneuAcao origem, PneuAcao destino) {
  if (origem == PneuAcao.conserto && destino == PneuAcao.venda) return true;
  if (origem == PneuAcao.recapagem && destino == PneuAcao.venda) return true;
  if (origem == PneuAcao.sucata && destino != PneuAcao.venda) return true;
  if (origem == PneuAcao.venda) return true;
  return false;
}

void showPneuAcoesDialog(
  BuildContext context,
  Pneu pneu, {
  void Function(Pneu pneu)? onConfirmed,
}) {
  showDialog<void>(
    context: context,
    builder: (context) {
      final isTablet = MediaQuery.of(context).size.width >= 600;
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
                    _buildAcoesGrid(context, pneu, onConfirmed: onConfirmed),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: isTablet ? 354 : 304,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
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
  Pneu pneu, {
  void Function(Pneu pneu)? onConfirmed,
}) {
  final acoes = PneuAcao.values;

  final origem = _origemFromLocalizacao(pneu.localizacao);

  bool isAtual(PneuAcao acao) =>
      acao.label.toUpperCase() == pneu.localizacao.toUpperCase();

  bool isDisabled(PneuAcao acao) {
    if (isAtual(acao)) return true;
    if (origem != null && _isProibido(origem, acao)) return true;
    return false;
  }

  VoidCallback tapFor(PneuAcao acao) => () {
    Navigator.pop(context);
    _confirmAction(context, pneu, acao, onConfirmed: onConfirmed);
  };

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AcaoCard(
            acao: acoes[0],
            onTap: tapFor(acoes[0]),
            disabled: isDisabled(acoes[0]),
          ),
          const SizedBox(width: 10),
          _AcaoCard(
            acao: acoes[1],
            onTap: tapFor(acoes[1]),
            disabled: isDisabled(acoes[1]),
          ),
          const SizedBox(width: 10),
          _AcaoCard(
            acao: acoes[2],
            onTap: tapFor(acoes[2]),
            disabled: isDisabled(acoes[2]),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AcaoCard(
            acao: acoes[3],
            onTap: tapFor(acoes[3]),
            disabled: isDisabled(acoes[3]),
          ),
          const SizedBox(width: 10),
          _AcaoCard(
            acao: acoes[4],
            onTap: tapFor(acoes[4]),
            disabled: isDisabled(acoes[4]),
          ),
        ],
      ),
    ],
  );
}

class _AcaoCard extends StatelessWidget {
  final PneuAcao acao;
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
