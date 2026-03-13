---
tags: [tipo/task, dominio/movimento, dominio/estilizacao]
date: 2026-03-05
status: concluída
branch: feat/estilizacao-movimento
---

# Task — Estilizacao do Movimento

[[Tasks/_index|Tasks]]

---

## Contexto

O Figma mostra a tela "Adicionar movimento" com visual completamente diferente do atual. Os cards atuais sao brancos com barra lateral colorida. No Figma, os cards sao preenchidos com fundo teal solido, ocupam toda a largura, com icone branco, label grande branco, subtitulo branco e seta branca. O AppBar mostra "Adicionar movimento" com seta de voltar.

## Objetivo

MovimentoScreen estilizada conforme o Figma: AppBar com titulo, cards teal de largura total com texto branco.

---

## Branch

```bash
git checkout -b feat/estilizacao-movimento
```

## Arquivos a criar

- *(nenhum)*

## Arquivos a modificar

- `lib/screens/movimento_screen.dart`

---

## Implementacao

### Passo 1 — Atualizar AppBar

Modificar o `AppBar` para exibir o titulo:

```dart
appBar: AppBar(
  title: const Text('Adicionar movimento'),
),
```

**Explicacao:**

- **Titulo no AppBar** — o Figma mostra "Adicionar movimento" como titulo. A seta de voltar aparece automaticamente quando a tela foi aberta via `Navigator.push` (o Flutter adiciona o `BackButton` automatico).

---

### Passo 2 — Reestilizar _MovimentoCard com fundo teal

Substituir completamente o widget `_MovimentoCard`:

```dart
class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Card(
        elevation: 2,
        color: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 36, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Explicacoes:**

- **`color: primary`** — o card inteiro tem fundo teal, em vez de branco com barra lateral. Mudanca visual mais significativa em relacao ao design anterior.

- **`Colors.white` para textos e icones** — sobre fundo teal escuro, todo o conteudo eh branco para garantir contraste e legibilidade.

- **`Colors.white70`** — branco com 70% de opacidade para o subtitulo. Cria hierarquia visual (titulo = branco puro, subtitulo = branco suave) sem precisar de outra cor.

- **`subtitle.toUpperCase()`** — o Figma mostra os subtitulos em maiusculo ("MOVIMENTACOES DE FROTA"). O `toUpperCase()` converte em runtime.

- **`letterSpacing: 0.5`** — espacamento extra entre letras no subtitulo. Texto em maiusculo fica mais legivel com um pouco mais de espaco entre caracteres.

- **`Icons.chevron_right`** — seta mais grossa que `arrow_forward_ios`, consistente com o Figma que mostra uma seta ">" proeminente.

- **`borderRadius: 16`** — cantos mais arredondados (era 12), alinhando com o estilo geral do Figma.

- **`fontSize: 20` no label** — texto maior que antes (era 16), dando mais destaque ao nome do modulo conforme o design.

---

### Passo 3 — Estado final do arquivo completo

```dart
import 'package:flutter/material.dart';

import 'frota_busca_screen.dart';

class MovimentoScreen extends StatelessWidget {
  final String token;

  const MovimentoScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar movimento'),
      ),
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
            label: 'Pneus',
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

class _MovimentoCard extends StatelessWidget {
  const _MovimentoCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Card(
        elevation: 2,
        color: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 36, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Nota:** este estado final assume que as tasks de Frota ja foram executadas (token no construtor, import do `frota_busca_screen.dart`, `onTap` no card Frotas). Se esta task for executada antes, ajustar conforme o estado real do codigo no momento.

---

## Criterios de aceite

- [ ] AppBar com titulo "Adicionar movimento" e seta de voltar automatica
- [ ] Cards com fundo teal solido, ocupando toda a largura
- [ ] Icones, labels e subtitulos em branco
- [ ] Subtitulos em maiusculo
- [ ] Seta `chevron_right` branca no lado direito
- [ ] Cantos arredondados (16px)
- [ ] InkWell com ripple funcionando
- [ ] Funcionalidade de navegacao inalterada
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-estilizacao-home|Estilizacao da Home]]
- [[DevLog/]]
