import 'package:flutter/material.dart';

class ReaderPage extends StatelessWidget {
  final String chapterName;

  const ReaderPage({
    super.key,
    required this.chapterName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang hitam pekat agar gambar manga lebih stand-out dan nyaman di mata
      backgroundColor: const Color(0xFF000000),

      // APP BAR: Dibuat semi-transparan melayang (Glassmorphic vibe)
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B14).withOpacity(0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          chapterName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          // Tombol interaktif tambahan untuk kenyamanan pembaca
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: "Muat Ulang Halaman",
            onPressed: () {
              // Logika refresh jika diperlukan nanti
            },
          ),
        ],
      ),

      body: ListView.builder(
        // Menggunakan physics bouncing khas iOS yang premium saat di-scroll
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero, // Menghilangkan padding bawaan agar gambar penuh ke tepi layar
        itemCount: 10,
        itemBuilder: (context, index) {
          return Image.network(
            "https://picsum.photos/800/1200?random=${index + 1}",
            fit: BoxFit.contain, // Memastikan gambar manga proporsional dan tidak terpotong lebar/tingginya
            width: double.infinity,

            // INDIKATOR LOADING: Dibuat minimalis & estetik dengan Shimmer-effect gaya gelap
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              // Menghitung persentase download jika tersedia
              final totalBytes = loadingProgress.expectedTotalBytes;
              final value = totalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / totalBytes
                  : null;

              return Container(
                height: 550,
                color: const Color(0xFF0B0B14),
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                      backgroundColor: Colors.white10,
                    ),
                  ),
                ),
              );
            },

            // HANDLER ERROR: Dibuat rapi, serasi, dan menyediakan tombol retry visual
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 400,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141424),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Gagal memuat halaman komik",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Halaman ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}