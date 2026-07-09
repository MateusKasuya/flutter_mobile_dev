import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;

/// Callback global disparado quando uma requisição autenticada recebe 401
/// (sessão expirada). O [main] registra aqui uma função que limpa o token e
/// volta para a tela de login.
///
/// Por que uma variável global? O [AuthHttpClient] é criado antes de a árvore
/// de widgets existir (ele é um singleton de longa vida), então não tem como
/// segurar um `BuildContext`. Deixar um ponto de contato global simples entre
/// a camada de rede e a de navegação resolve isso sem acoplar o client ao
/// Flutter/Provider.
void Function()? sessionExpiredHandler;

/// Cliente HTTP compartilhado por todos os serviços autenticados. É um
/// singleton de LONGA VIDA: criado uma vez e reutilizado em todas as
/// requisições — por isso os serviços nunca devem fechá-lo.
final http.Client apiClient = AuthHttpClient(http.Client());

/// Cliente HTTP que centraliza o tratamento de sessão expirada (401).
///
/// Conceito novo de Flutter/Dart: [http.BaseClient] é a classe-base do pacote
/// `http`. Todos os métodos de conveniência (`get`, `post`, ...) acabam
/// passando por um único método: [send]. Estendendo `BaseClient` e
/// sobrescrevendo `send`, interceptamos TODA requisição num só lugar — aqui,
/// para detectar o 401 de expiração de sessão sem repetir esse código em cada
/// um dos ~6 serviços.
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient(this._inner);

  /// Cliente real que efetivamente faz a requisição na rede.
  final http.Client _inner;

  /// Guarda de reentrância. Vários serviços podem estar aguardando respostas
  /// ao mesmo tempo e receber 401 quase juntos; sem esta trava, cada 401
  /// dispararia o handler (limpar token + navegar), empilhando navegações para
  /// o login. O flag garante que o tratamento rode UMA única vez por "rajada":
  /// ele é rearmado só no próximo frame, quando a navegação para o login já
  /// está a caminho.
  bool _expirando = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      _tratarSessaoExpirada();
    }
    // A resposta é sempre repassada ao chamador — o serviço ainda lança a
    // Exception dele; a expiração de sessão é um efeito colateral em paralelo.
    return response;
  }

  void _tratarSessaoExpirada() {
    if (_expirando) return;
    _expirando = true;
    sessionExpiredHandler?.call();
    // Rearma no próximo frame. addPostFrameCallback agenda uma função para
    // rodar logo após o Flutter desenhar o próximo quadro — segurar a trava
    // até lá colapsa a rajada de 401s (as telas antigas já foram substituídas
    // pelo login) e depois volta a permitir tratar uma futura expiração.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _expirando = false;
    });
  }

  @override
  void close() => _inner.close();
}
