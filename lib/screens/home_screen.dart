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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 91,
        backgroundColor: Colors.white,
        title: SvgPicture.asset(
              'assets/logo_horizontal.svg',
              height: 24,
              width: 155.74,
              alignment: AlignmentGeometry.centerLeft,
        ),
        centerTitle: false,
        titleSpacing: 28,
      ),
      backgroundColor: AppColors.backgroundScreen,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Monitoramento de\nmovimentações da Frota',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              Padding(
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
              ),
            ],
          ),
        ),
      floatingActionButton: SizedBox(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _LocalizacaoCard extends StatelessWidget {
  final Localizacao localizacao;

  const _LocalizacaoCard({required this.localizacao});

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
            SvgPicture.asset(svgPath)
          else
            const Icon(Icons.help_outline, size: 24),
          const SizedBox(height: 8),
          Text(
            '${localizacao.quantidade}',
            style: AppTextStyles.bigNumbers,
          ),
          const SizedBox(height: 4),
          Text(
            localizacao.nome,
            style: AppTextStyles.labelNumbers,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
