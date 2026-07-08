import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstração para persistir o token de sessão com segurança.
///
/// Existe uma interface (em vez de usar [FlutterSecureStorage] direto no
/// provider) para manter o [AuthProvider] testável sem depender do canal
/// nativo — os testes injetam uma implementação em memória.
abstract class TokenStorage {
  Future<String?> readToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

/// Implementação de produção: grava no armazenamento seguro do sistema
/// (Keystore no Android, Keychain no iOS). O token dá acesso à API, então é
/// tratado como segredo — nunca vai para o SharedPreferences em texto puro.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _key = 'auth_token';

  @override
  Future<String?> readToken() => _storage.read(key: _key);

  @override
  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  @override
  Future<void> deleteToken() => _storage.delete(key: _key);
}
