import 'package:apl_app/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import '../features/auth/auth_page.dart';
import '../features/balance/balance_page.dart';
import '../features/main/main_page.dart';
import '../features/auth/quick_login_page.dart';
import '../features/notification/notifications_page.dart';
import '../features/bonus/bonus_page.dart';

import '../features/orders/orders.dart';

class Routes {
  static const auth = '/auth';
  static const quickLogin = '/quick_login';
  static const balance = '/balance';
  static const news = '/news';
  static const promo = '/promo';
  static const bonus = '/bonus';
  static const main = '/main';
  static const profile = '/profile';
  static const notification = '/notification';

  static Route<dynamic> onGenerate(RouteSettings s) {
    switch (s.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case quickLogin:
        return MaterialPageRoute(builder: (_) => const QuickLoginPage());
      case balance:
        return MaterialPageRoute(builder: (_) => const BalancePage());
      case main:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case bonus:
        return MaterialPageRoute(builder: (_) => const BonusActivityPage());
      default:
        return MaterialPageRoute(builder: (_) => const MainPage());
    }
  }
}
