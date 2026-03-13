import 'package:flutter/material.dart';

import '../models/pneu.dart';
import '../models/veiculo.dart';

class FrotaDetalheScreen extends StatelessWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(veiculo.placa)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _VeiculoCard(veiculo: veiculo),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.tire_repair, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Pneus (${veiculo.pneus.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...veiculo.pneus.map((pneu) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PneuCard(pneu: pneu),
              )),
        ],
      ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class _PneuCard extends StatelessWidget {
  final Pneu pneu;

  const _PneuCard({required this.pneu});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colorScheme.secondaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.tire_repair,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pneu ${pneu.nroPneu}',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
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
                _InfoRow(label: 'N Pneu', value: pneu.nroPneu),
                _InfoRow(label: 'Esquema Eixo', value: pneu.codEsqEixo),
                _InfoRow(label: 'Local Eixo', value: pneu.localEixo),
                _InfoRow(label: 'Marca', value: pneu.marca),
                _InfoRow(label: 'Modelo', value: pneu.modelo),
                _InfoRow(label: 'Dimensão', value: pneu.dimensao),
                _InfoRow(label: 'Tipo', value: pneu.tipo),
                _InfoRow(label: 'Qtd. Vida', value: pneu.vidaPneu),
                _InfoRow(label: 'KM Atual', value: pneu.kmRodado),
                _InfoRow(label: 'KM Ult. Vei.', value: pneu.kmAtuVei),
                _InfoRow(label: 'D. Ult. Atualização', value: pneu.dataAtzKm),
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
