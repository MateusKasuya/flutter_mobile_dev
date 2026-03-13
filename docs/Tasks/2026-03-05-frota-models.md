---
tags: [tipo/task, dominio/frota]
date: 2026-03-05
status: planejada
branch: feat/frota-models
---

# Task — Models Veiculo e Pneu

[[Tasks/_index|Tasks]]

---

## Contexto

O modulo de Frota consome o endpoint `/veiculo/getveiculo-com-pneus` que retorna um JSON com dados do veiculo e uma lista de pneus. Precisamos de models Dart para deserializar essa resposta antes de criar o service e as telas.

## Objetivo

Dois models (`Veiculo` e `Pneu`) com factory `fromJson`, prontos para uso no service de frota.

---

## Branch

```bash
git checkout -b feat/frota-models
```

## Arquivos a criar

- `lib/models/veiculo.dart`
- `lib/models/pneu.dart`

## Arquivos a modificar

- *(nenhum)*

---

## Implementacao

### Passo 1 — Criar model Pneu

Criar `lib/models/pneu.dart`:

```dart
class Pneu {
  final String nroPneu;
  final String nroSerie;
  final String marca;
  final String modelo;
  final String dimensao;
  final String tipo;
  final String situacao;
  final String localEixo;
  final String codEsqEixo;
  final String localizacao;
  final String nroDot;
  final String indRecapagem;
  final String vidaPneu;
  final String kmRodado;
  final String kmAcumulador;
  final String kmAtuVei;
  final String kmRodado0;
  final String kmRodado1;
  final String kmRodado2;
  final String kmRodado3;
  final String kmRodado4;
  final String kmRodado5;
  final String dataCompra;
  final String dataAtzKm;
  final String codFil;
  final String nroFrota;
  final String placa;

  const Pneu({
    required this.nroPneu,
    required this.nroSerie,
    required this.marca,
    required this.modelo,
    required this.dimensao,
    required this.tipo,
    required this.situacao,
    required this.localEixo,
    required this.codEsqEixo,
    required this.localizacao,
    required this.nroDot,
    required this.indRecapagem,
    required this.vidaPneu,
    required this.kmRodado,
    required this.kmAcumulador,
    required this.kmAtuVei,
    required this.kmRodado0,
    required this.kmRodado1,
    required this.kmRodado2,
    required this.kmRodado3,
    required this.kmRodado4,
    required this.kmRodado5,
    required this.dataCompra,
    required this.dataAtzKm,
    required this.codFil,
    required this.nroFrota,
    required this.placa,
  });

  factory Pneu.fromJson(Map<String, dynamic> json) {
    return Pneu(
      nroPneu: json['NROPNEU'] as String,
      nroSerie: json['NROSERIE'] as String,
      marca: json['MARCA'] as String,
      modelo: json['MODELO'] as String,
      dimensao: json['DIMENSAO'] as String,
      tipo: json['TIPO'] as String,
      situacao: json['SITUACAO'] as String,
      localEixo: json['LOCALEIXO'] as String,
      codEsqEixo: json['CODESQEIXO'] as String,
      localizacao: json['LOCALIZACAO'] as String,
      nroDot: json['NRODOT'] as String,
      indRecapagem: json['INDRECAPAGEM'] as String,
      vidaPneu: json['VIDAPNEU'] as String,
      kmRodado: json['KMRODADO'] as String,
      kmAcumulador: json['KMACUMULADOR'] as String,
      kmAtuVei: json['KMATUVEI'] as String,
      kmRodado0: json['KMRODADO0'] as String,
      kmRodado1: json['KMRODADO1'] as String,
      kmRodado2: json['KMRODADO2'] as String,
      kmRodado3: json['KMRODADO3'] as String,
      kmRodado4: json['KMRODADO4'] as String,
      kmRodado5: json['KMRODADO5'] as String,
      dataCompra: json['DATACOMPRA'] as String,
      dataAtzKm: json['DATAATZKM'] as String,
      codFil: json['CODFIL'] as String,
      nroFrota: json['NROFROTA'] as String,
      placa: json['PLACA'] as String,
    );
  }
}
```

**Explicacoes:**

- **`const` no construtor** — como todos os campos sao `final`, o Dart permite marcar o construtor como `const`. Isso possibilita criar instancias em tempo de compilacao quando todos os argumentos forem constantes, melhorando performance.

- **`factory Pneu.fromJson`** — factory constructor nao cria a instancia diretamente com `this`, ele retorna um objeto. Util para deserializacao porque podemos fazer transformacoes antes de criar o objeto. O `factory` garante que sempre passamos por essa logica.

- **Todos os campos como `String`** — mesmo campos como `KMRODADO` que parecem numericos, a API retorna como string. Manter como string evita conversoes desnecessarias e erros de parsing. Se precisarmos de calculos futuros, convertemos no ponto de uso.

---

### Passo 2 — Criar model Veiculo

Criar `lib/models/veiculo.dart`:

```dart
import 'pneu.dart';

class Veiculo {
  final String placa;
  final String nroFrota;
  final String marca;
  final String modelo;
  final String ano;
  final String anoModelo;
  final String cor;
  final String tipo;
  final List<Pneu> pneus;

  const Veiculo({
    required this.placa,
    required this.nroFrota,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.anoModelo,
    required this.cor,
    required this.tipo,
    required this.pneus,
  });

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      placa: json['PLACA'] as String,
      nroFrota: json['NROFROTA'] as String,
      marca: json['MARCA'] as String,
      modelo: json['MODELO'] as String,
      ano: json['ANO'] as String,
      anoModelo: json['ANOMODELO'] as String,
      cor: json['COR'] as String,
      tipo: json['TIPO'] as String,
      pneus: (json['pneus'] as List)
          .map((e) => Pneu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

**Explicacoes:**

- **`import 'pneu.dart'`** — import relativo dentro do mesmo diretorio `models/`. Funciona porque ambos os arquivos estao em `lib/models/`.

- **`List<Pneu> pneus`** — o JSON retorna um array `pneus` dentro do veiculo. Usamos `List<Pneu>` tipado para ter autocomplete e type safety.

- **`(json['pneus'] as List).map(...).toList()`** — o `json['pneus']` retorna `dynamic`. Fazemos cast para `List`, depois `map` para converter cada item em `Pneu` usando `fromJson`, e `toList()` para materializar o `Iterable` em `List`. Sem o `toList()`, teriamos um `Iterable<Pneu>` lazy (que so executa quando iterado), nao um `List<Pneu>`.

---

## Criterios de aceite

- [ ] `lib/models/pneu.dart` existe com todos os campos do JSON mapeados
- [ ] `lib/models/veiculo.dart` existe com campos do veiculo + `List<Pneu> pneus`
- [ ] Ambos possuem factory `fromJson` funcional
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-service|Service de frota]]
- [[DevLog/]]
