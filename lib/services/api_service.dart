import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';

class ApiService {
  static Future<List<Manga>> getTopManga() async {
    final response = await http.get(
      Uri.parse(
        'https://api.jikan.moe/v4/top/manga',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['data'] as List)
          .map((e) => Manga.fromJson(e))
          .toList();
    }

    throw Exception('Gagal mengambil data');
    
  }
  
}
