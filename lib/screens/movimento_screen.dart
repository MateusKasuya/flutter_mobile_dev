import 'package:flutter/material.dart';

class MovimentoScreen extends StatelessWidget {
  const MovimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
            _MovimentoCard(
              label: 'Frotas',
              subtitle: 'Movimentações de frota',
              icon: Icons.directions_car,
            ),
            const SizedBox(height: 16),
            _MovimentoCard(
              label: 'Pneu',
              subtitle: 'Controle de pneus',
              icon: Icons.tire_repair,
            ),
            const SizedBox(height: 16),
            _MovimentoCard(
              label: 'Abastecimento',
              subtitle: 'Registro de abastecimento',
              icon: Icons.local_gas_station,
            ),
          ],
        ),
    );
  }
}

class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 100,
          child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, size: 40, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
