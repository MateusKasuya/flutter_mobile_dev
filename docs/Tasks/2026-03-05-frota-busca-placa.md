---
tags: [tipo/task, dominio/frota]
date: 2026-03-05
status: planejada
branch: feat/frota-busca-placa
---

# Task — Tela de busca de veiculo por placa

[[Tasks/_index|Tasks]]

---

## Contexto

O primeiro passo do fluxo de Frota eh o usuario digitar a placa do veiculo para buscar. Esta task cria a `FrotaBuscaScreen` com campo de texto e botao de busca, e conecta a navegacao desde o card "Frotas" na `MovimentoScreen`. O token de autenticacao precisa ser propagado de Home → Movimento → FrotaBusca.

## Objetivo

`FrotaBuscaScreen` funcional com campo de placa, botao buscar, loading durante a chamada, tratamento de erro com toast, e navegacao para `FrotaDetalheScreen` ao encontrar o veiculo.

---

## Branch

```bash
git checkout -b feat/frota-busca-placa
```

## Arquivos a criar

- `lib/screens/frota_busca_screen.dart`
- `lib/screens/frota_detalhe_screen.dart` *(placeholder)*

## Arquivos a modificar

- `lib/screens/movimento_screen.dart` — receber token, navegar para FrotaBuscaScreen
- `lib/screens/home_screen.dart` — passar token para MovimentoScreen

---

## Implementacao

### Passo 1 — Criar FrotaDetalheScreen placeholder

Criar `lib/screens/frota_detalhe_screen.dart` com um placeholder simples. Sera preenchida nas proximas tasks.

```dart
import 'package:flutter/material.dart';

import '../models/veiculo.dart';

class FrotaDetalheScreen extends StatelessWidget {
  final Veiculo veiculo;

  const FrotaDetalheScreen({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(veiculo.placa)),
      body: const Center(child: Text('Detalhes do veiculo')),
    );
  }
}
```

**Explicacoes:**

- **`required this.veiculo`** — a tela de detalhe recebe o objeto `Veiculo` ja carregado. A busca acontece na tela anterior, assim a tela de detalhe nao precisa saber nada sobre a API.

- **Placeholder** — criamos a tela minima agora para que a navegacao funcione. O conteudo sera implementado nas tasks seguintes.

---

### Passo 2 — Criar FrotaBuscaScreen

Criar `lib/screens/frota_busca_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/veiculo.dart';
import '../services/frota_service.dart' as frota_service;
import '../utils/app_toast.dart';
import 'frota_detalhe_screen.dart';

class FrotaBuscaScreen extends StatefulWidget {
  final String token;
  final Future<Veiculo> Function(String token, String placa) fetchFn;

  const FrotaBuscaScreen({
    super.key,
    required this.token,
    this.fetchFn = frota_service.fetchVeiculo,
  });

  @override
  State<FrotaBuscaScreen> createState() => _FrotaBuscaScreenState();
}

class _FrotaBuscaScreenState extends State<FrotaBuscaScreen> {
  final _placaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final veiculo = await widget.fetchFn(
        widget.token,
        _placaController.text.trim().toUpperCase(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FrotaDetalheScreen(veiculo: veiculo),
        ),
      );
    } catch (e) {
      showErrorToast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Veiculo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Placa do veiculo',
                  hintText: 'Ex: ABC1D23',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a placa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _buscar,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Explicacoes:**

- **`fetchFn` como parametro** — mesmo padrao de injecao de dependencia usado no `LoginScreen` e `HomeScreen`. Em producao usa `frota_service.fetchVeiculo`, em testes recebe um mock.

- **`import ... as frota_service`** — import com alias para evitar ambiguidade. Como `fetchVeiculo` eh uma funcao top-level (nao um metodo de classe), o alias deixa claro de onde vem o default do parametro.

- **`textCapitalization: TextCapitalization.characters`** — forca o teclado a exibir letras maiusculas. Placas brasileiras sao em maiusculo, entao facilita a digitacao sem que o usuario precise ativar caps lock.

- **`.trim().toUpperCase()`** — normaliza a entrada antes de enviar para a API. Remove espacos acidentais e garante maiusculo mesmo que `textCapitalization` nao funcione (ex: teclado fisico).

- **`ElevatedButton.icon`** — variante do `ElevatedButton` que aceita um `icon` alem do `label`. Coloca o icone a esquerda do texto automaticamente.

- **`CircularProgressIndicator` dentro do botao** — em vez de um overlay de loading como no login, aqui usamos um indicador inline no proprio botao. O `SizedBox(width: 20, height: 20)` limita o tamanho do spinner para caber no botao. `strokeWidth: 2` deixa a linha mais fina para o tamanho reduzido.

- **`onPressed: _isLoading ? null : _buscar`** — passar `null` desabilita o botao visualmente (fica cinza) e impede cliques durante o loading. Mesmo padrao do login.

---

### Passo 3 — Propagar token para MovimentoScreen

Modificar `lib/screens/movimento_screen.dart` para receber o `token` e navegar para `FrotaBuscaScreen`:

```dart
import 'package:flutter/material.dart';

import 'frota_busca_screen.dart';

class MovimentoScreen extends StatelessWidget {
  final String token;

  const MovimentoScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _MovimentoCard(
            label: 'Frotas',
            subtitle: 'Movimentacoes de frota',
            icon: Icons.directions_car,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FrotaBuscaScreen(token: token),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _MovimentoCard(
            label: 'Pneu',
            subtitle: 'Controle de pneus',
            icon: Icons.tire_repair,
          ),
          const SizedBox(height: 16),
          _MovimentoCard(
            label: 'Abastecimento',
            subtitle: 'Registro de abastecimento',
            icon: Icons.local_gas_station,
          ),
        ],
      ),
    );
  }
}
```

**O que mudou:**

- **`final String token`** — adicionado ao construtor para receber o token de autenticacao.
- **`import 'frota_busca_screen.dart'`** — importar a tela de busca.
- **`onTap` no card Frotas** — navega para `FrotaBuscaScreen` passando o token.

O widget `_MovimentoCard` permanece inalterado (ja aceita `onTap` opcional).

---

### Passo 4 — Passar token de HomeScreen para MovimentoScreen

Modificar `lib/screens/home_screen.dart`, na navegacao do FAB (linha ~78):

**Antes:**
```dart
MaterialPageRoute(builder: (_) => const MovimentoScreen()),
```

**Depois:**
```dart
MaterialPageRoute(builder: (_) => MovimentoScreen(token: widget.token)),
```

Remover tambem o `const` pois agora `MovimentoScreen` recebe um parametro de runtime.

**Explicacao:**

- **`widget.token`** — dentro de um `State`, acessamos as propriedades do `StatefulWidget` via `widget.`. O `HomeScreen` ja recebe o `token` do `LoginScreen`, agora so repassamos adiante.

---

## Criterios de aceite

- [ ] `FrotaBuscaScreen` exibe campo de placa com validacao de campo vazio
- [ ] Botao "Buscar" chama `fetchVeiculo` e navega para `FrotaDetalheScreen` com o resultado
- [ ] Loading inline no botao durante a busca
- [ ] Toast de erro quando veiculo nao encontrado (404) ou erro de API
- [ ] Token propagado: Home → Movimento → FrotaBusca
- [ ] Card "Frotas" no `MovimentoScreen` navega para `FrotaBuscaScreen`
- [ ] `FrotaDetalheScreen` placeholder exibe placa no AppBar
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-service|Service de frota]]
- [[Tasks/2026-03-05-frota-veiculo-card|Card de dados do veiculo]]
- [[DevLog/]]
