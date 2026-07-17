import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/fornecedor.dart';
import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../models/pneu_movimentacao.dart';
import '../providers/auth_provider.dart';
import '../screens/pneu_lista_screen.dart';
import '../services/fornecedor_service.dart' as fornecedor_service;
import '../services/pneu_service.dart' as pneu_service;
import '../services/sucata_service.dart' as sucata_service;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/breakpoints.dart';
import '../utils/app_toast.dart';
import '../utils/friendly_error.dart';
import 'shared/close_x_painter.dart';
import 'shared/form_helpers.dart';

Future<bool?> showPneuHorizontalSheet(
  BuildContext context,
  Pneu? initialPneu,
  PneuAcao origem,
  PneuAcao destino, {
  http.Client? client,
}) {
  // Altura fixa por combinação origem→destino. Cada movimentação tem um
  // conjunto diferente de campos, então o sheet/dialog usa altura exata
  // em vez de crescer com o conteúdo — bate com as specs de design.
  final sheetHeight = _sheetHeightFor(origem, destino);

  final mq = MediaQuery.of(context);
  // Breakpoint padrão do app: ≥600pt = tablet (mesma regra das outras
  // bottom sheets que viram Dialog no tablet).
  final isTablet = mq.size.width >= kTabletBreakpoint;

  if (isTablet) {
    // Tablet: modal centralizado, largura fixa 460pt (padrão das demais
    // dialogs do projeto). Mantém o padrão visual do fluxo horizontal:
    // faixa colorida no topo (destino.bgColor) com Origem→Destino e
    // o restante do formulário em fundo branco — mesma divisão do mobile.
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.textHint, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 460,
          height: sheetHeight,
          child: _PneuHorizontalForm(
            initialPneu: initialPneu,
            origem: origem,
            destino: destino,
            isTablet: true,
            client: client,
          ),
        ),
      ),
    );
  }

  // Mobile: bottom sheet com faixa de cabeçalho colorida + drag handle.
  // sheetHeight é a altura de REPOUSO (spec de design). O maxHeight sobe com a
  // tela pra que, ao abrir o teclado, o sheet possa CRESCER (até 60pt do topo)
  // e a barra de botões fixa siga visível acima do teclado — em vez de espremer
  // header+footer numa altura fixa e estourar. O max(...) garante
  // maxHeight >= minHeight em telas baixas (aí o teclado curto cabe sem crescer).
  final maxSheetHeight = mq.size.height - (mq.padding.top + 60);
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: BoxConstraints(
      minHeight: sheetHeight,
      maxHeight: sheetHeight > maxSheetHeight ? sheetHeight : maxSheetHeight,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: AppColors.textHint, width: 1),
    ),
    // Necessário pra que o background do header (colorido) seja recortado
    // pelos cantos superiores arredondados em vez de vazar.
    clipBehavior: Clip.antiAlias,
    builder: (context) => _PneuHorizontalForm(
      initialPneu: initialPneu,
      origem: origem,
      destino: destino,
      client: client,
    ),
  );
}

/// Altura do bottom sheet por combinação de movimentação (mobile).
/// Genéricos a todas as combinações (já aplicados no showModalBottomSheet):
/// background #FFFFFF, border 1px #C4C4C4, top-radius 20.
/// Específico por movimentação: a altura, vinda do design.
double _sheetHeightFor(PneuAcao origem, PneuAcao destino) {
  if (origem == PneuAcao.estoque && destino == PneuAcao.conserto) return 560;
  if (origem == PneuAcao.estoque && destino == PneuAcao.recapagem) return 520;
  if (origem == PneuAcao.estoque && destino == PneuAcao.sucata) return 657;
  if (origem == PneuAcao.estoque && destino == PneuAcao.venda) return 617;
  if (origem == PneuAcao.conserto && destino == PneuAcao.estoque) return 651;
  if (origem == PneuAcao.conserto && destino == PneuAcao.recapagem) return 760;
  if (origem == PneuAcao.conserto && destino == PneuAcao.sucata) return 760;
  if (origem == PneuAcao.sucata && destino == PneuAcao.venda) return 617;
  // Recapagem → X: alturas estimadas (sem specs Figma).
  // Base = equivalente por destino + ~50pt do switch "Proibido futura
  // recauchutagem", que só aparece quando a origem é recapagem.
  if (origem == PneuAcao.recapagem && destino == PneuAcao.estoque) return 705;
  if (origem == PneuAcao.recapagem && destino == PneuAcao.sucata) return 810;
  if (origem == PneuAcao.recapagem && destino == PneuAcao.venda) return 670;
  return 560;
}

