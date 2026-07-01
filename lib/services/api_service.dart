import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';

class ApiService {
  // Base URL cukup sampai folder api
  static const String baseUrl = "http://192.168.1.9/mangazone-backend/api";


  // Ambil daftar manga
  static Future<List<Manga>> getManga() async {
    final response = await http.get(Uri.parse('$baseUrl/manga.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((e) => Manga.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil data manga');
  }

  // Ambil genre
  static Future<List<dynamic>> getGenre() async {
    final response = await http.get(Uri.parse('$baseUrl/genre.php'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal mengambil genre');
  }

  // Ambil chapter berdasarkan manga_id
  static Future<List<dynamic>> getChapter(int mangaId) async {
    final response = await http.get(Uri.parse('$baseUrl/chapter.php?manga_id=$mangaId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal mengambil chapter');
  }

  // Tambah favorit
  static Future<void> addFavorite(String uid, int mangaId) async {
    await http.post(Uri.parse('$baseUrl/favorite.php'),
        body: {"firebase_uid": uid, "manga_id": mangaId.toString()});
  }

  // Hapus favorit
  static Future<void> removeFavorite(String uid, int mangaId) async {
    await http.delete(Uri.parse('$baseUrl/favorite.php'),
        body: {"firebase_uid": uid, "manga_id": mangaId.toString()});
  }
}
