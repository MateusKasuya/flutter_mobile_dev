import 'package:flutter/material.dart';

import '../components/diagrama_eixos.dart';
import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/veiculo.dart';
import '../utils/app_toast.dart';
import '../utils/eixo_utils.dart';

class FrotaDetalheScreen extends StatelessWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    final eixos = buildEixoLayout(veiculo.pneus);

    return Scaffold(
      appBar: AppBar(title: Text(veiculo.placa)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _VeiculoCard(veiculo: veiculo),
          const SizedBox(height: 24),
          DiagramaEixos(
            eixos: eixos,
            onPneuTap: (pneu) => _showPneuDetails(context, pneu),
          ),
          const SizedBox(height: 24),
          const _AcoesHeader(),
          const SizedBox(height: 12),
          _AcoesGrid(
            onPneuAction: (pneu, acao) => _confirmAction(context, pneu, acao),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

void _showPneuDetails(BuildContext context, Pneu pneu) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Pneu ${pneu.nroPneu}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          _InfoRow(label: 'Posição', value: pneu.localEixo),
          _InfoRow(label: 'Marca', value: pneu.marca),
          _InfoRow(label: 'Modelo', value: pneu.modelo),
          _InfoRow(label: 'Dimensão', value: pneu.dimensao),
          _InfoRow(label: 'Tipo', value: pneu.tipo),
          _InfoRow(label: 'Qtd. Vida', value: pneu.vidaPneu),
          _InfoRow(label: 'KM Rodado', value: pneu.kmRodado),
          _InfoRow(label: 'KM Ult. Vei.', value: pneu.kmAtuVei),
          _InfoRow(label: 'D. Ult. Atualização', value: pneu.dataAtzKm),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

void _confirmAction(
    BuildContext context, Pneu pneu, PneuAcao acao) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(acao.label),
      content: Text('Mover pneu ${pneu.nroPneu} para ${acao.label}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: acao.color),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // TODO: chamar API quando endpoint estiver disponível
    showSuccessToast('Pneu ${pneu.nroPneu} movido para ${acao.label}');
  }
}

class _AcoesHeader extends StatelessWidget {
  const _AcoesHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.drag_indicator, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          'Arraste um pneu para uma ação',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AcoesGrid extends StatelessWidget {
  final void Function(Pneu pneu, PneuAcao acao) onPneuAction;

  const _AcoesGrid({required this.onPneuAction});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: PneuAcao.values
          .map((acao) => _ActionZone(acao: acao, onPneuAction: onPneuAction))
          .toList(),
    );
  }
}

class _ActionZone extends StatelessWidget {
  final PneuAcao acao;
  final void Function(Pneu pneu, PneuAcao acao) onPneuAction;

  const _ActionZone({required this.acao, required this.onPneuAction});

  @override
  Widget build(BuildContext context) {
    return DragTarget<Pneu>(
      onAcceptWithDetails: (details) => onPneuAction(details.data, acao),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: isHovering
                ? acao.color.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? acao.color : Colors.grey.shade300,
              width: isHovering ? 2.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                acao.icon,
                color: isHovering ? acao.color : Colors.grey.shade600,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                acao.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isHovering ? acao.color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VeiculoCard extends StatelessWidget {
  final Veiculo veiculo;

  const _VeiculoCard({required this.veiculo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: colorScheme.primary,
            child: Row(
              children: [
                Icon(Icons.directions_car, color: colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text(
                  '${veiculo.placa} - Frota ${veiculo.nroFrota}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'Marca', value: veiculo.marca),
                _InfoRow(label: 'Modelo', value: veiculo.modelo),
                _InfoRow(
                  label: 'Ano',
                  value: veiculo.anoModelo.isEmpty
                      ? veiculo.ano
                      : '${veiculo.ano}/${veiculo.anoModelo}',
                ),
                _InfoRow(label: 'Cor', value: veiculo.cor),
                _InfoRow(label: 'Tipo', value: veiculo.tipo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
