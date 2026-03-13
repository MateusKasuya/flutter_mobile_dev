import 'package:flutter/material.dart';

import '../models/veiculo.dart';

class FrotaDetalheScreen extends StatelessWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(veiculo.placa)),
      body: const Center(child: Text('Detalhes do veículo')),
    );
  }
}
