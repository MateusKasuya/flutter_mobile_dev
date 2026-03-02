import 'package:flutter/material.dart';
import '../models/localizacao.dart';
import '../services/localizacao_service.dart';
import '../utils/app_toast.dart';

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
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: _localizacoes
              .map((loc) => _LocalizacaoCard(localizacao: loc))
              .toList(), 
          ),
        ),
    );
  }
}

class _LocalizacaoCard extends StatelessWidget {
  final Localizacao localizacao;

  const _LocalizacaoCard({required this.localizacao});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${localizacao.quantidade}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              
            ),
            const SizedBox(height: 8),
            Text(
              localizacao.nome,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
