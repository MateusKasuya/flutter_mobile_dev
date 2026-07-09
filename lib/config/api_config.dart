/// Configuração centralizada da API.
///
/// O endereço pode ser trocado POR BUILD, sem alterar código, via dart-define:
///
///   flutter run --dart-define=API_BASE_URL=servidor.producao.com:1234
///
/// `String.fromEnvironment` é resolvido em tempo de COMPILAÇÃO (não é
/// variável de ambiente do sistema em runtime): sem o --dart-define na
/// linha de comando, vale o defaultValue — o ambiente de homologação atual.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'fretefacilweb.ccmcloud.com.br:8624',
);

/// Tempo máximo de espera por resposta de cada requisição HTTP. Sem isso, uma
/// conexão que trava (portal cativo, perda de pacotes após conectar) deixaria
/// a UI girando até o timeout de socket do SO (1-2+ min).
const Duration apiTimeout = Duration(seconds: 15);
