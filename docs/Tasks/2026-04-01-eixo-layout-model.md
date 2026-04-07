---
tags: [tipo/task, dominio/frota]
date: 2026-04-01
status: planejada
branch: feat/eixo-layout-model
---

# Task — Modelo Eixo e parser de LOCALEIXO

[[Tasks/_index|Tasks]]

---

## Contexto

Para montar o diagrama visual de eixos, precisamos transformar a lista plana de `Pneu` (cada um com seu `localEixo`) em uma estrutura organizada por eixo. O campo `LOCALEIXO` da API codifica a posição do pneu no veículo:

- `1D` → Eixo 1, Direito (rodado simples)
- `1E` → Eixo 1, Esquerdo (rodado simples)
- `2DE` → Eixo 2, Direito Externo (rodado duplo)
- `2DI` → Eixo 2, Direito Interno (rodado duplo)
- `2EE` → Eixo 2, Esquerdo Externo (rodado duplo)
- `2EI` → Eixo 2, Esquerdo Interno (rodado duplo)

Padrão: `{nro_eixo}{lado}{posição_opcional}` — o primeiro caractere é o número do eixo, seguido de D/E para lado, e opcionalmente I/E para interno/externo em rodado duplo.

## Objetivo

Criar o model `Eixo` e uma função `buildEixoLayout` que recebe `List<Pneu>` e retorna `List<Eixo>` organizada por número do eixo, com cada pneu mapeado à sua posição correta.

---

## Branch

```bash
git checkout -b feat/eixo-layout-model
```

## Arquivos a criar

- `lib/models/eixo.dart` — classe `Eixo`
- `lib/utils/eixo_utils.dart` — função `buildEixoLayout`

## Arquivos a modificar

- *(nenhum)*

---

## Implementação

### Passo 1 — Criar o model `Eixo`

Criar `lib/models/eixo.dart`:

```dart
import 'pneu.dart';

/// Representa um eixo do veículo com seus pneus posicionados.
///
/// Para rodado simples (ex: eixo dianteiro), apenas [esquerdoExterno]
/// e [direitoExterno] são preenchidos.
/// Para rodado duplo (ex: eixo traseiro), os quatro campos podem
/// ser preenchidos.
class Eixo {
  final int numero;
  final Pneu? esquerdoExterno;
  final Pneu? esquerdoInterno;
  final Pneu? direitoExterno;
  final Pneu? direitoInterno;

  const Eixo({
    required this.numero,
    this.esquerdoExterno,
    this.esquerdoInterno,
    this.direitoExterno,
    this.direitoInterno,
  });

  /// Retorna `true` se o eixo possui rodado duplo (2 pneus de cada lado).
  bool get rodadoDuplo => esquerdoInterno != null || direitoInterno != null;
}
```

**Explicações:**

- **Quatro campos opcionais (`Pneu?`)** — em vez de listas ou mapas, usamos campos nomeados para cada posição possível. Isso torna o acesso direto e sem casting: `eixo.direitoExterno` em vez de `eixo.pneus['DE']`.

- **Rodado simples vs duplo** — no rodado simples (ex: eixo dianteiro de um TOCO), só existem 2 pneus: esquerdo e direito. Eles são armazenados em `esquerdoExterno` e `direitoExterno`. Os campos `*Interno` ficam `null`.

- **`rodadoDuplo` como getter** — propriedade derivada: se qualquer campo `*Interno` tem pneu, o eixo é duplo. Evita armazenar estado redundante.

---

### Passo 2 — Criar `buildEixoLayout`

Criar `lib/utils/eixo_utils.dart`:

```dart
import '../models/eixo.dart';
import '../models/pneu.dart';

/// Organiza uma lista de [Pneu] em [Eixo]s a partir do campo [localEixo].
///
/// O [localEixo] segue o padrão `{eixo}{lado}{posição}`:
/// - `1D` → Eixo 1, Direito (simples)
/// - `2EI` → Eixo 2, Esquerdo Interno (duplo)
///
/// Pneus com [localEixo] vazio são ignorados.
/// O resultado é ordenado por número do eixo (1, 2, 3...).
List<Eixo> buildEixoLayout(List<Pneu> pneus) {
  final Map<int, Map<String, Pneu>> eixoMap = {};

  for (final pneu in pneus) {
    if (pneu.localEixo.isEmpty) continue;

    final numero = int.parse(pneu.localEixo[0]);
    final posicao = pneu.localEixo.substring(1); // "D", "E", "DE", "DI", "EE", "EI"

    eixoMap.putIfAbsent(numero, () => {});
    eixoMap[numero]![posicao] = pneu;
  }

  return eixoMap.entries.map((entry) {
    final p = entry.value;
    return Eixo(
      numero: entry.key,
      esquerdoExterno: p['EE'] ?? p['E'],
      esquerdoInterno: p['EI'],
      direitoExterno: p['DE'] ?? p['D'],
      direitoInterno: p['DI'],
    );
  }).toList()
    ..sort((a, b) => a.numero.compareTo(b.numero));
}
```

**Explicações:**

- **`pneu.localEixo[0]`** — o primeiro caractere é sempre o número do eixo. `int.parse` converte "1" ou "2" para inteiro.

- **`pneu.localEixo.substring(1)`** — o resto da string identifica a posição: "D" (direito simples), "EE" (esquerdo externo), etc. Usamos essa string como chave no mapa.

- **`p['EE'] ?? p['E']`** — para rodado simples, a chave é apenas "E" (esquerdo). Para duplo, a chave é "EE" (esquerdo externo). O `??` faz o fallback: primeiro tenta "EE", se não existir usa "E". Assim o mesmo código funciona para ambos os tipos sem if/else.

- **`Map<int, Map<String, Pneu>>`** — mapa de dois níveis: primeiro agrupa por eixo (1, 2...), depois por posição ("D", "EE", "DI"...). Permite iterar por eixo e acessar pneus por posição.

- **`..sort()`** — cascade operator. Ordena a lista in-place e retorna ela mesma, permitindo encadear com o `return`.

---

## Critérios de aceite

- [ ] `lib/models/eixo.dart` criado com a classe `Eixo`
- [ ] `lib/utils/eixo_utils.dart` criado com `buildEixoLayout`
- [ ] Mapeia corretamente rodado simples ("1D", "1E")
- [ ] Mapeia corretamente rodado duplo ("2DE", "2DI", "2EE", "2EI")
- [ ] Ignora pneus com `localEixo` vazio
- [ ] Resultado ordenado por número do eixo
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-04-01-diagrama-eixos-widget|Widget do diagrama de eixos]]
- [[DevLog/]]
