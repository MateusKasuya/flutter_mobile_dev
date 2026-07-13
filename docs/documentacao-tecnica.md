# Documentação Técnica — Frota Fácil Mobile

Aplicativo Flutter (Android e iOS) de gestão de pneus de frota, integrado à API `api-frota` do ecossistema Transporte Fácil. Este documento descreve a arquitetura, as integrações, os padrões do código e a estratégia de testes. Para a visão de negócio (fluxos, regras, glossário), ver a [documentação de produto](documentacao-produto.md).

## 1. Visão geral

| Item | Valor |
|---|---|
| Framework | Flutter (Dart SDK `^3.10.8`) |
| Plataformas | Android e iOS |
| Versão | 0.1.0 (`pubspec.yaml`) |
| Idioma/locale | pt-BR (único locale suportado) |
| Gerência de estado | `provider` (apenas `AuthProvider`); o resto é estado local por tela (`StatefulWidget`) |
| Navegação | Imperativa, via `Navigator.push`/`pushReplacement`/`pushAndRemoveUntil` — **não há rotas nomeadas** |
| Lint | `flutter_lints` (via `analysis_options.yaml`) |
| CI | Não há — testes rodam manualmente via `./testar.sh` |

Padrão transversal importante: telas e serviços recebem dependências por parâmetro com valor default (`fetchFn`, `loginFn`, `client`, `prefs`...). Em produção usa-se o default; nos testes injeta-se um fake. É injeção de dependência manual, sem framework.

## 2. Dependências

Pacotes de runtime (`pubspec.yaml`):

| Pacote | Papel |
|---|---|
| `http` | Cliente HTTP de todos os serviços; `AuthHttpClient` estende `http.BaseClient` |
| `provider` | Disponibiliza o `AuthProvider` (`ChangeNotifierProvider`) na árvore de widgets |
| `flutter_secure_storage` | Keystore (Android) / Keychain (iOS) para token e senha do "lembrar-me" |
| `shared_preferences` | Flags não sensíveis do "lembrar-me" (`remember_me`, `saved_cpf`) |
| `mask_text_input_formatter` | Máscara de CPF no login |
| `fluttertoast` | Toasts de sucesso/erro |
| `flutter_svg` | Logos e ícones SVG de `assets/` |
| `google_fonts` | Fonte Montserrat — **empacotada em `assets/fonts/`, sem download em runtime** |
| `image_picker` | Foto da câmera para o OCR de placa |
| `flutter_localizations` | Localização pt-BR dos widgets Material |

Dev: `flutter_test`, `integration_test`, `flutter_lints`.

Nota: **não** há pacote `google_mlkit_*` — o OCR é implementado em código nativo (ver §11).

## 3. Como rodar

```bash
flutter pub get
flutter run                                              # API de homologação (default)
flutter run --dart-define=API_BASE_URL=servidor:porta    # aponta para outro ambiente
```

O endereço da API é resolvido em **tempo de compilação** por `String.fromEnvironment` em `lib/config/api_config.dart` — não é variável de ambiente em runtime. Sem `--dart-define`, vale o default: `fretefacilweb.ccmcloud.com.br:8624` (homologação). O timeout de toda requisição é `apiTimeout = 15s`.

### Testes (sem CI — sempre manual)

```bash
./testar.sh          # flutter analyze + testes de unidade/widget (rápido, sem device)
./testar.sh device   # o acima + integration tests (sobe emulador Android se preciso; 2º arg força um device)
./testar.sh homolog  # E2E real contra homologação (pede CPF/senha na hora, passa por --dart-define)
./testar.sh testlab  # integration tests em aparelhos do Firebase Test Lab (via gcloud)
./testar.sh tudo     # rápido + device + homolog
```

## 4. Estrutura do projeto

Organização por camada (layer-first) dentro de `lib/`:

