import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../components/pneu_acoes_dialog.dart';
import '../models/pneu.dart';
import '../models/pneu_acao.dart';
import '../providers/auth_provider.dart';
import '../services/pneu_service.dart' as pneu_service;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PneuListaScreen extends StatefulWidget {
  final Future<List<Pneu>> Function(String token) fetchFn;
  final bool selectionMode;
  final String title;

  const PneuListaScreen({
    super.key,
    this.fetchFn = _defaultFetch,
    this.selectionMode = false,
    this.title = 'Pneus',
  });

  static Future<List<Pneu>> _defaultFetch(String token) =>
      pneu_service.fetchPneus(token);

  @override
  State<PneuListaScreen> createState() => _PneuListaScreenState();
}

class _PneuListaScreenState extends State<PneuListaScreen> {
  // Acima dessa largura, renderizamos o layout de tablet.
  static const double _tabletBreakpoint = 600;

  final _searchController = TextEditingController();
  List<Pneu> _pneus = [];
  List<Pneu> _filteredPneus = [];
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPneus();
    _searchController.addListener(_aplicarFiltro);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarPneus() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final token = context.read<AuthProvider>().token;
      final pneus = await widget.fetchFn(token);
      if (!mounted) return;
      setState(() {
        _pneus = pneus;
        _filteredPneus = pneus;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltro() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPneus = _pneus;
      } else {
        _filteredPneus = _pneus.where((p) {
          return p.nroPneu.toLowerCase().contains(query) ||
              p.marca.toLowerCase().contains(query) ||
              p.modelo.toLowerCase().contains(query) ||
              p.placa.toLowerCase().contains(query) ||
              p.nroFrota.toLowerCase().contains(query) ||
              p.nroSerie.toLowerCase().contains(query) ||
              p.situacao.toLowerCase().contains(query) ||
              p.tipo.toLowerCase().contains(query) ||
              p.localizacao.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _situacaoLabel(String situacao) {
    switch (situacao.toUpperCase()) {
      case 'N':
        return 'NOVO';
      case 'U':
        return 'USADO';
      case 'R':
        return 'RECAPADO';
      case 'S':
        return 'SUCATA';
      default:
        return situacao.toUpperCase();
    }
  }

  Color _situacaoColor(String situacao) {
    switch (situacao.toUpperCase()) {
      case 'N':
        return const Color(0xFF00AF3E);
      case 'U':
        return const Color(0xFFFF8126);
      case 'R':
        return const Color(0xFF7D00DE);
      case 'S':
        return const Color(0xFFF03E26);
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= _tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: isTablet
            ? SvgPicture.asset(
                'assets/logo_horizontal.svg',
                height: 22,
                width: 177.17,
              )
            : Text(
                widget.title,
                style: AppTextStyles.labelBar,
                textAlign: TextAlign.center,
              ),
      ),
      backgroundColor: AppColors.backgroundScreen,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
            padding: EdgeInsets.fromLTRB(isTablet ? 47 : 28, isTablet ? 36 : 21, isTablet ? 47 : 28, isTablet ? 40 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTablet) ...[
                  Text(widget.title, style: AppTextStyles.screenTitleTablet),
                  const SizedBox(height: 13),
                ],
                Text('Buscar pneu', style: AppTextStyles.sublabelForm),
                const SizedBox(height: 8),
                SizedBox(
                  width: isTablet ? 740 : double.infinity,
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTextStyles.sublabelForm,
                    decoration: InputDecoration(
                      hintText: 'marca, modelo, placa ...',
                      hintStyle: AppTextStyles.formInputHint,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 14),
                        child: SvgPicture.asset(
                          'assets/busca.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchController.clear(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            )
                          : null,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color(0xFF959595),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color(0xFF959595),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color(0xFF959595),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
              Expanded(child: _buildBody()),
            ],
          ),
          if (!_isLoading && _erro == null && _filteredPneus.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(child: _buildEmptyState()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFilterEmpty = _searchController.text.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFilterEmpty) ...[
          SvgPicture.asset(
            'assets/busca_nao_encontrada.svg',
            width: 52,
            height: 52,
          ),
          const SizedBox(height: 21),
        ],
        Text(
          isFilterEmpty
              ? 'Nenhum pneu encontrado\npara o filtro'
              : 'Nenhum pneu cadastrado',
          style: AppTextStyles.label.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBody() {
    final isTablet = MediaQuery.of(context).size.width >= _tabletBreakpoint;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarPneus,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredPneus.isEmpty) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _carregarPneus,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(isTablet ? 47 : 28, 0, isTablet ? 47 : 28, 16),
        itemCount: _filteredPneus.length,
        itemBuilder: (context, index) {
          final pneu = _filteredPneus[index];
          return _PneuCard(
            pneu: pneu,
            situacaoLabel: _situacaoLabel(pneu.situacao),
            situacaoColor: _situacaoColor(pneu.situacao),
            isTablet: isTablet,
            onTap: widget.selectionMode
                ? () => Navigator.pop(context, pneu)
                : () => showPneuAcoesDialog(context, pneu),
          );
        },
      ),
    );
  }
}

class _PneuCard extends StatelessWidget {
  const _PneuCard({
    required this.pneu,
    required this.situacaoLabel,
    required this.situacaoColor,
    required this.isTablet,
    required this.onTap,
  });

  final Pneu pneu;
  final String situacaoLabel;
  final Color situacaoColor;
  final bool isTablet;
  final VoidCallback onTap;

  Color _headerColor() {
    try {
      final acao = PneuAcao.values.firstWhere(
        (a) => a.label.toUpperCase() == pneu.localizacao.toUpperCase(),
      );
      return acao.borderColor ?? AppColors.textBody;
    } catch (_) {
      return AppColors.textBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 10),
            blurRadius: 40,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFC4C4C4), width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: isTablet ? 154 : 200,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 15, 0),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nro pneu + situação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pneu #${pneu.nroPneu}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _headerColor(),
                  ),
                ),
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: situacaoColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    situacaoLabel,
                    style: AppTextStyles.labelNumbers.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '${pneu.marca} ${pneu.modelo}'.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${pneu.dimensao} - ${pneu.tipo}'.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 17),
            Divider(height: 2, thickness: 2, color: _headerColor()),
            const SizedBox(height: 18),
            if (isTablet)
              Row(
                children: [
                  Expanded(child: _placaChip()),
                  Expanded(child: _frotaChip()),
                  Expanded(child: _localizacaoChip()),
                  Expanded(child: _codEsqEixoChip()),
                  Expanded(child: _serieChip()),
                ],
              )
            else ...[
              Row(
                children: [
                  Expanded(child: _placaChip()),
                  Expanded(child: _frotaChip()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _localizacaoChip()),
                  Expanded(child: _codEsqEixoChip()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _serieChip()),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ],
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _infoChip(Widget icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyles.sublabelForm.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _svgIcon(String asset, double size) => SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(_headerColor(), BlendMode.srcIn),
      );

  Widget _placaChip() => _infoChip(_svgIcon('assets/frota.svg', 12), pneu.placa);
  Widget _frotaChip() =>
      _infoChip(_svgIcon('assets/hashtag.svg', 11), 'Frota ${pneu.nroFrota}');
  Widget _localizacaoChip() =>
      _infoChip(_svgIcon('assets/localizacao.svg', 14), pneu.localizacao);
  Widget _codEsqEixoChip() =>
      _infoChip(_svgIcon('assets/engrenagem.svg', 14), pneu.codEsqEixo);
  Widget _serieChip() =>
      _infoChip(_svgIcon('assets/serie.svg', 13), pneu.nroSerie);
}
