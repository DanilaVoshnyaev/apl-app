import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/routes.dart';
import 'quick_login.dart';
import 'package:hive_flutter/hive_flutter.dart';

class QuickLoginPage extends StatefulWidget {
  const QuickLoginPage({super.key});

  @override
  State<QuickLoginPage> createState() => _QuickLoginPageState();
}

class _QuickLoginPageState extends State<QuickLoginPage> {
  @override
  void initState() {
    super.initState();
    _tryQuickLogin();
  }

  Future<void> _tryQuickLogin() async {
    final app = context.read<AppState>();

    // Сначала пробуем биометрию
    final biometricOk = await QuickLogin.authenticate(context);
    if (biometricOk) {
      Navigator.pushReplacementNamed(context, Routes.balance);
      return;
    }

    // Если биометрия недоступна или отказана → показываем ввод PIN
    final box = await Hive.openBox('settings');
    final pin = box.get('pin');
    if (pin != null) {
      final entered = await _askPin();
      if (entered == pin) {
        Navigator.pushReplacementNamed(context, Routes.balance);
        return;
      }
    }

    // если ничего не сработало → обычная авторизация
    await app.setQuickLoginEnabled(false);
    Navigator.pushReplacementNamed(context, Routes.auth);
  }

  Future<String?> _askPin() async {
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Введите PIN"),
        content: TextField(
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          onSubmitted: Navigator.of(context).pop,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
