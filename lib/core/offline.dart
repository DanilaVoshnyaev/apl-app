import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Offline {
  static const _tokenKey = 'auth_token';
  static const _secure = FlutterSecureStorage();
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('app_box');
  }

  static Future<bool> hasNetwork() async {
    final r = await Connectivity().checkConnectivity();
    return r != ConnectivityResult.none;
  }

  static void saveToken(String token) {
    _box.put(_tokenKey, token);
    _secure.write(key: _tokenKey, value: token);
  }

  static String? readToken() {
    final t = _box.get(_tokenKey) as String?;
    return t;
  }

  static void clearToken() {
    _box.delete(_tokenKey);
    _secure.delete(key: _tokenKey);
  }
}
