import 'package:flutter/material.dart';
import 'offline.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AppState extends ChangeNotifier {
  final Map<String, dynamic> config;

  String? _token;
  bool _offline = false;
  bool _isAuthorized = false;
  bool _initialized = false;
  String? _lastError;
  Map<String, dynamic>? _user;

  Map<String, String> _translations = {};

  Map<String, String> get translations => _translations;
  int _langId = 1;

  String? _lastLogin;
  String? _lastPassword;

  /// --- Геттеры ---
  String? get lastError => _lastError;

  bool get isAuthorized => _isAuthorized;

  Map<String, dynamic>? get user => _user;

  String? get token => _token;

  bool get initialized => _initialized;

  bool get offline => _offline;

  int get langId => _langId;

  /// базовый URL API (из конфига или дефолт)
  final Uri _baseUri;

  AppState({required this.config})
      : _token = Offline.readToken(),
        _baseUri = Uri.parse(
          (config['api_url'] as String?) ??
              'https://stand-12.beta-dev.aplgo.com/integration/aplshop/',
        );

  Uri get baseUri => _baseUri;

  bool _quickLoginEnabled = false;

  bool get quickLoginEnabled => _quickLoginEnabled;

  Future<void> setQuickLoginEnabled(bool enabled) async {
    _quickLoginEnabled = enabled;
    final box = await Hive.openBox('settings');
    await box.put('quickLogin', enabled);
    notifyListeners();
  }

  Future<void> loadQuickLoginSetting() async {
    final box = await Hive.openBox('settings');
    _quickLoginEnabled = box.get('quickLogin', defaultValue: false);
  }

  void setOffline(bool v) {
    _offline = v;
    notifyListeners();
  }

  bool _loadingTranslations = false;

  bool get loadingTranslations => _loadingTranslations;

  Future<void> loadTranslations() async {
    _loadingTranslations = true;
    notifyListeners();

    try {
      final data = await _post(
        body: {'source': 'aplshop', 'action': 'GetTranslations'},
      );

      if (data['status'] == 'OK' && data['translations'] != null) {
        _translations = Map<String, String>.from(data['translations']);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки переводов: $e');
    }

    _loadingTranslations = false;
    notifyListeners();
  }

  String L(String key) {
    if (_translations.isEmpty) {
      return key;
    }
    return _translations[key] ?? key;
  }

  void setLang(int lang) async {
    _langId = lang;
    notifyListeners();
    await loadTranslations();
  }

  /// --- Балансы пользователя ---
  Future<Map<String, dynamic>?> fetchBalances() async {
    try {
      final data = await _post(
        body: {
          'source': 'aplshop',
          'action': 'GetPartnerBalance',
          'token': _token ?? '',
        },
        headers: {
          'Authorization': 'Bearer ${_token ?? ''}',
        },
      );

      if (data['status'] == 'OK' && data['balance'] != null) {
        return Map<String, dynamic>.from(data);
      } else {
        debugPrint('Ошибка загрузки баланса: ${data['message']}');
      }
    } catch (e) {
      debugPrint('Ошибка получения баланса: $e');
    }
    return null;
  }

  /// Универсальный POST-запрос
  Future<Map<String, dynamic>> _post({
    required Map<String, String> body,
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final mergedQuery = {
      ..._baseUri.queryParameters,
      ...?query,
      'SET_LANG_ID': '$_langId',
      'letmein': 'Ncb4VNysLz',
    };

    final uri = _baseUri.replace(queryParameters: mergedQuery);

    final response = await http.post(
      uri,
      body: body,
      headers: {
        'User-Agent': 'aplgo.com bot v1.2.1',
        if (headers != null) ...headers,
      },
    );

    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<void> loginWithPassword(String phone, String password) async {
    _offline = !(await Offline.hasNetwork());
    if (_offline) {
      notifyListeners();
      return;
    }

    try {
      final data = await _post(
        body: {
          'source': 'aplshop',
          'action': 'Auth',
          'token': 'aba8d512b4808a9de7b09cf5dfc53ba3',
          'devid': 'api',
          'loginOrEmail': phone.trim(),
          'password': password.trim(),
          'state': 'Чувашская Республика — Чувашия',
          'client_id': 'dev.aplshop.com',
          'client_secret':
              'AIgL0HTUT2aYsyrYoxkLbPGaiHLpHjWjg3B1ywHGMQS2ctXrTvP6e6XTv9dI47ys'
        },
      );

      if (data['status'] == 'OK') {
        _token = data['bearerToken'];
        _user = Map<String, dynamic>.from(data['user_data']);
        _isAuthorized = true;
        _lastError = null;

        final box = await Hive.openBox('auth');
        await box.put('token', _token);
        await box.put('user', _user);
      } else {
        _isAuthorized = false;
        _lastError = data['message'] ?? 'Ошибка входа';
      }
    } catch (e) {
      _isAuthorized = false;
      _lastError = 'Ошибка соединения: $e';
    }

    notifyListeners();
  }

  /// --- Выход ---
  Future<void> logout() async {
    final box = await Hive.openBox('auth');
    await box.clear();

    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('quickLogin', false);

    _isAuthorized = false;
    _quickLoginEnabled = false;
    _token = null;
    _user = null;
    notifyListeners();
  }

  /// --- Новости ---
  Future<List<Map<String, dynamic>>> fetchNews() async {
    try {
      final data = await _post(body: {
        'source': 'aplshop',
        'action': 'GetNews',
        'token': _token ?? '',
      });
      if (data['status'] == 'OK' && data['news'] != null) {
        return (data['news'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки новостей: $e');
    }
    return [];
  }

  /// --- Промо ---
  Future<List<Map<String, dynamic>>> fetchPromo() async {
    try {
      final data = await _post(body: {
        'source': 'aplshop',
        'action': 'GetPromo',
        'token': _token ?? '',
      });
      if (data['status'] == 'OK' && data['promo'] != null) {
        return (data['promo'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки промоушенов: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final now = DateTime.now();
      final dateEnd =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final dateStart =
          "${now.year - 1}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final data = await _post(
        body: {
          'source': 'aplshop',
          'action': 'GetOrders',
          'token': _token ?? '',
          'date_start': dateStart,
          'date_end': dateEnd,
        },
        headers: {
          'Authorization': 'Bearer ${_token ?? ''}',
        },
      );

      if (data['status'] == 'OK' && data['data'] != null) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки заказов: $e');
    }
    return [];
  }

  /// --- Бонусная активность ---
  Future<Map<String, dynamic>?> getBonusActivityData(
      {bool reload = false}) async {
    try {
      final data = await _post(
        body: {
          'source': 'aplshop',
          'action': 'getBonusActivityData',
          'reload': reload ? '1' : '0',
        },
        headers: {
          'Authorization': 'Bearer ${_token ?? ''}',
        },
      );

      if (data['status'] == 'OK' && data['response'] != null) {
        return Map<String, dynamic>.from(data['response']);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки бонусной активности: $e');
    }
    return null;
  }

  /// --- Автовход ---
  Future<void> tryAutoLogin() async {
    final box = await Hive.openBox('auth');
    final savedToken = box.get('token');
    final savedUser = box.get('user');

    final settingsBox = await Hive.openBox('settings');
    _quickLoginEnabled = settingsBox.get('quickLogin', defaultValue: false);

    if (savedToken != null && savedUser != null) {
      _token = savedToken;
      _user = Map<String, dynamic>.from(savedUser);
      _isAuthorized = true;
    } else {
      _isAuthorized = false;
    }
    _initialized = true;
    notifyListeners();
  }

  /// --- Уведомления ---
  Future<Map<String, dynamic>?> fetchNotifications(
      {bool archive = false}) async {
    try {
      final data = await _post(
        body: {
          'source': 'aplshop',
          'action': 'GetNotifications',
          'token': _token ?? '',
          if (archive) 'archive': '1',
        },
        headers: {
          'Authorization': 'Bearer ${_token ?? ''}',
        },
      );
      if (data['status'] == 'OK') return data;
    } catch (e) {
      debugPrint('Ошибка загрузки уведомлений: $e');
    }
    return null;
  }

  /// --- Архивация одного уведомления ---
  Future<bool> archiveNotification(int id) async {
    try {
      final data = await _post(
        body: {
          'source': 'aplshop',
          'action': 'GetNotifications',
          'token': _token ?? '',
          'action_open': 'archive',
          'id': '$id',
        },
        headers: {
          'Authorization': 'Bearer ${_token ?? ''}',
        },
      );
      return data['status'] == 'OK';
    } catch (e) {
      debugPrint('Ошибка архивации: $e');
      return false;
    }
  }

  /// --- Архивация всех уведомлений ---
  Future<bool> archiveAllNotifications() async {
    try {
      final data = await _post(
        body: {
          'source': 'aplshop',
          'action': 'GetNotifications',
          'token': _token ?? '',
          'action_open': 'alltoarchive',
        },
        headers: {
          'Authorization': 'Bearer ${_token ?? ''}',
        },
      );
      return data['status'] == 'OK';
    } catch (e) {
      debugPrint('Ошибка архивации всех: $e');
      return false;
    }
  }
}
