import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Catatan: Jika ingin menggunakan library external seperti 'translator', jalankan `flutter pub add translator`
import 'package:translator/translator.dart';

import '../../models/manga.dart';
import '../../services/favorite_service.dart';
import 'iklan.dart';
import 'reader_page.dart';

class Baca extends StatefulWidget {
  final Manga manga;

  const Baca({super.key, required this.manga});

  @override
  State<Baca> createState() => _BacaState();
}

class _BacaState extends State<Baca> {
  Future<bool> _isPremium() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final uid = currentUser.uid;
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!doc.exists) return false;

    final data = doc.data()!;
    if (data["isPremium"] != true) return false;
    if (data["premiumUntil"] == null) return false;

    DateTime expired;
    if (data["premiumUntil"] is Timestamp) {
      expired = (data["premiumUntil"] as Timestamp).toDate();
    } else {
      expired = DateTime.parse(data["premiumUntil"]);
    }

    return expired.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final manga = widget.manga;
    final totalChapter = manga.chapters > 0 ? manga.chapters : 20;
    final chapters = List.generate(
      totalChapter,
          (i) => "Chapter ${totalChapter - i}",
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B14),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF0B0B14),
            elevation: 0,
            leading: _circleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                    .collection('favorites')
                    .doc(manga.malId.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data?.exists ?? false;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _circleButton(
                      customWidget: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey(isFavorite),
                          color: isFavorite ? Colors.redAccent : Colors.white,
                          size: 22,
                        ),
                      ),
                      onTap: () async {
                        if (isFavorite) {
                          await FavoriteService.removeFavorite(manga);
                        } else {
                          await FavoriteService.addFavorite(manga);
                        }
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final isCollapsed = constraints.biggest.height <= kToolbarHeight + (MediaQuery.of(context).padding.top);
                  return isCollapsed
                      ? AutoSizeText(
                    manga.title,
                    maxLines: 1,
                    minFontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  )
                      : const SizedBox.shrink();
                },
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: manga.malId,
                    child: Image.network(
                      manga.imageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF141424),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 60,
                              color: Colors.white24,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                          const Color(0xFF0B0B14),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: MangaDetail(manga: manga),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 18, top: 20, bottom: 12),
              child: Text(
                "Daftar Chapter",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) => ChapterListTile(
                chapterName: chapters[index],
                number: totalChapter - index,
                onTap: () async {
                  final premium = await _isPremium();

                  if (!context.mounted) return;

                  if (premium) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderPage(chapterName: chapters[index]),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IklanPage(chapterName: chapters[index]),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _circleButton({IconData? icon, Widget? customWidget, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: customWidget ?? Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

class MangaDetail extends StatelessWidget {
  final Manga manga;

  const MangaDetail({super.key, required this.manga});

  // Fungsi untuk menerjemahkan sinopsis secara asinkron
  Future<String> _translateSynopsis(String text) async {
    if (text.isEmpty) return "Sinopsis tidak tersedia.";
    try {
      final translator = GoogleTranslator();
      final translation = await translator.translate(text, from: 'en', to: 'id');
      return translation.text;
    } catch (e) {
      // Jika gagal/offline, fallback ke teks asli (Inggris)
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            manga.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _scoreBadge(manga.score),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "${manga.chapters > 0 ? manga.chapters : '?'} Chapters",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: manga.genres.map((g) => GenreChip(genre: g)).toList(),
          ),
          const SizedBox(height: 24),

          const Text(
            "Sinopsis",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),

          // PERUBAHAN UTAMA: Menggunakan FutureBuilder untuk Translate & TextAlign.justify
          FutureBuilder<String>(
            future: _translateSynopsis(manga.synopsis),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  "Menerjemahkan sinopsis...",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13.5, fontStyle: FontStyle.italic),
                );
              }

              final synopsisText = snapshot.data ?? manga.synopsis;

              return Text(
                synopsisText,
                textAlign: TextAlign.justify, // REVISI: Membuat rata kanan kiri
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  height: 1.6,
                  fontSize: 13.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _scoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            score.toString(),
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String genre;
  const GenreChip({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.15), width: 1),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ChapterListTile extends StatelessWidget {
  final String chapterName;
  final int number;
  final VoidCallback onTap;

  const ChapterListTile({
    super.key,
    required this.chapterName,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141424),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chapterName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Ketuk untuk membaca komik",
                      style: TextStyle(color: Colors.white30, fontSize: 11),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}