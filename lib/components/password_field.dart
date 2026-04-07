import 'package:flutter/material.dart';
import '../components/app_input_decoration.dart';
import '../theme/app_colors.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 50,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscurePassword,
        decoration: appInputDecoration(
          hintText: 'Digite a senha',
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            color: AppColors.primaryBorder,
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Informe a senha';
          return null;
        },
      ),
    );
  }
}
