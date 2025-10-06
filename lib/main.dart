import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/app_state.dart';
import 'core/routes.dart';
import 'core/offline.dart';
import 'core/push.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Offline.init();
  await Push.init();
  final cfgStr = await rootBundle.loadString('assets/config.json');
  final cfg = json.decode(cfgStr) as Map<String, dynamic>;
  final appState = AppState(config: cfg);
  await appState.tryAutoLogin();
  await appState.loadTranslations();

  runApp(
    ChangeNotifierProvider(
      create: (_) => appState,
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (!app.initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APL App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: app.isAuthorized
          ? (app.quickLoginEnabled ? Routes.quickLogin : Routes.main)
          : Routes.auth,
      onGenerateRoute: Routes.onGenerate,
    );
  }
}
