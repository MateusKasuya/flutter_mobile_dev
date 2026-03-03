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
              icon: Icons.directions_car,
              onTap: null,
            ),
            const SizedBox(height: 16),
            _MovimentoCard(
              label: 'Pneu',
              icon: Icons.tire_repair,
              onTap: null,
            ),
            const SizedBox(height: 16),
            _MovimentoCard(
              label: 'Abastecimento',
              icon: Icons.local_gas_station,
              onTap: null,
            ),
          ],
        ),
    );
  }
}

class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

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
        onTap: onTap,
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
            Icon(icon, size: 28, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
