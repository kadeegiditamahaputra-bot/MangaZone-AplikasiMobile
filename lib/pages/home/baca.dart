import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // 🔹 Tambahin package ini
import '../../models/manga.dart';
import '../../services/favorite_manager.dart';


class Baca extends StatefulWidget {
  final Manga manga;

  const Baca({super.key, required this.manga});

  @override
  State<Baca> createState() => _BacaState();
}

class _BacaState extends State<Baca> {
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
              FavoriteButton(
                isFavorite: manga.isFavorite,
                onTap: () {
                  setState(() {
                    if (manga.isFavorite) {
                      FavoriteManager.removeFavorite(manga);
                    } else {
                      FavoriteManager.addFavorite(manga);
                    }
                    manga.isFavorite = !manga.isFavorite;
                  });
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Tooltip(
                message: manga
                    .title, // 🔹 tampilkan judul penuh saat hover/long press
                child: AutoSizeText(
                  manga.title,
                  maxLines: 1,
                  minFontSize: 12, // 🔹 otomatis mengecil kalau kepanjangan
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
                    child: Image.network(manga.imageUrl, fit: BoxFit.cover),
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ChapterListTile(
                chapterName: chapters[index],
                number: totalChapter - index,
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
            message: manga.title, // 🔹 tooltip juga di detail
            child: AutoSizeText(
              manga.title,
              maxLines: 2, // 🔹 di detail boleh 2 baris
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
          const Text("Daftar Chapter",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

  const ChapterListTile(
      {super.key, required this.chapterName, required this.number});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Membuka $chapterName")),
      ),
      child: Container(
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
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "$number",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          title: Text(chapterName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text("Tap untuk membaca"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        ),
      ),
    );
  }
}
