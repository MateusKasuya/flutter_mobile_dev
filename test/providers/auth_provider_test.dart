import 'package:flutter_test/flutter_test.dart';
import 'package:frota_facil_mobile/providers/auth_provider.dart';
import 'package:frota_facil_mobile/services/token_storage.dart';

/// Armazenamento em memória para os testes — evita o canal nativo do
/// flutter_secure_storage.
class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([this._token]);
  String? _token;

  @override
  Future<String?> readToken() async => _token;
  @override
  Future<void> saveToken(String token) async => _token = token;
  @override
  Future<void> deleteToken() async => _token = null;
}

void main() {
  group('AuthProvider', () {
    test('inicia sem sessão', () {
      final auth = AuthProvider(storage: FakeTokenStorage());
      expect(auth.token, '');
      expect(auth.isAuthenticated, false);
    });

    test('loadToken carrega o token persistido', () async {
      final auth = AuthProvider(storage: FakeTokenStorage('tok-salvo'));
      await auth.loadToken();
      expect(auth.token, 'tok-salvo');
      expect(auth.isAuthenticated, true);
    });

    test('setToken atualiza a memória na hora e persiste', () async {
      final storage = FakeTokenStorage();
      final auth = AuthProvider(storage: storage);

      // Memória atualiza de forma síncrona (antes do await de persistência),
      // por isso o padrão `AuthProvider()..setToken(...)` funciona nos testes.
      final future = auth.setToken('novo-token');
      expect(auth.token, 'novo-token');
      await future;

      // Persistiu: um provider novo com o mesmo storage recupera o token.
      final outro = AuthProvider(storage: storage);
      await outro.loadToken();
      expect(outro.token, 'novo-token');
    });

    test('clearToken limpa memória e armazenamento', () async {
      final storage = FakeTokenStorage('tok');
      final auth = AuthProvider(storage: storage);
      await auth.loadToken();
      expect(auth.isAuthenticated, true);

      await auth.clearToken();
      expect(auth.token, '');
      expect(auth.isAuthenticated, false);

      final outro = AuthProvider(storage: storage);
      await outro.loadToken();
      expect(outro.token, '');
    });

    test('notifica listeners em set e clear', () async {
      final auth = AuthProvider(storage: FakeTokenStorage());
      var count = 0;
      auth.addListener(() => count++);
      await auth.setToken('x');
      await auth.clearToken();
      expect(count, greaterThanOrEqualTo(2));
    });
  });
}
