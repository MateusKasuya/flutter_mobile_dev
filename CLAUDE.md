# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**frota_facil_mobile** — app Flutter (Android/iOS) de gestão de pneus de frota, do ecossistema Transporte Fácil. Login por CPF/senha, painel de pneus por localização, busca de veículo por placa (digitada ou lida por OCR na câmera), diagrama de eixos interativo e registro de movimentações de pneus (montagem, estoque, conserto, recapagem, sucata, venda) contra a API `api-frota`.

- Flutter SDK: `^3.10.8` (Dart SDK constraint)
- Linting: `flutter_lints` (via `analysis_options.yaml`)
- API: default homologação `fretefacilweb.ccmcloud.com.br:8624`, trocável por build com `--dart-define=API_BASE_URL=host:porta` (resolvido em tempo de compilação, em `lib/config/api_config.dart`)

## Common Commands

```bash
# Rodar testes (NÃO há CI — execução sempre manual, via script):
#   ./testar.sh          → analyze + unit/widget (rápido, sem device)
#   ./testar.sh device   → + integration tests (sobe emulador se necessário)
#   ./testar.sh homolog  → E2E contra homologação (pede credenciais na hora)
#   ./testar.sh testlab  → integration tests no Firebase Test Lab
#   ./testar.sh tudo     → rápido + device + homolog
./testar.sh

# Run the app (choose a connected device/emulator)
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

**NÃO rodar `dart format` amplo** (ex.: `dart format lib/`): o repositório está no estilo do formatter antigo e o atual reestilizaria metade dos arquivos, poluindo o diff. Formate apenas o que editar, seguindo o estilo local.

## Architecture

Layer-first dentro de `lib/`: `config/` (base URL da API), `models/`, `services/` (HTTP; `AuthHttpClient` intercepta 401 globalmente e derruba para o login), `providers/` (`AuthProvider` via package `provider`), `screens/`, `components/`, `theme/` (breakpoint único de 600px para tablet), `utils/`.

- Navegação imperativa com `Navigator.push` — sem rotas nomeadas.
- Estado: `provider` só para autenticação; o resto é estado local por tela.
- Testabilidade por injeção manual: telas/serviços recebem `fetchFn`/`client`/etc. com default de produção — novos códigos devem seguir o padrão.
- OCR de placa é nativo (ML Kit no Android, Vision no iOS) via `MethodChannel` — não há pacote Dart de OCR.

Detalhes completos em `docs/documentacao-tecnica.md`.

## Documentation

A documentação vive em `docs/` como Markdown puro (sem Obsidian: nada de wikilinks, frontmatter, dev logs, tasks ou ADRs):

- **`docs/documentacao-tecnica.md`** — arquitetura, API, modelos, telas, testes, plataformas e dívidas conhecidas.
- **`docs/documentacao-produto.md`** — visão de produto, conceitos do domínio, funcionalidades, fluxos e regras de negócio.

Ao mudar comportamento relevante (endpoint, regra de negócio, fluxo de tela, estratégia de teste), atualize o documento correspondente no mesmo PR/commit.
