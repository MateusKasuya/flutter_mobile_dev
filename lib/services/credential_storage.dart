import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstração para guardar a senha do "lembrar usuário e senha".
///
/// Existe uma interface (em vez de usar [FlutterSecureStorage] direto na tela)
/// por dois motivos: manter a `LoginScreen` testável sem depender do canal
/// nativo — os testes injetam uma implementação em memória — e deixar explícito
/// qual segredo o app persiste.
abstract class CredentialStorage {
  Future<String?> readPassword();
  Future<void> savePassword(String password);
  Future<void> deletePassword();
}

/// Implementação de produção: grava no armazenamento seguro do sistema
/// operacional (Keystore no Android, Keychain no iOS), onde o valor fica
/// criptografado — nunca em texto puro como no `SharedPreferences`.
class SecureCredentialStorage implements CredentialStorage {
  const SecureCredentialStorage([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  static const _passwordKey = 'saved_password';

  @override
  Future<String?> readPassword() => _storage.read(key: _passwordKey);

  @override
  Future<void> savePassword(String password) =>
      _storage.write(key: _passwordKey, value: password);

  @override
  Future<void> deletePassword() => _storage.delete(key: _passwordKey);
}
