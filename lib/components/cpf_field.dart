import 'package:flutter/material.dart';
import '../components/app_input_decoration.dart';
import '../utils/cpf_validator.dart';

class CpfField extends StatelessWidget {
  final TextEditingController controller;

  const CpfField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 50,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [maskFormatter],
        decoration: appInputDecoration(hintText: '000.000.000-00'),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Informe o CPF';
          final digits = value.replaceAll(RegExp(r'[^\d]'), '');
          if (digits.length < 11) return 'CPF incompleto';
          if (!isValidCpf(value)) return 'CPF inválido';
          return null;
        },
      ),
    );
  }
}
