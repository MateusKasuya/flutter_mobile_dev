# Frota Fácil Mobile

Aplicativo Flutter (Android e iOS) de **gestão de pneus de frota**, do ecossistema Transporte Fácil.

Permite acompanhar quantos pneus há em cada localização (estoque, frota, conserto, recapagem, sucata, venda), consultar os pneus montados em um veículo pela placa — digitada ou lida pela câmera (OCR) — em um diagrama de eixos interativo, e registrar movimentações de pneus direto do pátio.

## Documentação

- [Documentação técnica](docs/documentacao-tecnica.md) — arquitetura, API, modelos, telas, testes e plataformas.
- [Documentação de produto](docs/documentacao-produto.md) — visão do produto, conceitos do domínio, fluxos e regras de negócio.

## Como rodar

```bash
flutter pub get
flutter run                                              # usa a API de homologação (default)
flutter run --dart-define=API_BASE_URL=servidor:porta    # aponta para outro ambiente
```

## Testes

Não há CI — os testes rodam manualmente via script:

```bash
./testar.sh          # analyze + testes de unidade/widget (rápido, sem device)
./testar.sh device   # + testes de integração em emulador/aparelho
./testar.sh homolog  # E2E real contra homologação (pede credenciais na hora)
./testar.sh testlab  # testes de integração no Firebase Test Lab
./testar.sh tudo     # rápido + device + homolog
```
