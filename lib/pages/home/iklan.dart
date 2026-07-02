import 'dart:async';
import 'package:flutter/material.dart';
import 'reader_page.dart';

class IklanPage extends StatefulWidget {
  final String chapterName;

  const IklanPage({
    super.key,
    required this.chapterName,
  });

  @override
  State<IklanPage> createState() => _IklanPageState();
}

class _IklanPageState extends State<IklanPage> {
  int countdown = 10;
  final int totalDuration = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (countdown > 0) {
          setState(() {
            countdown--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void bukaChapter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderPage(
          chapterName: widget.chapterName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung progress untuk indikator lingkaran hitung mundur
    final double progress = countdown / totalDuration;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B14), // Konsisten dengan tema MangaZone
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Bagian Atas: Indikator Countdown / Tombol Skip Close
              Align(
                alignment: Alignment.topRight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: countdown > 0
                      ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                        ),
                      ),
                      Text(
                        "$countdown",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: bukaChapter,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Bagian Tengah: Kartu Promo Premium (Visualisasi Iklan Internal)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurpleAccent.withOpacity(0.15),
                      const Color(0xFF141424),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon Iklan Interaktif
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFFF9800), // Warna Gold Premium
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "MANGAZONE PREMIUM",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Bosan menunggu iklan?\nUpgrade ke Premium sekarang untuk menikmati akses instan tanpa gangguan sepuasnya!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bagian Bawah: Tombol Aksi Dinamis
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: countdown == 0 ? 1.0 : 0.4,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: countdown == 0 ? bukaChapter : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      disabledBackgroundColor: Colors.white.withOpacity(0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: countdown == 0 ? 8 : 0,
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                    ),
                    child: Text(
                      countdown > 0 ? "Menunggu Iklan Selesai..." : "Buka Chapter Sekarang",
                      style: TextStyle(
                        color: countdown == 0 ? Colors.white : Colors.white24,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}