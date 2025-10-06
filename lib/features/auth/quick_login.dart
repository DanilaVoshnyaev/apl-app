import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class QuickLogin {
  static final _auth = LocalAuthentication();

  /// Проверяем, можно ли использовать биометрию
  static Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint("Biometric check error: $e");
      return false;
    }
  }

  /// Запускаем аутентификацию
  static Future<bool> authenticate(BuildContext context) async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Войдите для подтверждения',
        options: const AuthenticationOptions(
          biometricOnly: false, // разрешаем PIN/графический ключ
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint("Biometric auth error: $e");
      return false;
    }
  }

  /// Получить список доступных методов (FaceID, TouchID и т.д.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint("Get biometrics error: $e");
      return [];
    }
  }
}
