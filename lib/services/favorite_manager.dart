import '../models/manga.dart';

class FavoriteManager {
  static final List<Manga> favorites = [];

  static void addFavorite(Manga manga) {
    if (!favorites.any((m) => m.malId == manga.malId)) {
      favorites.add(manga);
    }
  }

  static void removeFavorite(Manga manga) {
    favorites.removeWhere((m) => m.malId == manga.malId);
  }
}