---
tags: [tipo/task, dominio/frota]
date: 2026-03-05
status: planejada
branch: feat/frota-service
---

# Task — Service de frota

[[Tasks/_index|Tasks]]

---

## Contexto

Com os models `Veiculo` e `Pneu` prontos, precisamos de um service que chame o endpoint `/veiculo/getveiculo-com-pneus` da API e retorne um objeto `Veiculo` tipado. Seguimos o mesmo padrao do `localizacao_service.dart` existente.

## Objetivo

`frota_service.dart` com funcao `fetchVeiculo(token, placa)` que retorna um `Veiculo` ou lanca excecao com mensagem de erro.

---

## Branch

```bash
git checkout -b feat/frota-service
```

## Arquivos a criar

- `lib/services/frota_service.dart`

## Arquivos a modificar

- *(nenhum)*

---

## Implementacao

### Passo 1 — Criar frota_service.dart

Criar `lib/services/frota_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/veiculo.dart';

const String _baseUrl = 'fretefacilweb.ccmcloud.com.br:8624';

/// Busca um veiculo com seus pneus pela placa.
///
/// Lanca uma [Exception] com a mensagem de erro em caso de falha.
/// [client] permite injetar um cliente HTTP para testes.
Future<Veiculo> fetchVeiculo(String token, String placa,
    {http.Client? client}) async {
  final createdClient = client == null;
  final c = client ?? http.Client();
  try {
    final url = Uri.http(
      _baseUrl,
      '/api-frota/veiculo/getveiculo-com-pneus',
      {'placa': placa},
    );
    final response = await c.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Veiculo.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Veiculo nao encontrado');
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail']?[0]?['msg'] ?? 'Erro ao buscar veiculo');
    }
  } finally {
    if (createdClient) {
      c.close();
    }
  }
}
```

**Explicacoes:**

- **`Uri.http(_baseUrl, path, queryParameters)`** — o terceiro argumento de `Uri.http` eh um `Map<String, String>` de query parameters. O Dart automaticamente codifica e anexa como `?placa=ABC1D23` na URL. Mais seguro que concatenar strings manualmente, pois faz URL encoding automatico de caracteres especiais.

- **`{http.Client? client}`** — parametro nomeado opcional para injecao de dependencia, mesmo padrao do `localizacao_service.dart`. Em producao, cria um client novo; em testes, recebe um `MockClient`.

- **`final createdClient = client == null`** — flag para saber se devemos fechar o client no `finally`. Se o chamador injetou o client, a responsabilidade de fechar eh dele. Se criamos internamente, fechamos nos. Evita vazamento de recursos (conexoes HTTP abertas).

- **`response.statusCode == 404`** — tratamento especifico para "veiculo nao encontrado", que eh um caso esperado (usuario digitou placa errada). Mensagem amigavel em portugues em vez do erro tecnico da API.

- **`data['detail']?[0]?['msg']`** — navegacao segura com `?` (null-aware operator). Se `detail` for null, ou o array estiver vazio, ou `msg` nao existir, retorna `null` sem lancar erro. O `??` fornece o fallback.

---

## Criterios de aceite

- [ ] `lib/services/frota_service.dart` existe com funcao `fetchVeiculo`
- [ ] Aceita `token` e `placa` como parametros obrigatorios
- [ ] Aceita `client` opcional para testes
- [ ] Retorna `Veiculo` no sucesso (200)
- [ ] Lanca `Exception('Veiculo nao encontrado')` no 404
- [ ] Lanca `Exception` com mensagem da API no 422
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[Tasks/2026-03-05-frota-models|Models Veiculo e Pneu]]
- [[Tasks/2026-03-05-frota-busca-placa|Tela de busca por placa]]
- [[DevLog/]]
