import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'settings_page.dart';
import 'premium.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  Uint8List? _webImage;

  final User? _user = FirebaseAuth.instance.currentUser;

  bool _isPremium = false;
  DateTime? _premiumUntil;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    if (_user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(_user!.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    bool premium = data["isPremium"] ?? false;

    DateTime? until;

    final premiumData = data["premiumUntil"];

    if (premiumData != null) {
      if (premiumData is Timestamp) {
        until = premiumData.toDate();
      } else if (premiumData is String) {
        until = DateTime.parse(premiumData);
      }
    }

    setState(() {
      _isPremium = premium;
      _premiumUntil = until;
    });
  }

  Future<void> _pickImage() async {

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        } else {
          setState(() {
            _profileImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint("Error mengambil gambar: $e");
    }
  }
  String _formatDate(DateTime? date) {
    if (date == null) return "-";

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }


  @override
  Widget build(BuildContext context) {
    ImageProvider? profileProvider;

    if (kIsWeb && _webImage != null) {
      profileProvider = MemoryImage(_webImage!);
    } else if (_profileImage != null) {
      profileProvider = FileImage(_profileImage!);
    } else if (_user?.photoURL != null) {
      profileProvider = NetworkImage(_user!.photoURL!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: profileProvider,
                      child: profileProvider == null
                          ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user?.displayName ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _user?.email ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),


                  if (_isPremium) ...[
                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Premium Member",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Aktif sampai\n${_formatDate(_premiumUntil)}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PremiumPage(),
                          ),
                        );

                        _loadPremiumStatus();
                      },
                      icon: const Icon(Icons.workspace_premium),
                      label: const Text("Upgrade Sekarang"),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Nama"),
                      subtitle: Text(_user?.displayName ?? "-"),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text("Email"),
                      subtitle: Text(_user?.email ?? "-"),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: const Text("Email Terverifikasi"),
                      subtitle: Text(
                        _user?.emailVerified == true
                            ? "Ya"
                            : "Belum",
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text("Tanggal Pembuatan Akun"),
                      subtitle: Text(
                        _user?.metadata.creationTime
                            ?.toLocal()
                            .toString()
                            .split(" ")
                            .first ??
                            "-",
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text("Login Terakhir"),
                      subtitle: Text(
                        _user?.metadata.lastSignInTime
                            ?.toLocal()
                            .toString()
                            .replaceFirst(".000", "") ??
                            "-",
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
