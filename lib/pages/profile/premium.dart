import 'package:flutter/material.dart';
import 'konfirmasi.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B14), // Tema Gelap MangaZone
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MangaZone Premium',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header Badge Premium berkilau
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.withOpacity(0.2), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 72,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Nikmati Manga Tanpa Iklan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Baca manga lebih nyaman tanpa gangguan iklan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Opsi paket asli (tidak diubah, hanya didesain ulang)
              _premiumCard(
                context,
                title: "3 Bulan",
                price: "Rp25.000",
                isPopular: true, // Variasi desain aksen emas
              ),

              _premiumCard(
                context,
                title: "1 Tahun",
                price: "Rp80.000",
                isPopular: false, // Variasi desain aksen ungu
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumCard(
      BuildContext context, {
        required String title,
        required String price,
        required bool isPopular,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141424),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? Colors.amber.withOpacity(0.4) : Colors.white.withOpacity(0.03),
          width: isPopular ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            // Icon Badge paket
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPopular ? Colors.amber.withOpacity(0.12) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.workspace_premium,
                color: isPopular ? Colors.amber : Colors.white54,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Detail Teks Paket
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: isPopular ? Colors.amber : Colors.white60,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Beli (Logika Asli Tetap Sama)
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KonfirmasiPage(
                      paket: title,
                      harga: price,
                    ),
                  ),
                );

                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? Colors.amber : Colors.deepPurpleAccent,
                foregroundColor: isPopular ? const Color(0xFF0B0B14) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Beli",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: isPopular ? const Color(0xFF0B0B14) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}