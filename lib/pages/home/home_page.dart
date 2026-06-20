import 'package:flutter/material.dart';
import '../../models/manga.dart';
import '../../services/api_service.dart';
import 'Baca.dart';
import '../../services/favorite_manager.dart';
import 'searching.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedGenre = 'Semua';
  late Future<List<Manga>> _mangaFuture;
  final List<String> _genres = [
    'Semua',
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Romance',
    'Sci-Fi',
  ];

  @override
  void initState() {
    super.initState();
    _mangaFuture = ApiService.getTopManga();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined),
              const SizedBox(width: 8),
              const Text(
                "MangaZone",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD54F),
                      Color(0xFFFF9800),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "FREE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchingPage(),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.deepPurple,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Header gradient

          const SizedBox(height: 10),

          // 🔹 Genre filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _genres.length,
              itemBuilder: (_, i) {
                final genre = _genres[i];
                final selected = _selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: selected,
                    selectedColor: Colors.deepPurple,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.deepPurple,
                    ),
                    checkmarkColor: Colors.white, // 🔹 centang jadi putih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          30), // 🔹 lengkungan lebih halus
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedGenre = genre;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 List Manga
          Expanded(
            child: FutureBuilder<List<Manga>>(
              future: _mangaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Data manga tidak ditemukan'));
                }

                // filter sesuai genre
                final mangas = snapshot.data!.where((manga) {
                  if (_selectedGenre == 'Semua') return true;
                  return manga.genres.contains(_selectedGenre);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: mangas.length,
                  itemBuilder: (context, index) {
                    final manga = mangas[index];
                    manga.isFavorite = FavoriteManager.favorites.any(
                      (m) => m.malId == manga.malId,
                    );
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Image.network(
                              manga.imageUrl,
                              width: 110,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    manga.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 20),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${manga.score}",
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // 🔹 Genre chips
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: manga.genres.map((genre) {
                                      return Chip(
                                        label: Text(genre),
                                        backgroundColor:
                                            Colors.deepPurple.shade100,
                                        labelStyle: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 12,
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 15),

                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Baca(manga: manga),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.menu_book,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Baca",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            if (manga.isFavorite) {
                                              FavoriteManager.removeFavorite(
                                                  manga);
                                            } else {
                                              FavoriteManager.addFavorite(
                                                  manga);
                                            }

                                            debugPrint(
                                                "Total Favorite: ${FavoriteManager.favorites.length}");

                                            setState(() {
                                              manga.isFavorite =
                                                  !manga.isFavorite;
                                            });
                                          },
                                          icon: Icon(
                                            manga.isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.red,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
