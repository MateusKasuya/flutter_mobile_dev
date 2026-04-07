import 'package:flutter/material.dart';

import '../components/diagrama_eixos.dart';
import '../components/pneu_acoes_dialog.dart';
import '../models/eixo.dart';
import '../models/pneu.dart';
import '../models/veiculo.dart';
import '../utils/eixo_utils.dart';

class FrotaDetalheScreen extends StatefulWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  State<FrotaDetalheScreen> createState() => _FrotaDetalheScreenState();
}

class _FrotaDetalheScreenState extends State<FrotaDetalheScreen> {
  late List<Eixo> _eixos;

  @override
  void initState() {
    super.initState();
    _eixos = buildEixoLayout(widget.veiculo.pneus);
  }

  void _onPneuConfirmed(Pneu pneu) {
    setState(() {
      _eixos = _eixos.map((e) => e.withoutPneu(pneu)).toList();
    });
  }

  void _onSlotVazioConfirmed(String localEixo, Pneu pneu) {
    final eixoNumero = int.parse(localEixo[0]);
    final posicao = localEixo.substring(1);
    setState(() {
      _eixos = _eixos.map((e) {
        if (e.numero == eixoNumero) return e.withPneuAt(posicao, pneu);
        return e;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.veiculo.placa)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _VeiculoCard(veiculo: widget.veiculo),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DiagramaEixos(
                eixos: _eixos,
                onPneuTap: (pneu) => _showPneuDetails(context, pneu),
                onPneuDoubleTap: (pneu) => showPneuAcoesDialog(
                  context,
                  pneu,
                  onConfirmed: _onPneuConfirmed,
                ),
                onSlotVazioDoubleTap: (localEixo) =>
                    showSlotVazioAcoesDialog(
                      context,
                      localEixo,
                      onConfirmed: _onSlotVazioConfirmed,
                    ),
              ),
            ),
          ),
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
