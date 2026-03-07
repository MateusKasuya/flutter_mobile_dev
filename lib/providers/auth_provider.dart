import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String _token = '';

  String get token => _token;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
}
