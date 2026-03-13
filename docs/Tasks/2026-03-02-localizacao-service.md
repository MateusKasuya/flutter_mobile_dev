---
tags: [tipo/task, dominio/home]
date: 2026-03-02
status: planejada
branch: feat/localizacao-service
---

# Task — Modelo e serviço de localizações de pneus

[[Tasks/_index|Tasks]]

---

## Contexto

A Home Screen precisa consumir o endpoint `api/frota/pneu/qlocalizacaopneus` para exibir a quantidade de pneus por localização (ESTOQUE, FROTA, SUCATA, VENDA). Antes de construir a tela, precisamos do modelo de dados e do serviço HTTP que faz essa chamada autenticada.

## Objetivo

Ter um serviço reutilizável que recebe o token JWT e retorna a lista de localizações com suas quantidades, pronto para ser consumido pela Home Screen.

---

## Branch

```bash
git checkout -b feat/localizacao-service
```

## Arquivos a criar

- `lib/models/localizacao.dart` — classe `Localizacao` com `fromJson`
- `lib/services/localizacao_service.dart` — função `fetchLocalizacoes(String token)`

## Arquivos a modificar

- Nenhum

---

## Implementação

### Passo 1 — Criar o modelo `Localizacao`

Criar `lib/models/localizacao.dart`:

```dart
class Localizacao {
  final int quantidade;
  final String nome;

  const Localizacao({required this.quantidade, required this.nome});

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      quantidade: json['QTLOCALIZACAO'] as int,
      nome: json['LOCALIZACAO'] as String,
    );
  }
}
```

### Passo 2 — Criar o serviço `localizacao_service.dart`

Criar `lib/services/localizacao_service.dart`:

- Usar a mesma `_baseUrl` do `auth_service.dart` (`fretefacilweb.ccmcloud.com.br:8624`)
- Fazer GET em `api/frota/pneu/qlocalizacaopneus`
- Header `Authorization: Bearer <token>`
- Decodificar o JSON como `List<Localizacao>`
- Lançar `Exception` em caso de erro (mesmo padrão do `auth_service`)

Retorno esperado da API:
```json
[
  {"QTLOCALIZACAO": 241, "LOCALIZACAO": "ESTOQUE"},
  {"QTLOCALIZACAO": 906, "LOCALIZACAO": "FROTA"},
  {"QTLOCALIZACAO": 807, "LOCALIZACAO": "SUCATA"},
  {"QTLOCALIZACAO": 81, "LOCALIZACAO": "VENDA"}
]
```

---

## Critérios de aceite

- [ ] Modelo `Localizacao` criado com factory `fromJson`
- [ ] Serviço faz GET autenticado no endpoint correto
- [ ] Retorna `List<Localizacao>` com os dados parseados
- [ ] Lança Exception com mensagem em caso de erro HTTP
- [ ] `flutter analyze` sem erros

---

## Links relacionados

- [[DevLog/]]
- [[Decisoes/]]
