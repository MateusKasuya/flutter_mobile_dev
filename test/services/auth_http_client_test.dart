import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frota_facil_mobile/services/auth_http_client.dart';

void main() {
  // O AuthHttpClient rearma a guarda de reentrância num addPostFrameCallback,
  // que precisa do binding do Flutter inicializado. Em teste, esse callback só
  // dispara ao "pumpar" um frame — o que não fazemos aqui de propósito, para
  // que a guarda continue valendo durante os 401s simultâneos.
  TestWidgetsFlutterBinding.ensureInitialized();

  final url = Uri.parse('http://exemplo.test/rota');

  // sessionExpiredHandler é global: zeramos antes e depois de cada teste para
  // não vazar estado entre eles.
  setUp(() => sessionExpiredHandler = null);
  tearDown(() => sessionExpiredHandler = null);

  test('resposta 200 não dispara o handler de sessão expirada', () async {
    var chamadas = 0;
    sessionExpiredHandler = () => chamadas++;

    final client = AuthHttpClient(
      MockClient((_) async => http.Response('ok', 200)),
    );
    final resp = await client.get(url);

    expect(resp.statusCode, 200);
    expect(chamadas, 0);
  });

  test('resposta 401 dispara o handler exatamente uma vez', () async {
    var chamadas = 0;
    sessionExpiredHandler = () => chamadas++;

    final client = AuthHttpClient(
      MockClient((_) async => http.Response('', 401)),
    );
    await client.get(url);

    expect(chamadas, 1);
  });

  test('dois 401 simultâneos disparam o handler só uma vez (reentrância)',
      () async {
    var chamadas = 0;
    sessionExpiredHandler = () => chamadas++;

    final client = AuthHttpClient(
      MockClient((_) async => http.Response('', 401)),
    );
    // Future.wait dispara as duas requisições "ao mesmo tempo"; a guarda deve
    // colapsar os dois 401s num único tratamento.
    await Future.wait([client.get(url), client.get(url)]);

    expect(chamadas, 1);
  });

  test('a resposta 401 ainda é repassada ao chamador', () async {
    sessionExpiredHandler = () {};

    final client = AuthHttpClient(
      MockClient((_) async => http.Response('corpo', 401)),
    );
    final resp = await client.get(url);

    // O wrapper apenas observa o 401; o serviço chamador continua vendo a
    // resposta original para lançar sua própria Exception.
    expect(resp.statusCode, 401);
    expect(resp.body, 'corpo');
  });
}
