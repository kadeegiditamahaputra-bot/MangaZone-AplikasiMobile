import 'package:flutter/material.dart';
import '../../pages/login/logout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Konsisten dengan warna latar belakang gelap bioskop aplikasi kita
      backgroundColor: const Color(0xFF0B0B14),

      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: const Color(0xFF0B0B14),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        // Tombol kembali yang serasi dengan tema aplikasi
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // Kategori Menu: Aplikasi
          _buildSectionTitle("Aplikasi"),
          const SizedBox(height: 8),

          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.blueAccent,
            title: "Tentang MangaZone",
            subtitle: "Versi 1.0.0",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "MangaZone",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2026 MangaZone",
              );
            },
          ),

          const SizedBox(height: 24),

          // Kategori Menu: Akun
          _buildSectionTitle("Akun"),
          const SizedBox(height: 8),

          _buildSettingsTile(
            icon: Icons.logout_rounded,
            iconColor: Colors.redAccent,
            title: "Logout",
            subtitle: "Keluar dari akun kamu",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogoutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget Pembantu: Membuat Judul Sub-Bagian (Section Title)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Widget Pembantu: Membuat Item Menu Pengaturan Premium
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141424), // Box solid gelap ber-shading mewah
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}