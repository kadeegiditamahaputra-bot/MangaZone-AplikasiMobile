import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/manga.dart';

class FavoriteService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addFavorite(Manga manga) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(manga.malId.toString())
        .set(manga.toMap());
  }

  static Future<void> removeFavorite(Manga manga) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(manga.malId.toString())
        .delete();
  }

  static Stream<QuerySnapshot> getFavorites() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots();
  }
}