| Pasta | Conteúdo |
|---|---|
| `config/` | `api_config.dart` — base URL (dart-define) e timeout |
| `models/` | Classes de domínio com `fromJson` (Veiculo, Pneu, Eixo, Localizacao, Fornecedor, MotivoSucateamento, enum PneuAcao) |
| `services/` | Chamadas HTTP à API, storages seguros, cliente HTTP com tratamento global de 401 |
| `providers/` | `auth_provider.dart` — estado de autenticação (`ChangeNotifier`) |
| `screens/` | As 7 telas do app |
| `components/` | Widgets reutilizáveis: campos de formulário, bottom sheets de movimentação, diálogo de ações, diagrama de eixos |
| `theme/` | Cores, estilos de texto, tema Material e breakpoint de tablet |
| `utils/` | Validador de CPF, extração de placa, toasts, tradução de erros, montagem dos eixos |

## 5. Inicialização e navegação

`lib/main.dart`:

- `GoogleFonts.config.allowRuntimeFetching = false` — a Montserrat vem de `assets/fonts/` (funciona offline e a fonte certa aparece já no primeiro frame). A licença OFL é registrada em `LicenseRegistry`.
- `navigatorKey` (`GlobalKey<NavigatorState>`) global, passada ao `MaterialApp` — permite navegar **sem `BuildContext`** a partir da camada de rede (é como o tratamento de 401 leva o usuário ao login).
- `MainApp` é `StatefulWidget` só para registrar em `initState` (e desregistrar em `dispose`) o `sessionExpiredHandler` de `auth_http_client.dart`: limpa o token no `AuthProvider` e faz `pushAndRemoveUntil(LoginScreen)` descartando todo o histórico.
- `ChangeNotifierProvider(create: AuthProvider())` no topo da árvore; `MaterialApp` com `theme: AppTheme.theme`, locale fixo `pt-BR` e `home: SplashScreen()`.

`SplashScreen` decide a rota inicial: espera 2s (branding), carrega o token do secure storage (`auth.loadToken()`) e navega para `HomeScreen` se `isAuthenticated` (token não vazio) ou `LoginScreen`. **Não há validação do token na splash** — um token expirado entra na Home e cai no login no primeiro 401.

Mapa de navegação:

```
Splash → Login → Home → Movimento → Frotas  → FrotaBusca → FrotaDetalhe → (ações de pneu)
                  │                → Pneus   → PneuLista   → (ações de pneu)
                  │                → Abastecimento (placeholder, inativo)
                  └ (logout / sessão expirada → Login)
```

## 6. Autenticação

### Login

`services/auth_service.dart` → `login(cpfusuario, senhausuario)`:

- `POST http://{apiBaseUrl}/sftlogin/login` com body `{"cpfusuario": ..., "senhausuario": ...}` (CPF só dígitos — a tela remove a máscara antes de enviar).
- **Sucesso é HTTP 202** (particularidade do gateway, não 200); retorna `access_token` do corpo.
- O 401 de senha errada chega com **corpo vazio** — por isso o erro passa por `apiException`, que tolera corpo vazio/não-JSON.

### Token e armazenamento

- `AuthProvider` (`ChangeNotifier`): `_token` em memória é a fonte de verdade; `isAuthenticated => _token.isNotEmpty`. `setToken`/`clearToken` notificam a UI **antes** de persistir (persistência best-effort em try/catch).
- `TokenStorage` (interface) / `SecureTokenStorage`: token na chave `auth_token` do `FlutterSecureStorage`. O token nunca vai para `SharedPreferences`.
- `CredentialStorage` / `SecureCredentialStorage`: senha do "lembrar-me" na chave `saved_password` do secure storage.

### "Lembrar usuário e senha"

No login bem-sucedido com a opção marcada: `remember_me=true` e `saved_cpf` (com máscara) vão para `SharedPreferences`; a **senha vai só para o Keystore/Keychain**. Desmarcado, tudo é removido. A tela também remove um eventual `saved_password` legado do `SharedPreferences` (migração de versões antigas que guardavam a senha em texto puro).

