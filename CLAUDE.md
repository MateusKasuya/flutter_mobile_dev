# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**frota_facil_mobile** — Flutter mobile application for fleet management ("frota fácil" = easy fleet in Portuguese). Currently in initial setup phase.

- Flutter SDK: ^3.10.8 (Dart SDK constraint)
- Linting: `flutter_lints` (standard Flutter lint rules via `analysis_options.yaml`)

## Common Commands

```bash
# Rodar testes (NÃO há CI — execução sempre manual, via script):
#   ./testar.sh          → analyze + unit/widget (rápido, sem device)
#   ./testar.sh device   → + integration tests (sobe emulador se necessário)
#   ./testar.sh homolog  → E2E contra homologação (pede credenciais na hora)
#   ./testar.sh tudo     → tudo acima
./testar.sh

# Run the app (choose a connected device/emulator)
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze

# Format code
dart format lib/

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Architecture

The project is in early stages with only `lib/main.dart` containing a bare-bones `MaterialApp`. As features are added, organize code under `lib/` following a feature-first or layer-first structure consistent with what gets established during development.

## Documentation Vault

Project evolution and learning are documented in `docs/` as an Obsidian vault.

- Open `docs/` as the vault root in Obsidian.
- **`docs/Home.md`** — main index (MOC).
- **`docs/Decisões/`** — Architecture Decision Records (ADRs). Create one for every significant tech/architecture choice.
- **`docs/Dev Log/`** — chronological session notes. Use the template at `docs/Templates/Dev Log.md`.
- **`docs/Aprendizados/`** — topic-based learning notes (Flutter, Dart, patterns, tools).
- **`docs/Problemas & Soluções/`** — documented bugs and how they were solved.
- **`docs/Roadmap/Backlog.md`** — feature backlog and milestones.
- **`docs/Templates/`** — note templates for each section.
