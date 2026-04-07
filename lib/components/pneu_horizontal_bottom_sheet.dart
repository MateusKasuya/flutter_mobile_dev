import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/pneu_mov_horizontal.dart';
import '../models/pneu_movimentacao.dart';
import '../screens/pneu_lista_screen.dart';
import '../services/pneu_service.dart' as pneu_service;
import '../theme/app_colors.dart';
import 'shared/form_helpers.dart';

Future<PneuMovHorizontal?> showPneuHorizontalSheet(
  BuildContext context,
  Pneu? initialPneu,
  PneuAcao origem,
  PneuAcao destino,
) {
  return showModalBottomSheet<PneuMovHorizontal>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PneuHorizontalForm(
      initialPneu: initialPneu,
      origem: origem,
      destino: destino,
    ),
  );
}

class _PneuHorizontalForm extends StatefulWidget {
  final Pneu? initialPneu;
  final PneuAcao origem;
  final PneuAcao destino;

  const _PneuHorizontalForm({
    required this.initialPneu,
    required this.origem,
    required this.destino,
  });

  @override
  State<_PneuHorizontalForm> createState() => _PneuHorizontalFormState();
}

class _PneuHorizontalFormState extends State<_PneuHorizontalForm> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _valorController = TextEditingController();
  final _motivoController = TextEditingController();
  final _fornecedorRecapController = TextEditingController();
  final _observacaoController = TextEditingController();

  Pneu? _selectedPneu;
  MotivoSucateamento? _motivoSucateamento;
  bool _proibidoFuturaRecap = false;
  bool _pneuError = false;

  // ── Lógica de exibição dos campos ────────────────────────────────────────

  /// Valor aparece quando a origem é conserto/recauchutagem (registra custo)
  /// ou quando o destino é venda (registra preço).
  bool get _showValor =>
      widget.origem == PneuAcao.conserto ||
      widget.origem == PneuAcao.recapagem ||
      widget.destino == PneuAcao.venda;

  /// Motivo (texto livre) aparece em movimentos de recauchutagem e venda.
  bool get _showMotivo =>
      (widget.origem == PneuAcao.estoque && widget.destino == PneuAcao.recapagem) ||
      widget.destino == PneuAcao.venda;

  bool get _showMotivoSucateamento => widget.destino == PneuAcao.sucata;

  /// Fornecedor só aparece em Conserto → Recauchutagem (placeholder de API futura).
  bool get _showFornecedorRecap =>
      widget.origem == PneuAcao.conserto && widget.destino == PneuAcao.recapagem;

  /// Flag de proibição de futura recauchutagem aparece em qualquer saída da recauchutagem.
  bool get _showFlagProibidoRecap => widget.origem == PneuAcao.recapagem;

  /// Observação é mostrada quando não há campo "motivo" (eles são mutuamente exclusivos).
  bool get _showObservacao => !_showMotivo;

  String get _dataLabel {
    if (widget.origem == PneuAcao.conserto || widget.origem == PneuAcao.recapagem) {
      return 'Data de Retorno';
    }
    if (widget.destino == PneuAcao.venda) return 'Data da Venda';
    return 'Data de Envio';
  }

  String get _valorLabel {
    if (widget.origem == PneuAcao.conserto) return 'Valor do Conserto';
    if (widget.origem == PneuAcao.recapagem) return 'Valor da Recauchutagem';
    return 'Valor da Venda';
  }

  // ── Ciclo de vida ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedPneu = widget.initialPneu;
    _dataController.text = formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dataController.dispose();
    _valorController.dispose();
    _motivoController.dispose();
    _fornecedorRecapController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  // ── Ações ────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) _dataController.text = formatDate(picked);
  }

  Future<void> _selecionarPneu() async {
    final filtro = widget.origem.label.toUpperCase();
    final pneu = await Navigator.push<Pneu>(
      context,
      MaterialPageRoute(
        builder: (_) => PneuListaScreen(
          selectionMode: true,
          title: 'Pneus em ${widget.origem.label}',
          fetchFn: (token) async {
            final todos = await pneu_service.fetchPneus(token);
            return todos
                .where((p) => p.localizacao.toUpperCase() == filtro)
                .toList();
          },
        ),
      ),
    );
    if (pneu != null) {
      setState(() {
        _selectedPneu = pneu;
        _pneuError = false;
      });
    }
  }

  void _confirmar() {
    if (_selectedPneu == null) {
      setState(() => _pneuError = true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      PneuMovHorizontal(
        nroPneu: _selectedPneu!.nroPneu,
        origem: widget.origem,
        destino: widget.destino,
        data: _dataController.text,
        valor: _showValor ? _valorController.text : null,
        motivo: _showMotivo ? _motivoController.text : null,
        fornecedorRecap:
            _showFornecedorRecap ? _fornecedorRecapController.text : null,
        motivoSucateamento:
            _showMotivoSucateamento ? _motivoSucateamento : null,
        proibidoFuturaRecap: _proibidoFuturaRecap,
        observacao: _showObservacao ? _observacaoController.text : '',
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final origem = widget.origem;
    final destino = widget.destino;

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
          // Header: Origem → Destino
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: destino.color.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: destino.color.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(origem.icon, color: origem.color, size: 20),
                const SizedBox(width: 6),
                Text(
                  origem.label,
                  style: TextStyle(
                    color: origem.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
                Icon(destino.icon, color: destino.color, size: 20),
                const SizedBox(width: 6),
                Text(
                  destino.label,
                  style: TextStyle(
                    color: destino.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
                    _buildPneuPicker(),
                    const SizedBox(height: 14),
                    FieldLabel(_dataLabel),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _dataController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: formInputDecoration(
                        hint: 'DD/MM/AAAA',
                        suffix: const Icon(Icons.calendar_today, size: 18),
                      ),
                    ),
                    if (_showValor) ...[
                      const SizedBox(height: 14),
                      FieldLabel(_valorLabel),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _valorController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [BrazilianCurrencyFormatter()],
                        decoration: formInputDecoration(hint: '0,00'),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Informe o valor' : null,
                      ),
                    ],
                    if (_showFornecedorRecap) ...[
                      const SizedBox(height: 14),
                      FieldLabel('Fornecedor de Recauchutagem'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _fornecedorRecapController,
                        decoration:
                            formInputDecoration(hint: 'Nome do fornecedor'),
                      ),
                    ],
                    if (_showFlagProibidoRecap) ...[
                      const SizedBox(height: 14),
                      _buildSwitch(
                        label: 'Proibido futura recauchutagem',
                        value: _proibidoFuturaRecap,
                        onChanged: (v) =>
                            setState(() => _proibidoFuturaRecap = v),
                      ),
                    ],
                    if (_showMotivoSucateamento) ...[
                      const SizedBox(height: 14),
                      FieldLabel('Motivo de Sucateamento'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<MotivoSucateamento>(
                        initialValue: _motivoSucateamento,
                        decoration:
                            formInputDecoration(hint: 'Selecione o motivo'),
                        items: MotivoSucateamento.valores
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _motivoSucateamento = v),
                        validator: (v) => v == null
                            ? 'Selecione o motivo de sucateamento'
                            : null,
                      ),
                    ],
                    if (_showMotivo) ...[
                      const SizedBox(height: 14),
                      FieldLabel('Motivo'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _motivoController,
                        decoration:
                            formInputDecoration(hint: 'Descreva o motivo'),
                      ),
                    ],
                    if (_showObservacao) ...[
                      const SizedBox(height: 14),
                      FieldLabel('Observação'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _observacaoController,
                        maxLines: 3,
                        decoration: formInputDecoration(
                            hint: 'Observações (opcional)'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                              backgroundColor: destino.color,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildPneuPicker() {
    // Quando o pneu foi pré-selecionado (veio do diagrama), exibe como read-only.
    if (widget.initialPneu != null) {
      return ReadOnlyField(label: 'Nº do Pneu', value: _selectedPneu!.nroPneu);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel('Nº do Pneu'),
        const SizedBox(height: 6),
        InkWell(
          onTap: _selecionarPneu,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: _pneuError ? Colors.red : AppColors.primaryBorder,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedPneu != null
                        ? 'Pneu #${_selectedPneu!.nroPneu}'
                        : 'Toque para selecionar',
                    style: TextStyle(
                      color: _selectedPneu != null
                          ? AppColors.textDark
                          : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.search, size: 18, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
        if (_pneuError) ...[
          const SizedBox(height: 4),
          const Text(
            'Selecione um pneu',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