### Sessão expirada (401)

`services/auth_http_client.dart`:

- `apiClient` é um singleton global (`AuthHttpClient` sobre `http.Client`) usado por todos os serviços autenticados — nenhum serviço o fecha.
- `AuthHttpClient` sobrescreve `send()` e intercepta **toda** resposta 401 num único ponto: dispara o `sessionExpiredHandler` (registrado no `main.dart`) uma única vez mesmo sob uma rajada de 401s simultâneos (flag de reentrância rearmada no próximo frame).
- **Não há refresh token nem re-login automático**: o 401 limpa o token e devolve o usuário à tela de login.

## 7. Camada de API

Todos os endpoints usam `Uri.http` (HTTP em texto claro — ver §15) e, exceto o login, enviam `Authorization: Bearer {token}`. O contrato JSON da API é **camelCase todo minúsculo**, documentado no Swagger público em `/api-frota/swagger/v1/swagger.json`.

| Função (service) | Método | Caminho | Observações |
|---|---|---|---|
| `login` (auth_service) | POST | `/sftlogin/login` | Sucesso = **202** com `access_token` |
| `fetchVeiculo` (frota_service) | GET | `/api-frota/veiculo/getveiculo-com-pneus?placa=XXX` | 404 → "Veiculo nao encontrado" |
| `fetchPneus` (pneu_service) | GET | `/api-frota/pneu/getpneu` | Lista todos os pneus |
| `movimentarPneu` (pneu_service) | POST | `/api-frota/pneu/movimentarpneu` | Endpoint único de movimentação (abaixo) |
| `fetchLocalizacoes` (localizacao_service) | GET | `/api-frota/pneu/qlocalizacaopneus` | Quantidade de pneus por localização (Home) |
| `fetchFornecedores` (fornecedor_service) | GET | `/api-frota/fornecedor/getfornecedor` | Fornecedores de recauchutagem |
| `fetchMotivosSucateamento` (sucata_service) | GET | `/api-frota/sucata/getsucata` | Motivos de sucateamento |

### `movimentarPneu` — endpoint único

O backend decide o tipo de movimentação pelos campos preenchidos (os demais vão `null`):

- **Toda movimentação:** `localizacaO_ORIGEM` com a localização **atual** do pneu em MAIÚSCULAS (`FROTA` quando montado num veículo). A grafia exótica da chave é literal do contrato — é como o serializer do backend expõe a propriedade `LOCALIZACAO_ORIGEM` no swagger.
- **Montagem no veículo:** `localeixo`, `codesqeixo`, `placa`, `nrofrota`. A **origem** do pneu segue indo também em `localizacao` (exigência anterior ao campo dedicado — "LOCALIZACAO é obrigatória"; ainda sem confirmação do backend de que a montagem dispensa o campo).
- **Movimentação para localização** (estoque/conserto/recapagem/sucata/venda): `localizacao` com o nome do **destino** em MAIÚSCULAS.
- **Sucateamento:** adicionalmente `codmotivosucat`.
- Campos comuns: `nropneu`, `dataentrada`, `codfil`, `valor` (default 0); opcionais `kmentrada`, `cgccpfforne` (fornecedor), `motivosaida`.

A data é formatada como `AAAA-MM-DDTHH:MM:SS` **sem milissegundos** (`toIso8601String()` não serve — acrescenta `.000`, fora do contrato). A resposta, tanto em 200 quanto em **422**, vem no formato `{"sucesso": bool, "mensagem": str}` — diferente do `{"detail": ...}` do resto da API —, por isso o parse é feito no próprio service; sucesso = `200` **e** `sucesso == true`.

### Tratamento de erros

