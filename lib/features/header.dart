import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/web_container.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'componets/share.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text("Главная страница"),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;

  const CustomHeader({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
      title: Row(
        children: [
          SvgPicture.asset(
            "assets/images/logo.svg",
            height: 24,
          ),
          const SizedBox(width: 8),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            showSharingPopup(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            Navigator.pushNamed(context, Routes.notification);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.profile);
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                'https://backoffice.aplgo.com/userfiles/avatars/33224/c6ea9042030ede1e270b1c169011acff.jpeg',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                const SizedBox(height: 24),
                Builder(
                    builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                        })),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.main);
                  },
                  child: SvgPicture.asset(
                    "assets/images/logo.svg",
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _drawerItemLink(context, Icons.storefront, "Магазин",
              "https://stand-12.beta-dev.aplgo.com/index/partneram/buy/magazine/"),
          _drawerItem(context, Icons.balance, "Баланс", Routes.balance),
          ExpansionTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text("База знаний"),
            children: [
              _drawerItemLink(
                context,
                Icons.arrow_right,
                "APL OFFICE",
                "https://aploffice.com/",
              ),
              _drawerItemLink(
                context,
                Icons.arrow_right,
                "Маркетинг-план",
                "https://stand-12.beta-dev.aplgo.com/index/partneram/knowledgebase/marketing-plan/",
              ),
              _drawerItemLink(
                context,
                Icons.arrow_right,
                "Документы",
                "https://stand-12.beta-dev.aplgo.com/index/partneram/knowledgebase/docs/",
              ),
              _drawerItemLink(
                context,
                Icons.arrow_right,
                "Обучающие видео по BackOffice",
                "https://stand-12.beta-dev.aplgo.com/index/partneram/knowledgebase/educational_videos/",
              ),
              _drawerItemLink(
                context,
                Icons.arrow_right,
                "Календарь событий",
                "https://aploffice.com/calendar/",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawerItemLink(
      BuildContext context, IconData icon, String title, String url) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebContainer(url: url, title: title),
          ),
        );
      },
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return new Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.grey[800]),
            title: Text(title),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, route);
            },
          ),
        ],
      ),
    );
  }
}
