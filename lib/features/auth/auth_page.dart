import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_state.dart';
import '../../core/routes.dart';
import 'quick_login.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _login = TextEditingController();
  final _pass = TextEditingController();
  bool _biometricAvailable = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    QuickLogin.canUseBiometrics().then(
      (v) => setState(() => _biometricAvailable = v),
    );
  }

  Future<void> _doLogin() async {
    final app = context.read<AppState>();
    await app.loginWithPassword(_login.text.trim(), _pass.text.trim());

    if (app.isAuthorized) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.balance);
        if (_biometricAvailable) {
          final enable = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(app.L('quick_login_title')),
              content: Text(app.L('quick_login_question')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(app.L('no')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(app.L('yes')),
                ),
              ],
            ),
          );

          if (enable == true) {
            await app.setQuickLoginEnabled(true);
          }
        }
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      app.L('error_title'),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      app.lastError ?? 'Произошла ошибка',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(app.L('ok_button')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _doBiometric() async {
    final ok = await QuickLogin.authenticate(context);
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, Routes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                "assets/images/logo.svg",
                height: 80,
              ),
              const SizedBox(height: 24),
              Text(
                app.L('login_title'),
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 32),
              if (app.offline)
                Text(
                  app.L('offline_mode'),
                  style: TextStyle(color: Colors.orange),
                ),
              // Поле логина
              TextField(
                controller: _login,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: app.L('partner_id'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _pass,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: app.L('password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопка входа
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _doLogin,
                  child: Text(
                    app.L('login_button').trim(),
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Быстрый вход
              if (_biometricAvailable)
                OutlinedButton(
                  onPressed: _doBiometric,
                  child: Text(app.L('biometric_login')),
                ),

              const SizedBox(height: 32),

              Row(
                children: [
                  const Icon(Icons.language, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: app.langId,
                      onChanged: (value) {
                        if (value != null) {
                          app.setLang(value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Русский")),
                        DropdownMenuItem(value: 2, child: Text("English")),
                        DropdownMenuItem(value: 3, child: Text("Español")),
                        DropdownMenuItem(value: 4, child: Text("Deutsch")),
                        DropdownMenuItem(value: 5, child: Text("Română")),
                        DropdownMenuItem(value: 7, child: Text("Italiano")),
                        DropdownMenuItem(value: 10, child: Text("Türkçe")),
                        DropdownMenuItem(value: 13, child: Text("Français")),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Забыли пароль
              TextButton(
                onPressed: () {
                  // переход на экран восстановления пароля
                },
                child: Text(
                  app.L('forgot_password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