- `services/api_error.dart` → `apiException(response, mensagemPadrao)`: extrai `detail` do corpo nos dois formatos usados pela API (`{"detail": "msg"}` e `{"detail": [{"msg": ...}]}`); corpo vazio/não-JSON vira `"{mensagemPadrao} (HTTP {código})"`.
- `services/http_helpers.dart` → `getJsonList<T>(path, token, fromJson)`: esqueleto genérico GET + Bearer + timeout + decode de lista, usado pelos services de pneu/localização/fornecedor/sucata.
- `utils/friendly_error.dart` → `friendlyError(e)`: traduz a exceção capturada em mensagem curta pt-BR (`SocketException`/`ClientException` → "Sem conexão com o servidor...", `TimeoutException` → "O servidor demorou para responder...", `Exception: msg` → `msg`, resto → "Ocorreu um erro inesperado."). As telas usam `showErrorToast(friendlyError(e))`.

## 8. Modelos de domínio (`lib/models/`)

Padrão: campos `final`, `factory fromJson` com `?? ''`/`?? 0` por chave. Nenhum modelo tem `toJson` — o único envio (movimentação) é montado manualmente no service.

| Modelo | Campos principais | Notas |
|---|---|---|
| `Veiculo` | `placa`, `nroFrota`, `marca`, `modelo`, `ano`, `anoModelo`, `cor`, `tipo`, `codEsqEixo`, `List<Pneu> pneus` | `pneus` tolera lista ausente/itens malformados (`whereType`) |
| `Pneu` | 27 campos String: `nroPneu`, `nroSerie`, `marca`, `modelo`, `dimensao`, `tipo`, `situacao`, `localEixo`, `codEsqEixo`, `localizacao`, `nroDot`, `vidaPneu`, `kmRodado`, `kmAtuVei`, `kmRodado0..5`, datas, `codFil`, `nroFrota`, `placa`... | **Pegadinha:** as chaves JSON `kmrodadO0..kmrodadO5` têm "O" **maiúsculo** antes do dígito (artefato da API). Números chegam como String; o service converte com `int.tryParse` ao enviar |
| `Eixo` | `numero`, 4 slots `Pneu?` (esq/dir × externo/interno), `rodadoDuplo` | **Sem `fromJson`** — construído por `buildEixoLayout` (§10). Métodos imutáveis `withoutPneu`/`withPneuAt` |
| `Localizacao` | `nome`, `quantidade` | Chaves `localizacao`/`qtlocalizacao`; quantidade tolera String ou número |
| `Fornecedor` | `cgcCpf`, `razaoSocial`, `nomeFantasia` | `==`/`hashCode` por `cgcCpf` |
| `MotivoSucateamento` | `codigo`, `descricao` | **Atenção:** definido em `models/pneu_movimentacao.dart` (não existe classe `PneuMovimentacao`) |
| `PneuAcao` (enum) | `estoque`, `conserto`, `recapagem`, `sucata`, `venda` | Cada valor carrega label, ícone/SVG e cores usados na UI |

Situação do pneu (campo `situacao`): `N` NOVO `#00AF3E` · `U` USADO `#FF8126` · `R` RECAPADO `#7D00DE` · `S` SUCATA `#F03E26`.

## 9. Telas (`lib/screens/`)

