import 'pages/login/auth_wrapper.dart';
//import 'pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/transaksi/notifikasi_pembayaran.dart';

// Pages MangaZone
import 'pages/home/home_page.dart';
import 'pages/favorite/favorite_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/transaksi/transaksi_page.dart';

// SQFlite Multi Platform
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Desktop only
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init Database (multi platform)
  if (kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menyelaraskan warna dasar aplikasi ke Dark Mode secara menyeluruh
        scaffoldBackgroundColor: const Color(0xFF0B0B14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark, // Mengaktifkan optimasi sistem berbasis gelap
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Menggunakan PageController agar perpindahan halaman bisa dianimasikan dengan mulus (Slick)
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Background disamakan persis dengan warna bioskop digital HomePage
      backgroundColor: const Color(0xFF0B0B14),

      // Menggunakan Stack agar bar navigasi bisa mengambang (Floating Effect) di atas konten jika diinginkan
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Menghindari ketidaksengajaan geser manual swipe
        children: const [
          HomePage(),
          FavoritePage(),
          TransaksiPage(),
          ProfilePage(),
        ],
      ),

      // Desain Bar Navigasi Premium Custom Menyaingi Aplikasi Streaming Global
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B14),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.04), // Garis pembatas tipis yang sangat elegan
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorite'),
                _buildNavItem(2, Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Transaksi'),
                _buildProfileNavItem(3, user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builder Item Navigasi Kustom Beranimasi Neon
  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Membuat background kapsul menyala saat ikon aktif
          color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? Colors.deepPurpleAccent : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.deepPurpleAccent : Colors.white38,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builder Khusus untuk Foto Profil Google Agar Presisi dan Mewah
  Widget _buildProfileNavItem(int index, User? user) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Bingkai bersinar tipis warna ungu di sekitar foto jika dipilih
                border: Border.all(
                  color: isSelected ? Colors.deepPurpleAccent : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: user?.photoURL != null
                  ? CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(user!.photoURL!),
              )
                  : Icon(
                isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
                color: isSelected ? Colors.deepPurpleAccent : Colors.white60,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Profile',
              style: TextStyle(
                color: isSelected ? Colors.deepPurpleAccent : Colors.white38,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}