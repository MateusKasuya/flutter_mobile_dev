import 'package:flutter/material.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../screens/pneu_lista_screen.dart';
import '../services/pneu_service.dart' as pneu_service;
import '../utils/app_toast.dart';
import 'pneu_entrada_bottom_sheet.dart';
import 'pneu_horizontal_bottom_sheet.dart';
import 'pneu_movimentacao_bottom_sheet.dart';

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
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pneu ${pneu.nroPneu}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecione uma ação',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            _buildAcoesGrid(context, pneu, onConfirmed: onConfirmed),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
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
          _AcaoCard(acao: acoes[0], onTap: tapFor(acoes[0]), disabled: isDisabled(acoes[0])),
          const SizedBox(width: 10),
          _AcaoCard(acao: acoes[1], onTap: tapFor(acoes[1]), disabled: isDisabled(acoes[1])),
          const SizedBox(width: 10),
          _AcaoCard(acao: acoes[2], onTap: tapFor(acoes[2]), disabled: isDisabled(acoes[2])),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AcaoCard(acao: acoes[3], onTap: tapFor(acoes[3]), disabled: isDisabled(acoes[3])),
          const SizedBox(width: 10),
          _AcaoCard(acao: acoes[4], onTap: tapFor(acoes[4]), disabled: isDisabled(acoes[4])),
        ],
      ),
    ],
  );
}

class _AcaoCard extends StatelessWidget {
  final PneuAcao acao;
  final VoidCallback onTap;
  final bool disabled;

  const _AcaoCard({required this.acao, required this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = disabled ? Colors.grey.shade400 : acao.color;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: effectiveColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(acao.icon, color: effectiveColor, size: 28),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  acao.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: effectiveColor,
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

void showSlotVazioAcoesDialog(
  BuildContext context,
  String localEixo, {
  void Function(String localEixo, Pneu pneu)? onConfirmed,
}) {
  const acoesInsercao = [PneuAcao.estoque, PneuAcao.conserto, PneuAcao.recapagem];

  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posição $localEixo',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecione a origem do pneu',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
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
                        acoesInsercao[i],
                        onConfirmed: onConfirmed,
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
    final entrada = await showPneuEntradaSheet(
      context,
      selectedPneu,
      localEixo,
      selectedPneu.codEsqEixo,
      acao,
    );
    if (entrada != null) {
      // TODO: chamar API quando endpoint estiver disponível
      showSuccessToast(
        'Pneu ${selectedPneu.nroPneu} inserido na posição $localEixo',
      );
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
    final movimentacao = await showPneuMovimentacaoSheet(context, pneu, destino);
    if (movimentacao != null) {
      // TODO: enviar para a API quando endpoint estiver disponível
      showSuccessToast('Pneu ${pneu.nroPneu} movido para ${destino.label}');
      onConfirmed?.call(pneu);
    }
  } else {
    // Pneu em estoque/conserto/recauchutagem/sucata → movimentação horizontal.
    final mov = await showPneuHorizontalSheet(context, pneu, origem, destino);
    if (mov != null) {
      // TODO: enviar para a API quando endpoint estiver disponível
      showSuccessToast('Pneu ${pneu.nroPneu} movido para ${destino.label}');
      onConfirmed?.call(pneu);
    }
  }
}
