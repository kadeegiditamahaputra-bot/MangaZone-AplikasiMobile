import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  // PERBAIKAN: Fungsi _isPremium dipindahkan ke dalam State class
  Future<bool> _isPremium() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false; // Antisipasi jika user belum login

    final uid = currentUser.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

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
      backgroundColor: const Color(0xFFF7F8FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF6A11CB),
            leading: _circleButton(
              icon: Icons.arrow_back_ios_new,
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

                  return FavoriteButton(
                    isFavorite: isFavorite,
                    onTap: () async {
                      if (isFavorite) {
                        await FavoriteService.removeFavorite(manga);
                      } else {
                        await FavoriteService.addFavorite(manga);
                      }
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Tooltip(
                message: manga.title,
                child: AutoSizeText(
                  manga.title,
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: manga.malId,
                    child: Image.network(
                      manga.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 60, color: Colors.grey),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8),
                        ],
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
          // Judul Daftar Chapter diletakkan di sini agar rapi sebelum list
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Text(
                "Daftar Chapter",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ChapterListTile(
                chapterName: chapters[index],
                number: totalChapter - index,
                onTap: () async {
                  final premium = await _isPremium();

                  if (!context.mounted) return;

                  if (premium) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderPage(
                          chapterName: chapters[index],
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IklanPage(
                          chapterName: chapters[index],
                        ),
                      ),
                    );
                  }
                },
              ),
              childCount: chapters.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteButton(
      {super.key, required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
          color: Colors.red,
          size: 30,
        ),
      ),
      onPressed: onTap,
    );
  }
}

class MangaDetail extends StatelessWidget {
  final Manga manga;

  const MangaDetail({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: manga.title,
            child: AutoSizeText(
              manga.title,
              maxLines: 2,
              minFontSize: 14,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _scoreBadge(manga.score),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: manga.genres.map((g) => GenreChip(genre: g)).toList(),
          ),
          const SizedBox(height: 25),
          const Text("Sinopsis",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(manga.synopsis, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  Widget _scoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 18, color: Colors.orange),
          const SizedBox(width: 5),
          Text(score.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            chapterName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text("Tap untuk membaca"),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
        ),
      ),
    );
  }
}