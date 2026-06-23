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
    return Manga(
      malId: json['mal_id'],
      title: json['title'] ?? '',
      imageUrl: json['images']['jpg']['image_url'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      chapters: json['chapters'] ?? 0,
      synopsis: json['synopsis'] ?? '',
      genres: (json['genres'] as List?)
          ?.map((e) => e['name'].toString())
          .toList() ??
          [],
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
      malId: data['malId'],
      title: data['title'],
      imageUrl: data['imageUrl'],
      score: (data['score'] ?? 0).toDouble(),
      genres: List<String>.from(data['genres'] ?? []),
      chapters: data['chapters'] ?? 0,
      synopsis: data['synopsis'] ?? '',
      isFavorite: true,
    );
  }
}