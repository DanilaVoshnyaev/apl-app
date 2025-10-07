import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Offline {
  static const _tokenKey = 'auth_token';
  static const _secure = FlutterSecureStorage();
  static late Box _box;

  static const int _defaultTTL = 1000 * 60 * 60 * 24; // 24 часа

  static Future<void> init() async {
    _box = await Hive.openBox('app_box');
  }

  static Future<bool> hasNetwork() async {
    final r = await Connectivity().checkConnectivity();
    return r != ConnectivityResult.none;
  }

  static Future<void> saveToken(String token) async {
    await _box.put(_tokenKey, token);
    await _secure.write(key: _tokenKey, value: token);
  }

  /// Чтение токена
  static String? readToken() {
    return _box.get(_tokenKey) as String?;
  }

  /// Очистка токена
  static Future<void> clearToken() async {
    await _box.delete(_tokenKey);
    await _secure.delete(key: _tokenKey);
  }

  /// Сохранить кэш (например новости, баланс и т.д.)
  static Future<void> saveCache(String key, dynamic data,
      {int ttl = _defaultTTL}) async {
    final record = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl,
      'data': jsonEncode(data),
    };
    await _box.put(key, record);
  }

  /// Прочитать кэш (если не устарел)
  static Future<T?> readCache<T>(String key) async {
    final record = _box.get(key);
    if (record == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final created = record['timestamp'] as int;
    final ttl = record['ttl'] as int;

    if (now - created > ttl) {
      // устарел — удаляем
      await _box.delete(key);
      return null;
    }

    try {
      final decoded = jsonDecode(record['data']);
      return decoded as T;
    } catch (_) {
      return null;
    }
  }

  /// Принудительное удаление кэша
  static Future<void> clearCache(String key) async {
    await _box.delete(key);
  }

  /// Очистить всё
  static Future<void> clearAll() async {
    await _box.clear();
    await _secure.deleteAll();
  }
}
