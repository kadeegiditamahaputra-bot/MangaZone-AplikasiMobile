import 'package:flutter/material.dart';
import '../../models/manga.dart';
import '../../services/api_service.dart';
import '../home/Baca.dart';

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  List<Manga> _allManga = [];
  List<Manga> _filteredManga = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadManga();
  }

  Future<void> _loadManga() async {
    try {
      final mangas = await ApiService.getTopManga();

      setState(() {
        _allManga = mangas;
        _filteredManga = mangas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _search(String query) {
    setState(() {
      _filteredManga = _allManga.where((manga) {
        return manga.title
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Manga"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Cari judul manga...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : ListView.builder(
              itemCount: _filteredManga.length,
              itemBuilder: (context, index) {
                final manga = _filteredManga[index];

                return ListTile(
                  leading: Image.network(
                    manga.imageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(manga.title),
                  subtitle: Text(
                    "Score: ${manga.score}",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Baca(
                          manga: manga,
                        ),
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