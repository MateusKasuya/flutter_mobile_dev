import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RememberMeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-5, 0),
            child: Transform.scale(
              scale: 24 / 18,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Lembrar usuário e senha',
              style: AppTextStyles.checkboxLabel,
            ),
          ),
        ],
      ),
    );
  }
}
