---
tags: [tipo/devlog, dominio/frota]
date: 2026-03-16
---

# Dev Log — 16/03/2026

[[DevLog/_index|DevLog]]

---

## Task

[[Tasks/2026-03-05-frota-camera-ocr|Camera + OCR da placa]]

## O que foi feito

- Adicionadas dependências `image_picker` e `google_mlkit_text_recognition` ao `pubspec.yaml`
- Configurada permissão de câmera no `ios/Runner/Info.plist` (`NSCameraUsageDescription`)
- Adicionado método `_scanPlaca` na `FrotaBuscaScreen` que abre a câmera, processa a imagem com ML Kit e preenche o campo de placa automaticamente
- Adicionado `FloatingActionButton` com ícone `camera_alt` na `FrotaBuscaScreen`

## Decisões tomadas

Nenhuma decisão de arquitetura nova.

## Problemas encontrados

Nenhum.

## Aprendizados

- `image_picker` abstrai câmera nativa entre Android e iOS, retornando `XFile?` (null se cancelado)
- `google_mlkit_text_recognition` roda OCR localmente no dispositivo sem necessidade de internet
- `TextRecognizer` deve ser fechado com `.close()` no `finally` para liberar recursos nativos

## Próximos passos

- [[Tasks/2026-03-05-frota-tests|Testes do módulo Frota]]
