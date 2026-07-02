import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      // Proses Sign Out dari Firebase dan Google
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      if (!context.mounted) return;

      // Bersihkan stack navigasi dan arahkan kembali ke LoginPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
            (route) => false,
      );
    } catch (e) {
      debugPrint("Error saat logout: $e");
      // Fallback jika terjadi kendala pada GoogleSignIn, tetap tendang ke LoginPage
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF141424), // Menyatu dengan tema gelap MangaZone
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.04), width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Keluar Akun",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      content: Text(
        "Apakah Anda yakin ingin logout dari MangaZone? Anda perlu masuk kembali untuk mengakses daftar favorit.",
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actions: [
        // Tombol Batal (Aksi Aman)
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Batal",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),

        // Tombol Logout (Aksi Destruktif)
        ElevatedButton(
          onPressed: () => logout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ],
    );
  }
}