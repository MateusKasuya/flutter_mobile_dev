import 'package:flutter/material.dart';
import '../utils/cpf_validator.dart';

class CpfField extends StatelessWidget {
  final TextEditingController controller;

  const CpfField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [maskFormatter],
      decoration: InputDecoration(
        labelText: 'CPF',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe o CPF';
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.length < 11) return 'CPF incompleto';
        if (!isValidCpf(value)) return 'CPF inválido';
        return null;
      },
    );
  }
}
