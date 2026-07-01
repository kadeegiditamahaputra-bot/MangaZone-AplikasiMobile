import 'dart:convert';

class Manga {
  final int malId;
  final String title;
  final String imageUrl;
  final double score;
  final List<String> genres;
  final int chapters;
  final String synopsis;

  bool isFavorite;

  Manga({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.score,
    required this.genres,
    required this.chapters,
    required this.synopsis,
    this.isFavorite = false,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    // Handle genres fleksibel: bisa List dari API, bisa String JSON dari DB
    List<String> parsedGenres = [];
    if (json['genres'] is List) {
      parsedGenres = (json['genres'] as List)
          .map((e) => e is Map ? e['name'].toString() : e.toString())
          .toList();
    } else if (json['genres'] is String) {
      try {
        parsedGenres = List<String>.from(jsonDecode(json['genres']));
      } catch (_) {
        parsedGenres = [];
      }
    }

    return Manga(
      malId: json['mal_id'] ?? json['malId'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['images']?['jpg']?['image_url'] ?? json['imageUrl'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      chapters: json['chapters'] ?? 0,
      synopsis: json['synopsis'] ?? '',
      genres: parsedGenres,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'malId': malId,
      'title': title,
      'imageUrl': imageUrl,
      'score': score,
      'genres': genres,
      'chapters': chapters,
      'synopsis': synopsis,
    };
  }

  factory Manga.fromFirestore(Map<String, dynamic> data) {
    return Manga(
      malId: data['malId'] ?? 0,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      score: (data['score'] ?? 0).toDouble(),
      genres: List<String>.from(data['genres'] ?? []),
      chapters: data['chapters'] ?? 0,
      synopsis: data['synopsis'] ?? '',
      isFavorite: data['isFavorite'] ?? true,
    );
  }
}
