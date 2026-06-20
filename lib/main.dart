import 'pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_selectedIndex) {
      case 0:
        currentPage = const HomePage();
        break;
      case 1:
        currentPage = const FavoritePage();
        break;
      case 2:
        currentPage = const TransaksiPage();
        break;
      case 3:
        currentPage = const ProfilePage();
        break;
      default:
        currentPage = const HomePage();
    }

    // Ambil user Google
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'transaksi',
          ),
          BottomNavigationBarItem(
            icon: user?.photoURL != null
                ? CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(user!.photoURL!),
            )
                : const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
