import 'package:flutter/foundation.dart';

import '../services/token_storage.dart';

/// Guarda o token de autenticação da sessão e o persiste no armazenamento
/// seguro, permitindo retomar a sessão quando o app é reaberto.
///
/// A memória é sempre a fonte de verdade imediata: [setToken]/[clearToken]
/// atualizam `_token` e notificam ANTES de tocar no armazenamento, e a
/// persistência é best-effort (se o armazenamento seguro falhar, a sessão só
/// não sobrevive a um restart — o app segue funcionando).
class AuthProvider extends ChangeNotifier {
  AuthProvider({TokenStorage? storage})
    : _storage = storage ?? const SecureTokenStorage();

  final TokenStorage _storage;

  String _token = '';

  String get token => _token;

  bool get isAuthenticated => _token.isNotEmpty;

  /// Carrega o token persistido para a memória. Chamado no SplashScreen para
  /// decidir entre Login e Home.
  Future<void> loadToken() async {
    try {
      _token = await _storage.readToken() ?? '';
    } catch (_) {
      // Falha ao ler o armazenamento seguro (raro): trata como não logado.
      _token = '';
    }
    notifyListeners();
  }

  /// Define o token na memória (imediato) e o persiste (best-effort).
  Future<void> setToken(String token) async {
    _token = token;
    notifyListeners();
    try {
      await _storage.saveToken(token);
    } catch (_) {
      // Persistência best-effort — ver doc da classe.
    }
  }

  /// Limpa o token da memória e do armazenamento (logout / sessão expirada).
  Future<void> clearToken() async {
    _token = '';
    notifyListeners();
    try {
      await _storage.deleteToken();
    } catch (_) {
      // best-effort
    }
  }
}
