import 'package:flutter/material.dart';
import 'package:frota_facil_mobile/theme/app_colors.dart';
import 'package:frota_facil_mobile/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/localizacao.dart';
import '../providers/auth_provider.dart';
import '../services/localizacao_service.dart';
import '../utils/app_toast.dart';
import 'movimento_screen.dart';

const _localizacaoIcons = <String, String>{
  'ESTOQUE': 'assets/estoque.svg',
  'FROTA': 'assets/frota.svg',
  'SUCATA': 'assets/sucata.svg',
  'VENDA': 'assets/venda.svg',
  'CONSERTO': 'assets/conserto.svg',
  'RECAPAGEM': 'assets/recapagem.svg',
};

class HomeScreen extends StatefulWidget {
  final Future<List<Localizacao>> Function(String token) fetchFn;

  const HomeScreen({
    super.key,
    this.fetchFn = fetchLocalizacoes,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Acima dessa largura, renderizamos o layout de tablet.
  static const double _tabletBreakpoint = 600;

  List<Localizacao> _localizacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState(); 
    _load();
  }

  Future<void> _load() async {
    try {
      final token = context.read<AuthProvider>().token;
      final data = await widget.fetchFn(token);
      if (!mounted) return;
      setState(() {
        _localizacoes = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorToast(e.toString().replaceFirst('Exception: ', ''));
    }
  }


  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= _tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 91,
        backgroundColor: Colors.white,
        title: SvgPicture.asset(
              'assets/logo_horizontal.svg',
              height: 24,
              width: 155.74,
        ),
        centerTitle: isTablet,
        titleSpacing: isTablet ? 0 : 28,
      ),
      backgroundColor: AppColors.backgroundScreen,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 0 : 80),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isTablet
                              ? 'Monitoramento de movimentações da Frota'
                              : 'Monitoramento de\nmovimentações da Frota',
                          style: isTablet
                              ? AppTextStyles.body.copyWith(fontSize: 24)
                              : AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 26),
                        isTablet ? _buildTabletGrid() : _buildPhoneGrid(),
                        if (isTablet) ...[
                          const SizedBox(height: 100),
                          _buildAddButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      floatingActionButton: isTablet ? null : _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: 300,
      height: 56,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MovimentoScreen()),
          );
        },
        icon: SvgPicture.asset('assets/mais-icon.svg'),
        label: Text('Adicionar Movimento', style: AppTextStyles.labelFloatButton),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(56),
        ),
      ),
    );
  }

  Widget _buildPhoneGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.785,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _localizacoes
            .map((loc) => _LocalizacaoCard(localizacao: loc))
            .toList(),
      ),
    );
  }

  Widget _buildTabletGrid() {
    // Cards 200x214, spacing 16, 3 colunas e 2 linhas:
    // largura total = 3*200 + 2*16 = 632
    // altura total  = 2*214 + 1*16 = 444
    // ratio         = 200 / 214 ≈ 0.9346
    return SizedBox(
      width: 632,
      height: 444,
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 200 / 214,
        physics: const NeverScrollableScrollPhysics(),
        children: _localizacoes
            .map((loc) => _LocalizacaoCard(localizacao: loc, isTablet: true))
            .toList(),
      ),
    );
  }
}

class _LocalizacaoCard extends StatelessWidget {
  final Localizacao localizacao;
  final bool isTablet;

  const _LocalizacaoCard({
    required this.localizacao,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final svgPath = _localizacaoIcons[localizacao.nome];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 1,
          color: const Color(0xFFC4C4C4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (svgPath != null)
            SvgPicture.asset(
              svgPath,
              width: isTablet ? 37 : null,
              height: isTablet ? 37 : null,
            )
          else
            const Icon(Icons.help_outline, size: 24),
          const SizedBox(height: 8),
          Text(
            '${localizacao.quantidade}',
            style: isTablet
                ? AppTextStyles.bigNumbers.copyWith(fontSize: 40)
                : AppTextStyles.bigNumbers,
          ),
          const SizedBox(height: 4),
          Text(
            localizacao.nome,
            style: isTablet
                ? AppTextStyles.labelNumbers.copyWith(fontSize: 14)
                : AppTextStyles.labelNumbers,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
