---
tags: [tipo/task, dominio/home]
date: 2026-03-02
status: concluída
branch: feat/home-grid-localizacoes
---

# Task — Home Screen com GridView de localizações

[[Tasks/_index|Tasks]]

---

## Contexto

Após o login, o app exibia uma Home Screen placeholder que apenas mostrava o token. Precisamos transformá-la numa tela funcional que consome o serviço de localizações e exibe a distribuição de pneus num grid 2x2.

## Objetivo

Home Screen que carrega dados do serviço de localizações e exibe 4 cards em GridView 2x2 com nome e quantidade.

---

## Branch

```bash
git checkout -b feat/home-grid-localizacoes
```

## Arquivos a criar

- Nenhum

## Arquivos a modificar

- `lib/screens/home_screen.dart` — reescrever completamente

---

## Implementação

> **Pré-requisito:** Task [[Tasks/2026-03-02-localizacao-service|Modelo e serviço de localizações]] concluída.

### Passo 1 — Reescrever `HomeScreen` como StatefulWidget

Substituir o conteúdo de `lib/screens/home_screen.dart`:

```dart
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
```

### Passo 2 — Implementar o `build` com loading e GridView

```dart
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
```

`childAspectRatio: 1.5` controla a proporção largura/altura de cada célula do grid — valor acima de 1.0 deixa os cards mais largos do que altos.

### Passo 3 — Criar o widget `_LocalizacaoCard` com estilização

Adicionar abaixo de `_HomeScreenState`, no mesmo arquivo:

```dart
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
```

- Quantidade exibida com `headlineMedium` bold na cor primária do tema (`#028687`)
- Nome exibido com `titleMedium` na cor secundária do tema
- Ambas as cores vêm do `AppTheme`, sem hardcode

---

## Observação — Path do endpoint

Durante a execução foi identificado que o path correto é `/api-frota/pneu/qlocalizacaopneus` (com hífen), não `/api/frota/...`. O `localizacao_service.dart` foi corrigido nesta task.

Ver [[Bugs/2026-03-02-404-endpoint-path|404 ao chamar endpoint de localizações]].

---

## Critérios de aceite

- [x] Home Screen carrega dados do endpoint ao abrir
- [x] Exibe `CircularProgressIndicator` centralizado enquanto busca dados
- [x] GridView 2x2 exibe os 4 cards com nome e quantidade
- [x] Quantidade em destaque com a cor primária do tema
- [x] Nome do card com cor secundária do tema
- [x] Tratamento de erro com toast em caso de falha na API
- [x] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-02-localizacao-service|Modelo e serviço de localizações]]
- [[Bugs/2026-03-02-404-endpoint-path|404 ao chamar endpoint de localizações]]
- [[DevLog/2026-03-02-home-grid-localizacoes]]
- [[Decisoes/]]
