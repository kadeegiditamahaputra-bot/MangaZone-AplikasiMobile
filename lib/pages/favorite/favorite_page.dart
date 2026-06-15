import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> favoriteManga = [
      {
        "title": "One Piece",
        "genre": "Adventure",
      },
      {
        "title": "Naruto",
        "genre": "Action",
      },
      {
        "title": "Attack on Titan",
        "genre": "Fantasy",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorite Manga",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: favoriteManga.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Belum ada manga favorit",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favoriteManga.length,
              itemBuilder: (context, index) {
                final manga = favoriteManga[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      manga["title"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Genre: ${manga["genre"]}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "${manga["title"]} dihapus dari favorit",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}