- **`splash_screen.dart`** — gradiente `#01556F → #028480`, logo branco, tagline; decide Login × Home (§5).
- **`login_screen.dart`** — CPF (`CpfField`, máscara + validação de dígitos verificadores) + senha (`PasswordField`, toggle de visibilidade) + `RememberMeCheckbox` + "Entrar" com `LoadingOverlay`. Erros via toast. Celular: faixa de gradiente no topo + form rolável; tablet (≥600): card branco de 420px sobre gradiente.
- **`home_screen.dart`** — "Monitoramento de movimentações da Frota": grid de cards com a quantidade de pneus por localização (`fetchLocalizacoes`), ícone SVG por nome (ESTOQUE/FROTA/SUCATA/VENDA/CONSERTO/RECAPAGEM). Pull-to-refresh, estado de erro com "Tentar novamente", logout na AppBar. FAB "Adicionar Movimento" → `MovimentoScreen`. Celular: `GridView.count` 3 colunas; tablet: grid fixo.
- **`movimento_screen.dart`** — menu com 3 cards: **Frotas** → `FrotaBuscaScreen`, **Pneus** → `PneuListaScreen`, **Abastecimento** → sem `onTap` (placeholder de feature futura).
- **`frota_busca_screen.dart`** — campo de placa (maiúsculas forçadas) + "Buscar" + FAB de câmera. O fluxo de câmera: `image_picker` (câmera traseira, qualidade 85) → OCR nativo → `extractPlaca` → preenche o campo e mostra toast. Buscar → `fetchVeiculo` → `FrotaDetalheScreen`.
- **`frota_detalhe_screen.dart`** — card do veículo (placa, frota, marca/modelo/ano/cor/tipo) + `DiagramaEixos` interativo. Toque no pneu = detalhes (bottom sheet no celular, dialog no tablet); **duplo toque no pneu** = ações de movimentação (remove o pneu do slot ao confirmar); **duplo toque em slot vazio** = montagem (insere o pneu ao confirmar).
- **`pneu_lista_screen.dart`** — lista de todos os pneus com **filtro client-side** (nº, marca, modelo, placa, frota, série, situação, tipo, localização). Cards com badge de situação e chips. Toque: abre ações; em `selectionMode` (usado pela montagem), devolve o pneu por `Navigator.pop(context, pneu)`.

## 10. Diagrama de eixos

Renderização visual do chassi do veículo com um slot por posição de pneu.

- **`utils/eixo_utils.dart` → `buildEixoLayout(pneus, codEsqEixo)`**: parseia `localEixo` de cada pneu no formato `{nºeixo}{posição}` (posições `E`/`EE`/`EI`/`D`/`DE`/`DI` — esquerdo/direito, externo/interno). Se o `codEsqEixo` do veículo é um esquema conhecido, monta o **chassi inteiro** (inclusive eixos vazios, com rodado simples/duplo do esquema); pneus sem posição válida (ex.: estepe) ficam de fora do desenho.
- **`components/diagrama_eixos/esquema_eixo.dart` → enum `EsquemaEixo`**: 15 esquemas mapeados por código, com o rodado (simples/duplo) de cada eixo:

  | Código | Esquema | Rodado por eixo |
  |---|---|---|
  | A | Toco | simples, duplo |
  | M | Moto | simples, simples |
  | F | Passeio | simples, simples |
  | H | Bitruck | simples, simples, duplo, duplo |
  | G / B / O / D | Cavalos truck | variações de 3–4 eixos |
  | N | Carretinha | simples |
  | J / E / K / C / L / P | Carretas 1–4 eixos | todos duplos |

- **`components/diagrama_eixos/base_frame.dart`**: frame genérico — 2 longarinas + extremidades configuráveis (`parachoque`, `pinoRei`, `nenhum`) + layout dos eixos (espaçado, agrupado ou espalhado na traseira). Caminhões usam parachoque/pino-rei; carretas, pino-rei/parachoque.
- **`frame_moto.dart`**: caso especial — espinha central única, 1 pneu centralizado por eixo.
- **`primitives.dart`**: os desenhos em si, com `CustomPainter` (API do Flutter para desenhar direto no canvas): `TirePainter` (pneu visto de cima com sulcos e sipes), `EmptyTirePainter` (slot vazio com borda tracejada), parachoque, pino-rei, hubs e labels `E1/E2...`. Dimensões dobram no tablet.
- **`diagrama_eixos.dart`**: escolhe o frame pelo `codEsqEixo` (fallback: código do 1º pneu; desconhecido → toco), calcula altura mínima e habilita scroll quando não cabe. Repassa os callbacks `onPneuTap`/`onPneuDoubleTap`/`onSlotVazioDoubleTap`.

## 11. OCR de placa

O OCR é **nativo**, exposto ao Dart por um `MethodChannel` (ponte Flutter ↔ código da plataforma):

