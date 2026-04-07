import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/pneu_movimentacao.dart';
import 'shared/form_helpers.dart';

Future<PneuMovimentacao?> showPneuMovimentacaoSheet(
  BuildContext context,
  Pneu pneu,
  PneuAcao acao,
) {
  return showModalBottomSheet<PneuMovimentacao>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PneuMovimentacaoForm(pneu: pneu, acao: acao),
  );
}

class _PneuMovimentacaoForm extends StatefulWidget {
  final Pneu pneu;
  final PneuAcao acao;

  const _PneuMovimentacaoForm({required this.pneu, required this.acao});

  @override
  State<_PneuMovimentacaoForm> createState() => _PneuMovimentacaoFormState();
}

class _PneuMovimentacaoFormState extends State<_PneuMovimentacaoForm> {
  final _formKey = GlobalKey<FormState>();
  final _dataRetornoController = TextEditingController();
  final _kmSaidaController = TextEditingController();
  final _observacaoController = TextEditingController();

  MotivoSucateamento? _motivoSucateamento;

  @override
  void initState() {
    super.initState();
    _dataRetornoController.text = formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dataRetornoController.dispose();
    _kmSaidaController.dispose();
    _observacaoController.dispose();
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
      _dataRetornoController.text = formatDate(picked);
    }
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final movimentacao = PneuMovimentacao(
      nroPneu: widget.pneu.nroPneu,
      dataEnvio: widget.pneu.dataAtzKm,
      dataRetorno: _dataRetornoController.text,
      kmEntrada: widget.pneu.kmAtuVei,
      kmSaida: _kmSaidaController.text,
      motivoSucateamento: _motivoSucateamento,
      observacao: _observacaoController.text,
      acao: widget.acao,
    );

    Navigator.pop(context, movimentacao);
  }

  @override
  Widget build(BuildContext context) {
    final acao = widget.acao;
    final pneu = widget.pneu;

    return Padding(
      // Sobe o conteúdo quando o teclado aparecer
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
          // Header colorido com ícone e título da ação
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: acao.color.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: acao.color.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(acao.icon, color: acao.color, size: 22),
                const SizedBox(width: 10),
                Text(
                  acao.label,
                  style: TextStyle(
                    color: acao.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '— Pneu ${pneu.nroPneu}',
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
                    ReadOnlyField(label: 'Data do envio', value: normalizeDateStr(pneu.dataAtzKm)),
                    const SizedBox(height: 14),
                    FieldLabel('Data do retorno'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _dataRetornoController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: formInputDecoration(
                        hint: 'DD/MM/AAAA',
                        suffix: const Icon(Icons.calendar_today, size: 18),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ReadOnlyField(label: 'KM de entrada', value: formatKm(pneu.kmAtuVei)),
                    const SizedBox(height: 14),
                    FieldLabel('KM de saída'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _kmSaidaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorFormatter(),
                      ],
                      decoration: formInputDecoration(hint: 'Informe o KM atual'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe o KM de saída' : null,
                    ),
                    if (acao == PneuAcao.sucata) ...[
                      const SizedBox(height: 14),
                      FieldLabel('Motivo de sucateamento'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<MotivoSucateamento>(
                        initialValue: _motivoSucateamento,
                        decoration: formInputDecoration(hint: 'Selecione o motivo'),
                        items: MotivoSucateamento.valores
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.label, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _motivoSucateamento = v),
                        validator: (v) =>
                            v == null ? 'Selecione o motivo de sucateamento' : null,
                      ),
                    ],
                    const SizedBox(height: 14),
                    FieldLabel('Observação'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _observacaoController,
                      maxLines: 3,
                      decoration: formInputDecoration(hint: 'Observações (opcional)'),
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
                              backgroundColor: acao.color,
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
