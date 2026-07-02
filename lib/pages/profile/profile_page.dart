import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    return DateFormat('dd MMM yyyy').format(date);
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
      // Konsisten dengan skema warna gelap bioskop aplikasi kita
      backgroundColor: const Color(0xFF0B0B14),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              const Text(
                "My",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "Profile",
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF0B0B14),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false, // Bersih tanpa tombol back otomatis
        actions: [
          // Tombol setting dipindah ke pojok kanan atas agar clean dan pro
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _circleButton(
              icon: Icons.settings_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          children: [
            // KARTU PROFIL UTAMA (Gaya Cyber & Premium Neon)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // Jika premium dapet efek gradasi emas-ungu neon, jika reguler dapet ungu-gelap
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPremium
                      ? [const Color(0xFF1E1435), const Color(0xFF2D1B2A)]
                      : [const Color(0xFF141424), const Color(0xFF1B1435)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isPremium
                      ? Colors.amberAccent.withOpacity(0.15)
                      : Colors.deepPurpleAccent.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Avatar dengan Indikator Border Interaktif
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isPremium
                                  ? [Colors.amber, Colors.orangeAccent]
                                  : [Colors.deepPurpleAccent, Colors.purpleAccent],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: const Color(0xFF0B0B14),
                            backgroundImage: profileProvider,
                            child: profileProvider == null
                                ? const Icon(
                              Icons.person_rounded,
                              size: 55,
                              color: Colors.white24,
                            )
                                : null,
                          ),
                        ),
                        // Tombol edit foto kecil di pojok avatar
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _isPremium ? Colors.amber : Colors.deepPurpleAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0B0B14), width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama User
                  Text(
                    _user?.displayName ?? "MangaZone User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email User
                  Text(
                    _user?.email ?? "pembaca@mangazone.com",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // KONDISI BADGE PREMIUM ATAU TOMBOL UPGRADE
                  if (_isPremium) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.withOpacity(0.15), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 24),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Premium Member",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Aktif s.d ${_formatDate(_premiumUntil)}",
                                style: TextStyle(
                                  color: Colors.amber.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    // Tombol Upgrade Gaya Moderen & Sporty
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PremiumPage()),
                          );
                          _loadPremiumStatus();
                        },
                        icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                        label: const Text(
                          "Upgrade ke Premium",
                          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KARTU DETAIL INFORMASI AKUN (Sleek Dark List)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141424),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.02)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildProfileTile(
                      icon: Icons.person_outline_rounded,
                      title: "Nama",
                      value: _user?.displayName ?? "-",
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      icon: Icons.mail_outline_rounded,
                      title: "Email",
                      value: _user?.email ?? "-",
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      icon: Icons.verified_user_outlined,
                      title: "Email Terverifikasi",
                      value: _user?.emailVerified == true ? "Ya, Terverifikasi" : "Belum",
                      valueColor: _user?.emailVerified == true ? Colors.greenAccent : Colors.white38,
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      icon: Icons.calendar_today_rounded,
                      title: "Tanggal Pembuatan Akun",
                      value: _user?.metadata.creationTime
                          ?.toLocal()
                          .toString()
                          .split(" ")
                          .first ?? "-",
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      icon: Icons.access_time_rounded,
                      title: "Login Terakhir",
                      value: _user?.metadata.lastSignInTime
                          ?.toLocal()
                          .toString()
                          .replaceFirst(".000", "") ?? "-",
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

  // Widget Pembantu: Membuat item list profile yang elegan
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = Colors.white70,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurpleAccent.withOpacity(0.6), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.03),
      indent: 58,
      endIndent: 20,
      height: 1,
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}