- `services/ocr_service.dart`: casca fina — `extractTextFromImage(imagePath)` invoca `extractText` no canal `frota_facil/ocr` e devolve o texto reconhecido.
- **Android** (`android/.../OcrPlugin.kt`): Google **ML Kit** (`com.google.mlkit:text-recognition:16.0.1`, script latino), registrado na `MainActivity`.
- **iOS** (`ios/Runner/OcrPlugin.swift`): **Apple Vision** (`VNRecognizeTextRequest`, nível `accurate`, sem correção de linguagem), registrado no `AppDelegate`.
- Erros nativos viram `PlatformException` (`INVALID_ARGS`, `IMAGE_ERROR`, `OCR_ERROR`).

`utils/placa_utils.dart` → `extractPlaca(texto)`: divide **só por `\n`** (o OCR às vezes insere espaço dentro da placa), remove tudo que não é `A-Z0-9` de cada linha e retorna a primeira que casa placa antiga (`AAA9999`) ou Mercosul (`AAA9A99`). Isso descarta ruído como "BRASIL" e o nome do município.

Legado: `assets/tessdata/eng.traineddata` sobrou de uma tentativa anterior com Tesseract; a implementação atual não o usa.

## 12. Tema e responsividade

- **Breakpoint único**: `kTabletBreakpoint = 600` pixels lógicos (`theme/breakpoints.dart`). `largura >= 600` = layout tablet (um celular em paisagem também cai nele — cenário coberto pelos testes). Muda: layouts centralizados/mais largos, fontes maiores e bottom sheets viram `Dialog`.
- **Cores** (`theme/app_colors.dart`): primária `#006F70` (borda `#028687`), texto `#003156`/`#363636`/tons de cinza, fundo `#EDEDED`, gradiente do login `#CEFCF1 → #FFFFFF`, ícones `#00ACAD`. As cores de situação de pneu e das ações de movimentação são definidas junto de quem as usa (§8).
- **Tipografia** (`theme/app_text_styles.dart`): ~25 estilos Montserrat nomeados por uso (`heading`, `button`, `bigNumbers`, `labelBar`...), `height: 1.0`.
- **Tema** (`theme/app_theme.dart`): `ColorScheme.fromSeed(seedColor: primary).copyWith(primary: primary)` — o `copyWith` fixa o primary exato (o `fromSeed` sozinho geraria um tom derivado, criando "dois teais").

## 13. Testes

### Unidade e widget (`test/`, 28 arquivos)

Espelham a estrutura de `lib/`: `models/` (parsing), `services/` (com `MockClient` de `package:http/testing.dart` — verificam método, path, header Bearer, desserialização e mensagens de erro), `providers/`, `screens/`, `components/`, `utils/`.

- **Matriz responsiva** (`test/screens/responsive_matrix_test.dart` + `test/helpers/test_viewport.dart`): **6 telas × 9 perfis de dispositivo = 54 testes**. Perfis: celulares pequeno/padrão/grande, fonte grande (escala 1.3), paisagem, tablet retrato/paisagem/fonte grande. O teste renderiza cada tela em cada viewport e conta com o detector implícito de overflow do Flutter (RenderFlex overflow → erro → teste falha). `usePhoneViewport` existe porque o viewport default do `flutter test` (800×600) cruzaria o breakpoint de tablet.
- **Fontes reais** (`test/flutter_test_config.dart`): carrega os `.ttf` da Montserrat via `FontLoader` antes de todo teste. Sem isso o Flutter testa com a fonte fake "Ahem" (glifos quadrados, mais largos), gerando falsos overflows.

### Integração (`integration_test/`, roda em device/emulador)

