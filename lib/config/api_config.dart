/// Configuração centralizada da API.
/// Trocar para o endereço de produção quando necessário.
const String apiBaseUrl = 'fretefacilweb.ccmcloud.com.br:8624';

/// Tempo máximo de espera por resposta de cada requisição HTTP. Sem isso, uma
/// conexão que trava (portal cativo, perda de pacotes após conectar) deixaria
/// a UI girando até o timeout de socket do SO (1-2+ min).
const Duration apiTimeout = Duration(seconds: 15);
