import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/routes.dart';
import '../header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user ?? {};

    return Scaffold(
      appBar: CustomHeader(showBack: true),
      body: user.isEmpty
          ? const Center(child: Text("Нет данных пользователя"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Аватар
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user["avatar"] != null
                        ? NetworkImage(
                            "https://backoffice.aplgo.com${user["avatar"]}")
                        : const AssetImage("assets/images/logo.png")
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    (user["fname"] ?? "").toString() +
                        " " +
                        (user["lname"] ?? "").toString() +
                        " " +
                        (user["mname"] ?? "").toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  if (user["email"] != null)
                    Text(user["email"],
                        style: const TextStyle(color: Colors.grey)),
                  if (user["phone"] != null)
                    Text(user["phone"],
                        style: const TextStyle(color: Colors.grey)),

                  const Spacer(),

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
                            DropdownMenuItem(
                                value: 13, child: Text("Français")),
                          ],
                        ),
                      ),
                    ],
                  ),

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
                      onPressed: () async {
                        await app.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, Routes.auth);
                        }
                      },
                      child: Text(app.L('logout_in_acc'),
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