- `fluxo_critico_test.dart` — fluxos críticos com **rede mockada por injeção** e storages reais: navegação Home→Movimento, busca de placa→detalhe→diálogo de ações, movimentação estoque→conserto (cancela antes do POST) e persistência real do lembrar-me (SharedPreferences + Keystore, simulando reabertura do app).
- `e2e_homolog_test.dart` — E2E **real** contra homologação, nada mockado, **somente leitura** (nenhum POST). Credenciais via `--dart-define` (`E2E_CPF`, `E2E_SENHA`, `E2E_PLACA` opcional); dá auto-`skip` se ausentes.
- `ocr_smoke_test.dart` — smoke do OCR nativo (único código fora do alcance dos widget tests): gera a imagem de uma placa via `Canvas` (sem binário no git) e valida leitura, ausência de falso positivo e erro de caminho inexistente.
- `all_tests.dart` — agregador dos três para o Firebase Test Lab (o nome não termina em `_test.dart` de propósito, para o modo `device` não rodá-los em dobro).

### Firebase Test Lab

`./testar.sh testlab` builda os 2 APKs de instrumentação (`assembleDebug -Ptarget=integration_test/all_tests.dart` + `assembleDebugAndroidTest`) e roda `gcloud firebase test android run` (default `MediumPhone.arm, API 34, pt_BR`; sobrescrevível por `TESTLAB_DEVICES`).

## 14. Específicos de plataforma

**Android** (`android/`):
- `applicationId`/`namespace` = `com.example.frota_facil_mobile` — **placeholder, trocar antes de publicar** (há `TODO` no `build.gradle.kts`).
- `allowBackup="false"`; Java/Kotlin target 17; min/target/compile SDK herdados do Flutter.
- Dependência nativa `com.google.mlkit:text-recognition:16.0.1`; runner de instrumentação AndroidJUnit (Test Lab).
- O manifest principal não declara `CAMERA` (a foto vem do app de câmera do sistema, via intent do `image_picker`) nem `INTERNET` (presente só nos manifests de debug/profile — conferir no build release, ver §15).

**iOS** (`ios/`):
- Display name "Frota Facil Mobile"; deployment target **15.6**.
- `NSCameraUsageDescription` = "Necessário para fotografar a placa do veículo".
- OCR via Apple Vision em `OcrPlugin.swift`.

## 15. Pontos de atenção e dívidas conhecidas

1. **HTTP em texto claro**: toda a API (inclusive login com CPF/senha) usa `Uri.http`. A migração para HTTPS depende do servidor expor TLS (pendência do backend, item A3 do code review de jul/2026); quando ocorrer, trocar para `Uri.https` e remover as exceções de cleartext.
2. **Login retorna 202** no sucesso — qualquer mudança no gateway quebra o fluxo; o status está fixo no `auth_service`.
3. **Sem refresh token**: token expirado só é detectado no primeiro 401, que derruba o usuário para o login.
4. **`applicationId` Android é placeholder** (`com.example.*`) — precisa mudar antes de qualquer publicação.
5. **`INTERNET` fora do manifest release** — validar acesso à rede num build release Android.
6. **Chaves `kmrodadO0..5`** do JSON de pneu têm "O" maiúsculo — não "corrigir" para minúsculo.
7. **Switch "Proibido futura recauchutagem"** (movimentação saindo de recapagem) existe na UI mas **não é enviado à API** atualmente.
8. **Abastecimento** é placeholder sem ação no menu Movimento.
9. **`assets/tessdata/`** é resquício do Tesseract, não usado.

## 16. Convenções de código

- Injeção de dependência por parâmetro default (`fetchFn`, `client`...) — novos serviços/telas devem seguir o padrão para permitir testes sem rede.
- Serviços sem client injetado usam o `apiClient` compartilhado (e **não** o fecham); o login cria e fecha o próprio client (create-or-close).
- Guardas `if (!mounted) return` após todo `await` que precede uso de `context`.
- Comentários em pt-BR explicando o *porquê* de decisões não óbvias (o projeto também é material de aprendizado de Flutter).
- **Não rodar `dart format` amplo**: o repositório está no estilo do formatter antigo; o formatter atual reestilizaria metade dos arquivos e poluiria o diff. Formatar apenas o que for editado, seguindo o estilo local.
