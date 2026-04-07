import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/pneu_acoes_dialog.dart';
import '../models/pneu.dart';
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
        return 'Novo';
      case 'U':
        return 'Usado';
      case 'R':
        return 'Recapado';
      case 'S':
        return 'Sucata';
      default:
        return situacao;
    }
  }

  Color _situacaoColor(String situacao) {
    switch (situacao.toUpperCase()) {
      case 'N':
        return Colors.green;
      case 'U':
        return Colors.orange;
      case 'R':
        return Colors.blue;
      case 'S':
        return Colors.red;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 91,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.title,
          style: AppTextStyles.labelBar,
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: AppColors.backgroundScreen,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por marca, modelo, placa...',
                hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'Nenhum pneu encontrado para o filtro'
              : 'Nenhum pneu cadastrado',
          style: AppTextStyles.label,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarPneus,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _filteredPneus.length,
        itemBuilder: (context, index) {
          final pneu = _filteredPneus[index];
          return _PneuCard(
            pneu: pneu,
            situacaoLabel: _situacaoLabel(pneu.situacao),
            situacaoColor: _situacaoColor(pneu.situacao),
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
    required this.onTap,
  });

  final Pneu pneu;
  final String situacaoLabel;
  final Color situacaoColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nro pneu + situação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pneu #${pneu.nroPneu}',
                  style: AppTextStyles.body.copyWith(fontSize: 16),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: situacaoColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    situacaoLabel,
                    style: AppTextStyles.labelNumbers.copyWith(
                      color: situacaoColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Marca / Modelo
            Text(
              '${pneu.marca} ${pneu.modelo}',
              style: AppTextStyles.label.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            // Dimensão e Tipo
            Text(
              '${pneu.dimensao} - ${pneu.tipo}',
              style: AppTextStyles.footer.copyWith(fontSize: 12),
            ),
            const Divider(height: 20),
            // Info row
            Row(
              children: [
                _infoChip(Icons.directions_car, pneu.placa),
                const SizedBox(width: 16),
                _infoChip(Icons.tag, 'Frota ${pneu.nroFrota}'),
                const SizedBox(width: 16),
                _infoChip(Icons.settings, pneu.localEixo),
              ],
            ),
            if (pneu.localizacao.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _infoChip(Icons.location_on, pneu.localizacao),
                ],
              ),
            ],
            if (pneu.nroSerie.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _infoChip(Icons.qr_code, 'Série: ${pneu.nroSerie}'),
                ],
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.footer.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
