import 'package:flutter/material.dart';
import '../../pages/login/logout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info,
                color: Colors.blue,
              ),
              title: const Text("Tentang MangaZone"),
              subtitle: const Text("Versi 1.0.0"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "MangaZone",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2026 MangaZone",
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text("Logout"),
              subtitle: const Text("Keluar dari akun"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogoutPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}