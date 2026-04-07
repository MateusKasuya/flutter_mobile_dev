import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/pneu_entrada_veiculo.dart';
import 'shared/form_helpers.dart';

Future<PneuEntradaVeiculo?> showPneuEntradaSheet(
  BuildContext context,
  Pneu pneu,
  String localEixo,
  String codEsqEixo,
  PneuAcao origem,
) {
  return showModalBottomSheet<PneuEntradaVeiculo>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PneuEntradaForm(
      pneu: pneu,
      localEixo: localEixo,
      codEsqEixo: codEsqEixo,
      origem: origem,
    ),
  );
}

class _PneuEntradaForm extends StatefulWidget {
  final Pneu pneu;
  final String localEixo;
  final String codEsqEixo;
  final PneuAcao origem;

  const _PneuEntradaForm({
    required this.pneu,
    required this.localEixo,
    required this.codEsqEixo,
    required this.origem,
  });

  @override
  State<_PneuEntradaForm> createState() => _PneuEntradaFormState();
}

class _PneuEntradaFormState extends State<_PneuEntradaForm> {
  final _formKey = GlobalKey<FormState>();
  final _dataEnvioController = TextEditingController();
  final _kmEntradaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataEnvioController.text = formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dataEnvioController.dispose();
    _kmEntradaController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dataEnvioController.text = formatDate(picked);
    }
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final entrada = PneuEntradaVeiculo(
      nroPneu: widget.pneu.nroPneu,
      codEsqEixo: widget.codEsqEixo,
      localEixo: widget.localEixo,
      dataEnvio: _dataEnvioController.text,
      kmEntradaVeiculo: _kmEntradaController.text,
      origem: widget.origem,
    );

    Navigator.pop(context, entrada);
  }

  @override
  Widget build(BuildContext context) {
    final origem = widget.origem;
    final pneu = widget.pneu;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header colorido com ícone e origem
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: origem.color.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: origem.color.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(origem.icon, color: origem.color, size: 22),
                const SizedBox(width: 10),
                Text(
                  origem.label,
                  style: TextStyle(
                    color: origem.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '→ Posição ${widget.localEixo}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Formulário
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReadOnlyField(label: 'Nº do Pneu', value: pneu.nroPneu),
                    const SizedBox(height: 14),
                    ReadOnlyField(label: 'Esquema de Eixo', value: widget.codEsqEixo),
                    const SizedBox(height: 14),
                    ReadOnlyField(label: 'Localização Eixo', value: widget.localEixo),
                    const SizedBox(height: 14),
                    FieldLabel('Data do Envio'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _dataEnvioController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: formInputDecoration(
                        hint: 'DD/MM/AAAA',
                        suffix: const Icon(Icons.calendar_today, size: 18),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FieldLabel('KM Entrada Veículo'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _kmEntradaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorFormatter(),
                      ],
                      decoration: formInputDecoration(hint: 'Informe o KM do veículo'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe o KM de entrada' : null,
                    ),
                    const SizedBox(height: 24),
                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _confirmar,
                            style: FilledButton.styleFrom(
                              backgroundColor: origem.color,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
