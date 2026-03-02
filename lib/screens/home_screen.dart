import 'package:flutter/material.dart';
import '../models/localizacao.dart';
import '../services/localizacao_service.dart';
import '../utils/app_toast.dart';
import 'movimento_screen.dart';

const _localizacaoIcons = <String, IconData>{
  'ESTOQUE': Icons.inventory,
  'FROTA': Icons.local_shipping,
  'SUCATA': Icons.recycling,
  'VENDA': Icons.sell,
  'CONSERTO': Icons.build,
};

class HomeScreen extends StatefulWidget {
  final String token;
  final Future<List<Localizacao>> Function(String token) fetchFn;

  const HomeScreen({
    super.key,
    required this.token,
    this.fetchFn = fetchLocalizacoes
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
      final data = await widget.fetchFn(widget.token);
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
      appBar: AppBar(),
      //backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: _localizacoes
              .map((loc) => _LocalizacaoCard(localizacao: loc))
              .toList(), 
          ),
        ),
        floatingActionButton: Transform.scale(
          scale: 1.2,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovimentoScreen()),
              );
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Movimento'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
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
    final primary = Theme.of(context).colorScheme.primary;
    final icon = _localizacaoIcons[localizacao.nome] ?? Icons.help_outline;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 6,
            color: primary,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizacao.quantidade}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizacao.nome,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
