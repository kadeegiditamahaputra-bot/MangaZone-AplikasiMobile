import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/manga.dart';
import '../home/Baca.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B14),
        body: Center(
          child: Text(
            "User tidak valid. Silakan login kembali.",
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B14),
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              const Text(
                "Koleksi",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "Favorit",
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _FavoriteShimmerLoading();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_border_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Belum ada manga favorit",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final favorites = snapshot.data!.docs;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final doc = favorites[index];
              final data = doc.data() as Map<String, dynamic>;

              // Mengambil info visual dasar untuk UI listview item
              final String imageUrl = data['imageUrl'] ?? data['image_url'] ?? '';
              final String title = data['title'] ?? 'No Title';
              final List genresList = data['genres'] is List ? data['genres'] : [];
              final double score = double.tryParse(data['score']?.toString() ?? '0.0') ?? 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141424),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.02)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      try {
                        // SOLUSI: Konversi data map utuh dari Firestore menggunakan constructor model bawaan kamu
                        // Ini otomatis mengisi synopsis, chapters, malId, dll jika data tersebut ada di Firestore
                        Manga mangaObject;

                        if (data.containsKey('malId') || data.containsKey('synopsis')) {
                          // Jika data di dokumen favorites sudah lengkap, pakai data map tersebut
                          mangaObject = Manga.fromJson(data);
                        } else {
                          // Jika data di favorites hanya data singkat, kita inject fallback string kosong agar model tidak crash null
                          final completeData = Map<String, dynamic>.from(data);
                          completeData['id'] ??= doc.id;
                          completeData['synopsis'] ??= '';
                          completeData['chapters'] ??= 0;
                          completeData['volumes'] ??= 0;
                          completeData['type'] ??= 'Manga';
                          completeData['status'] ??= 'Finished';

                          mangaObject = Manga.fromJson(completeData);
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Baca(manga: mangaObject),
                          ),
                        );
                      } catch (e) {
                        // Tolong cek Log jika masih ada error field, nama constructor modelmu mungkin 'fromMap' bukan 'fromJson'
                        debugPrint("Error Parsing Model Manga: $e");

                        // Fallback darurat jika ada perbedaan penamaan constructor model di project-mu:
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Gagal memuat detail manga: $title"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    splashColor: Colors.deepPurpleAccent.withOpacity(0.1),
                    highlightColor: Colors.transparent,
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // SISI KIRI: Poster Manga
                          SizedBox(
                            width: 85,
                            height: 115,
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF1C1C30),
                                child: const Icon(Icons.broken_image_rounded, color: Colors.white24),
                              ),
                            )
                                : Container(
                              color: const Color(0xFF1C1C30),
                              child: const Icon(Icons.image_not_supported_rounded, color: Colors.white24),
                            ),
                          ),

                          // SISI TENGAH: Info Detail Teks
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    genresList.isNotEmpty ? genresList.join(", ") : "No Genres",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$score",
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),

                          // SISI KANAN: Tombol Hapus Favorit dengan Konfirmasi
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _showRemoveDialog(context, uid, doc.id, title);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, String uid, String docId, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Hapus dari Favorit?",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Apakah kamu yakin ingin menghapus '$title' dari daftar koleksimu?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: Colors.white60),
                        child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('favorites')
                              .doc(docId)
                              .delete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteShimmerLoading extends StatefulWidget {
  const _FavoriteShimmerLoading();

  @override
  State<_FavoriteShimmerLoading> createState() => _FavoriteShimmerLoadingState();
}

class _FavoriteShimmerLoadingState extends State<_FavoriteShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.4),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              height: 115,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF141424),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}