/// Nome exibível do fornecedor: razão social ou, na falta dela, nome fantasia.
/// Usado tanto na ordenação/campo quanto no seletor com busca.
String _nomeFornecedor(Fornecedor f) =>
    f.razaoSocial.isNotEmpty ? f.razaoSocial : f.nomeFantasia;

class _PneuHorizontalForm extends StatefulWidget {
  final Pneu? initialPneu;
  final PneuAcao origem;
  final PneuAcao destino;
  // No modo tablet o form vive dentro de um Dialog centralizado — sem drag
  // handle, sem faixa colorida de header e sem safe-area de teclado.
  final bool isTablet;
  // Injetável nos testes (MockClient); em produção os serviços criam o próprio.
  final http.Client? client;

  const _PneuHorizontalForm({
    required this.initialPneu,
    required this.origem,
    required this.destino,
    this.isTablet = false,
    this.client,
  });

  @override
  State<_PneuHorizontalForm> createState() => _PneuHorizontalFormState();
}

class _PneuHorizontalFormState extends State<_PneuHorizontalForm> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _valorController = TextEditingController();
  final _motivoController = TextEditingController();
  final _observacaoController = TextEditingController();

  Pneu? _selectedPneu;
  MotivoSucateamento? _motivoSucateamento;
  Fornecedor? _selectedFornecedor;
  bool _proibidoFuturaRecap = false;
  bool _pneuError = false;
  bool _fornecedorError = false;

  // true enquanto o POST de movimentação está em andamento — desabilita os
  // botões (evita envio duplicado) e troca o texto do Confirmar por um spinner.
  bool _enviando = false;

  // Dados vindos da API; carregados sob demanda em initState dependendo
  // dos campos visíveis no fluxo origem→destino atual.
  List<MotivoSucateamento> _motivos = [];
  bool _loadingMotivos = false;
  String? _erroMotivos;

  List<Fornecedor> _fornecedores = [];
  bool _loadingFornecedores = false;
  String? _erroFornecedores;

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

  /// Fornecedor de recauchutagem só aparece em Conserto → Recauchutagem.
  /// A lista vem da API (GET /fornecedor/getfornecedor) via [_carregarFornecedores].
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
    if (_showMotivoSucateamento) _carregarMotivos();
    if (_showFornecedorRecap) _carregarFornecedores();
  }

  @override
  void dispose() {
    _dataController.dispose();
    _valorController.dispose();
    _motivoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarMotivos() async {
    setState(() {
      _loadingMotivos = true;
      _erroMotivos = null;
    });
    try {
      final token = context.read<AuthProvider>().token;
      final motivos = await sucata_service.fetchMotivosSucateamento(
        token,
        client: widget.client,
      );
      if (!mounted) return;
      setState(() {
        _motivos = motivos;
        _loadingMotivos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroMotivos = friendlyError(e);
        _loadingMotivos = false;
      });
      showErrorToast(_erroMotivos!);
    }
  }

  Future<void> _carregarFornecedores() async {
    setState(() {
      _loadingFornecedores = true;
      _erroFornecedores = null;
    });
    try {
      final token = context.read<AuthProvider>().token;
      final fornecedores = await fornecedor_service.fetchFornecedores(
        token,
        client: widget.client,
      );
      if (!mounted) return;
      // Lista grande: ordena alfabeticamente (case-insensitive) pra facilitar
      // a leitura e a busca no seletor.
      fornecedores.sort(
        (a, b) => _nomeFornecedor(a)
            .toLowerCase()
            .compareTo(_nomeFornecedor(b).toLowerCase()),
      );
      setState(() {
        _fornecedores = fornecedores;
        _loadingFornecedores = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroFornecedores = friendlyError(e);
        _loadingFornecedores = false;
      });
      showErrorToast(_erroFornecedores!);
    }
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

  Future<void> _selecionarFornecedor() async {
    final escolhido = await showModalBottomSheet<Fornecedor>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.textHint, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => _FornecedorPickerSheet(
        fornecedores: _fornecedores,
        selecionado: _selectedFornecedor,
      ),
    );
    if (escolhido != null) {
      setState(() {
        _selectedFornecedor = escolhido;
        _fornecedorError = false;
      });
    }
  }

  Future<void> _confirmar() async {
    if (_selectedPneu == null) {
      setState(() => _pneuError = true);
      return;
    }
    // Bloqueia o submit conforme o ESTADO do carregamento da API, não apenas
    // pela lista estar vazia. Uma lista vazia pode significar três coisas bem
    // diferentes: (1) ainda carregando, (2) deu erro de rede, ou (3) o backend
    // legitimamente devolveu []. Só (1) e (2) devem travar o envio; uma lista
    // vazia legítima (ex.: Sucata sem motivos cadastrados) não pode bloquear
    // para sempre — nesse caso o validator do dropdown já cuida da obrigação.
    if (_showMotivoSucateamento) {
      if (_loadingMotivos) {
        showErrorToast('Aguarde os motivos carregarem');
        return;
      }
      if (_erroMotivos != null) {
        showErrorToast('Não foi possível carregar os motivos. Tente novamente.');
        return;
      }
    }
    if (_showFornecedorRecap) {
      if (_loadingFornecedores) {
        showErrorToast('Aguarde os fornecedores carregarem');
        return;
      }
      if (_erroFornecedores != null) {
        showErrorToast(
          'Não foi possível carregar os fornecedores. Tente novamente.',
        );
        return;
      }
    }
    // Fornecedor de recauchutagem é obrigatório neste fluxo. Como o campo é um
    // seletor customizado (não um TextFormField), a validação é manual, no
    // mesmo padrão do seletor de pneu (_pneuError).
    if (_showFornecedorRecap && _selectedFornecedor == null) {
      setState(() => _fornecedorError = true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // A API espera nropneu/codfil como int, mas o GET os devolve como string
    // (o model faz default '' quando a API omite). Validamos com tryParse ANTES
    // de entrar no estado "enviando": int.parse('') lançaria e travaria a
    // movimentação do pneu.
    final nroPneu = int.tryParse(_selectedPneu!.nroPneu);
    final codFil = int.tryParse(_selectedPneu!.codFil);
    if (nroPneu == null || codFil == null) {
      showErrorToast('Pneu sem número ou filial válidos para movimentar.');
      return;
    }

    // Motivo e Observação nunca aparecem juntos (_showObservacao é o
    // inverso de _showMotivo) — o que existir vira o motivosaida da API.
    final motivoTexto = _showMotivo
        ? _motivoController.text
        : _observacaoController.text;

    setState(() => _enviando = true);
    try {
      final token = context.read<AuthProvider>().token;
      final mensagem = await pneu_service.movimentarPneu(
        token,
        // A API espera números onde o GET devolve strings (nropneu, codfil).
        nroPneu: nroPneu,
        // Data escolhida no form (retorno/venda/envio, conforme o fluxo) =
        // data em que o pneu entra na nova localização.
        dataEntrada: parseDate(_dataController.text) ?? DateTime.now(),
        codFil: codFil,
        // Origem e destino do movimento, pelos nomes em maiúsculas — mesmo
        // formato que o GET devolve no campo localizacao.
        localizacaoOrigem: widget.origem.label.toUpperCase(),
        localizacao: widget.destino.label.toUpperCase(),
        // "12.345,67" (máscara do form) → 12345.67; fluxos sem campo de
        // valor enviam 0.
        valor: _showValor ? (parseCurrency(_valorController.text) ?? 0) : 0,
        // kmentrada fica nulo: o pneu está saindo de uma localização,
        // não de um veículo — não há KM envolvido.
        codMotivoSucat:
            _showMotivoSucateamento ? _motivoSucateamento?.codigo : null,
        cgcCpfForne:
            _showFornecedorRecap ? _selectedFornecedor?.cgcCpf : null,
        motivoSaida: motivoTexto.isEmpty ? null : motivoTexto,
        client: widget.client,
        // O switch "Proibido futura recauchutagem" não é enviado: o backend
        // confirmou que esse endpoint não recebe essa informação.
      );
      if (!mounted) return;
      showSuccessToast(
        mensagem.isNotEmpty
            ? mensagem
            : 'Pneu ${_selectedPneu!.nroPneu} movido para '
                '${widget.destino.label}',
      );
      // Sinaliza sucesso ao chamador (contrato `pop != null` = confirmado);
      // cancelar/fechar continuam passando null implícito.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      // Mantém o sheet aberto para o usuário corrigir/tentar de novo
      // sem perder o que já digitou.
      setState(() => _enviando = false);
      showErrorToast(friendlyError(e));
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final destino = widget.destino;

    final content = Padding(
      padding: EdgeInsets.only(
        // Tablet roda em Dialog centralizado, não precisa subir pro teclado.
        bottom: widget.isTablet ? 0 : MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: faixa colorida com destino.bgColor em ambos os modos.
              // Mobile = 95pt com drag handle (conteúdo a top:55), tablet =
              // 76pt sem drag handle (conteúdo a top:36, em linha com o
              // padding-top dos outros dialogs do projeto).
              if (widget.isTablet)
                Container(
                  width: double.infinity,
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(color: destino.bgColor),
                  alignment: Alignment.centerLeft,
                  child: _buildHeaderRow(),
                )
              else
                Container(
                  width: double.infinity,
                  height: 95,
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  decoration: BoxDecoration(color: destino.bgColor),
                  child: Stack(
                    children: [
                      // Drag handle: 130×5, #9B9B9B, radius 5, centralizado
                      // horizontalmente e a 22pt do topo do sheet.
                      Positioned(
                        top: 22,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 130,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.textSubtle,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                      // Conteúdo do header a 55pt do topo (= 22 do handle +
                      // 5 da altura dele + 28 de gap).
                      Positioned(
                        top: 55,
                        left: 0,
                        right: 0,
                        child: _buildHeaderRow(),
                      ),
                    ],
                  ),
                ),
              // Formulário
              Flexible(
                child: SingleChildScrollView(
                  // Arrastar o formulário pra baixo fecha o teclado. Útil
                  // sobretudo no Valor: o teclado numérico do iOS não tem
                  // tecla "OK".
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    widget.isTablet ? 40 : 33,
                    widget.isTablet ? 30 : 27,
                    widget.isTablet ? 40 : 33,
                    8,
                  ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPneuPicker(),
                    const SizedBox(height: 29),
                    FieldLabel(_dataLabel),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _dataController,
                      readOnly: true,
                      onTap: _pickDate,
                      style: AppTextStyles.inputText,
                      decoration: formInputDecoration(
                        hint: 'DD/MM/AAAA',
                        suffix: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: destino.borderColor ?? destino.color,
                        ),
                        borderColor: destino.borderColor ?? destino.color,
                      ),
                    ),
                    if (_showValor) ...[
                      const SizedBox(height: 29),
                      FieldLabel(_valorLabel),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: _valorController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [BrazilianCurrencyFormatter()],
                        style: AppTextStyles.inputText,
                        decoration: formInputDecoration(
                          hint: '0,00',
                          borderColor: destino.borderColor ?? destino.color,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Informe o valor' : null,
                      ),
                    ],
                    if (_showFornecedorRecap) ...[
                      const SizedBox(height: 29),
                      FieldLabel('Fornecedor de Recauchutagem'),
                      const SizedBox(height: 7),
                      _buildFornecedorField(),
                    ],
                    if (_showFlagProibidoRecap) ...[
                      const SizedBox(height: 29),
                      _buildSwitch(
                        label: 'Proibido futura recauchutagem',
                        value: _proibidoFuturaRecap,
                        onChanged: (v) =>
                            setState(() => _proibidoFuturaRecap = v),
                      ),
                    ],
                    if (_showMotivoSucateamento) ...[
                      const SizedBox(height: 29),
                      FieldLabel('Motivo de Sucateamento'),
                      const SizedBox(height: 7),
                      _buildMotivoField(),
                    ],
                    if (_showMotivo) ...[
                      const SizedBox(height: 29),
                      FieldLabel('Motivo'),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: _motivoController,
                        style: AppTextStyles.inputText,
                        decoration: formInputDecoration(
                          hint: 'Descreva o motivo',
                          borderColor: destino.borderColor ?? destino.color,
                        ),
                      ),
                    ],
                    if (_showObservacao) ...[
                      const SizedBox(height: 29),
                      FieldLabel('Observação'),
                      const SizedBox(height: 7),
                      SizedBox(
                        height: 90,
                        child: TextFormField(
                          controller: _observacaoController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: AppTextStyles.inputText,
                          decoration: formInputDecoration(
                            hint: 'Observações (opcional)',
                            borderColor: destino.borderColor ?? destino.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
              // Barra de botões fixa: fora do scroll, sempre visível —
              // inclusive acima do teclado (o Padding(viewInsets.bottom) do
              // build() sobe todo o conteúdo). Antes ela rolava junto e sumia
              // atrás do teclado.
              _buildBotoes(context),
            ],
          ),
          // Botão fechar (X) — só no tablet; mobile fecha via swipe-down.
          // Posição relativa à dialog de 460pt: 460 - 20 - 30 = 410 da esquerda.
          if (widget.isTablet)
            Positioned(
              left: 410,
              top: 30,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Desabilita o "X" durante o envio (mesma intenção do Cancelar).
                onTap: _enviando ? null : () => Navigator.pop(context),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(
                    painter: CloseXPainter(
                      color: AppColors.textMuted,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Bloqueia fechar a sheet (back/swipe/toque fora) enquanto envia — senão a
    // requisição continua e o `if (!mounted) return` engole o sucesso, deixando
    // a UI desatualizada. Navigator.pop explícito (sucesso/X) segue funcionando.
    return PopScope(canPop: !_enviando, child: content);
  }

  // Rodapé fixo com Cancelar/Confirmar, irmão do SingleChildScrollView no
  // Column — não rola com os campos e permanece visível acima do teclado.
  // Padding horizontal igual ao do form (33 mobile / 40 tablet); 16pt de folga
  // até a base do sheet/modal.
  Widget _buildBotoes(BuildContext context) {
    final horizontal = widget.isTablet ? 40.0 : 33.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        16,
        horizontal,
        folgaInferiorBotoes(context, folgaDesign: 16, isTablet: widget.isTablet),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 144,
            height: 56,
            child: OutlinedButton(
              // Durante o envio, cancelar fecharia o sheet com a requisição
              // ainda em andamento — melhor bloquear.
              onPressed: _enviando ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: BorderSide(
                  width: 2,
                  color: AppColors.textPlaceholder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Cancelar',
                textAlign: TextAlign.center,
                style: AppTextStyles.buttonSecondary,
              ),
            ),
          ),
          Container(
            width: 144,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: FilledButton(
              onPressed: _enviando ? null : _confirmar,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                // Mantém a cor cheia enquanto desabilitado no envio, para o
                // spinner não ficar sobre cinza.
                disabledBackgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _enviando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirmar',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Conteúdo "ORIGEM → DESTINO" do header. Reutilizado em mobile (dentro
  /// da faixa colorida com drag handle) e tablet (inline no Dialog colorido).
  Widget _buildHeaderRow() {
    final origem = widget.origem;
    final destino = widget.destino;
    return Row(
      children: [
        // ORIGEM: Montserrat 12 SemiBold uppercase, cor #363636.
        Text(
          origem.label.toUpperCase(),
          style: AppTextStyles.labelNumbers,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.arrow_forward,
            size: 14,
            color: AppColors.textBody,
          ),
        ),
        // Ícone do destino: 24×24, tingido com borderColor.
        SizedBox(
          width: 24,
          height: 24,
          child: Transform.flip(
            flipX: destino.mirrorX,
            child: destino.asset != null
                ? SvgPicture.asset(
                    destino.asset!,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      destino.borderColor ?? destino.color,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    destino.icon,
                    color: destino.borderColor ?? destino.color,
                    size: 24,
                  ),
          ),
        ),
        const SizedBox(width: 6),
        // DESTINO: Montserrat 20 Bold uppercase, cor #363636.
        // Flexible + ellipsis: é o elemento mais largo do header (20px bold);
        // sem isso, combos longos (ex.: RECAPAGEM) estouram em telas estreitas.
        Flexible(
          child: Text(
            destino.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body,
          ),
        ),
      ],
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
        const SizedBox(height: 7),
        InkWell(
          onTap: _selecionarPneu,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 1,
                color: _pneuError ? Colors.red : AppColors.textHint,
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
                    style: _selectedPneu != null
                        ? AppTextStyles.inputText
                        : AppTextStyles.formInputHint,
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

  Widget _buildMotivoField() {
    if (_loadingMotivos) return _loadingBox();
    if (_erroMotivos != null) {
      return _erroRetry(_erroMotivos!, _carregarMotivos);
    }
    final destino = widget.destino;
    return DropdownButtonFormField<MotivoSucateamento>(
      initialValue: _motivoSucateamento,
      isExpanded: true,
      itemHeight: 60,
      style: AppTextStyles.inputText,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(20),
      menuMaxHeight: 570,
      decoration: formInputDecoration(
        hint: 'Selecione o motivo',
        borderColor: destino.borderColor ?? destino.color,
      ),
      // Sem selectedItemBuilder, o DropdownButton reusa o widget do item
      // (o Stack abaixo, que inclui o divisor de 1px) pra exibir o valor
      // selecionado no campo fechado — e a linha aparecia dentro do campo.
      // Aqui renderizamos só o texto no estado fechado.
      selectedItemBuilder: (context) => _motivos
          .map(
            (m) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                m.label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.inputText
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          )
          .toList(),
      items: List.generate(_motivos.length, (i) {
        final m = _motivos[i];
        final isLast = i == _motivos.length - 1;
        return DropdownMenuItem(
          value: m,
          // O DropdownButton aplica EdgeInsets.symmetric(horizontal: 16) em
          // volta de cada item. Pra borda atravessar de ponta a ponta do
          // menu, uso um Stack com Positioned de offset negativo (-16) que
          // "escapa" essa margem.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  m.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inputText
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (!isLast)
                Positioned(
                  left: -16,
                  right: -16,
                  bottom: 0,
                  child: Container(
                    height: 1,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
        );
      }),
      onChanged: (v) => setState(() => _motivoSucateamento = v),
      validator: (v) =>
          v == null ? 'Selecione o motivo de sucateamento' : null,
    );
  }

  Widget _buildFornecedorField() {
    if (_loadingFornecedores) return _loadingBox();
    if (_erroFornecedores != null) {
      return _erroRetry(_erroFornecedores!, _carregarFornecedores);
    }
    // Campo tocável (mesmo padrão do seletor de pneu) que abre um bottom sheet
    // com busca — a lista de fornecedores é grande demais pra um dropdown.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _selecionarFornecedor,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              // Borda na cor do destino (recapagem = roxo #7D00DE), igual aos
              // demais campos temáticos do form; vermelha quando há erro.
              border: Border.all(
                width: 2,
                color: _fornecedorError
                    ? Colors.red
                    : (widget.destino.borderColor ?? widget.destino.color),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFornecedor != null
                        ? _nomeFornecedor(_selectedFornecedor!)
                        : 'Selecione o fornecedor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _selectedFornecedor != null
                        ? AppTextStyles.inputText
                        : AppTextStyles.formInputHint,
                  ),
                ),
                Icon(Icons.search, size: 18, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
        if (_fornecedorError) ...[
          const SizedBox(height: 4),
          const Text(
            'Selecione o fornecedor',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _loadingBox() {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _erroRetry(String mensagem, VoidCallback onRetry) {
    return Row(
      children: [
        Expanded(
          child: Text(
            mensagem,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}

/// Bottom sheet de seleção de fornecedor com busca. Recebe a lista já
/// ordenada e filtra por razão social / nome fantasia conforme o usuário
/// digita — pensado para listas grandes, onde um dropdown seria inviável.
/// Retorna o [Fornecedor] escolhido via [Navigator.pop] (ou null se fechado).
class _FornecedorPickerSheet extends StatefulWidget {
  final List<Fornecedor> fornecedores;
  final Fornecedor? selecionado;

  const _FornecedorPickerSheet({
    required this.fornecedores,
    required this.selecionado,
  });

  @override
  State<_FornecedorPickerSheet> createState() => _FornecedorPickerSheetState();
}

class _FornecedorPickerSheetState extends State<_FornecedorPickerSheet> {
  final _buscaController = TextEditingController();
  late List<Fornecedor> _filtrados;

  @override
  void initState() {
    super.initState();
    _filtrados = widget.fornecedores;
    // Refiltra a lista a cada tecla digitada na busca.
    _buscaController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrar() {
    final q = _buscaController.text.trim().toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? widget.fornecedores
          : widget.fornecedores
              .where((f) =>
                  f.razaoSocial.toLowerCase().contains(q) ||
                  f.nomeFantasia.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Ocupa 85% da tela, descontando o teclado quando aberto pra que a busca
    // e a lista continuem visíveis sem estourar a altura do sheet.
    final altura = (media.size.height * 0.85 - media.viewInsets.bottom)
        .clamp(240.0, media.size.height)
        .toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: altura,
        child: Column(
          children: [
            // Drag handle.
            Container(
              width: 130,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.textSubtle,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: TextField(
                controller: _buscaController,
                autofocus: true,
                style: AppTextStyles.inputText,
                decoration: formInputDecoration(
                  hint: 'Buscar fornecedor',
                  suffix:
                      Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                ),
              ),
            ),
            Expanded(
              child: _filtrados.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum fornecedor encontrado',
                        style: AppTextStyles.formInputHint,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtrados.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.textHint,
                      ),
                      itemBuilder: (context, i) {
                        final f = _filtrados[i];
                        final selecionado = f == widget.selecionado;
                        // Só mostra o nome fantasia como subtítulo quando o
                        // título é a razão social (senão duplicaria a linha).
                        final mostrarFantasia =
                            f.razaoSocial.isNotEmpty && f.nomeFantasia.isNotEmpty;
                        return ListTile(
                          title: Text(
                            _nomeFornecedor(f),
                            style: AppTextStyles.inputText
                                .copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: mostrarFantasia
                              ? Text(
                                  f.nomeFantasia,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: selecionado
                              ? const Icon(Icons.check,
                                  color: AppColors.primary)
                              : null,
                          onTap: () => Navigator.pop(context, f),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
