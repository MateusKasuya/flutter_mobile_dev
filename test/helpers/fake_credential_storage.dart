import 'package:frota_facil_mobile/services/credential_storage.dart';

/// Implementação em memória de [CredentialStorage] para os testes — evita
/// depender do canal nativo do flutter_secure_storage.
class FakeCredentialStorage implements CredentialStorage {
  FakeCredentialStorage([this._password]);
  String? _password;

  @override
  Future<String?> readPassword() async => _password;

  @override
  Future<void> savePassword(String password) async => _password = password;

  @override
  Future<void> deletePassword() async => _password = null;
}
