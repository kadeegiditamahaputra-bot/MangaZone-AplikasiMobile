import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  Uint8List? _webImage;

  String _name = '';
  String _email = '';
  String _favoriteManga = '';
  String _favoriteGenre = '';
  String _bio = '';

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();

          setState(() {
            _webImage = bytes;
          });
        } else {
          setState(() {
            _profileImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint("Error mengambil gambar: $e");
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Profil berhasil disimpan"),
          backgroundColor: Colors.green,
        ),
      );

      debugPrint("Nama: $_name");
      debugPrint("Email: $_email");
      debugPrint("Manga Favorit: $_favoriteManga");
      debugPrint("Genre Favorit: $_favoriteGenre");
      debugPrint("Bio: $_bio");
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? profileProvider;

    if (kIsWeb) {
      if (_webImage != null) {
        profileProvider = MemoryImage(_webImage!);
      }
    } else {
      if (_profileImage != null) {
        profileProvider = FileImage(_profileImage!);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,

                child: Stack(
                  alignment: Alignment.bottomRight,

                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: profileProvider,

                      child: profileProvider == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),

                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Ketuk foto untuk mengganti profil",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 40,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "MangaZone Reader",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nama Pengguna",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _name = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama tidak boleh kosong";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  if (!value.contains('@')) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Manga Favorit",
                  prefixIcon: Icon(Icons.menu_book),
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _favoriteManga = value ?? '',
              ),

              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Genre Favorit",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _favoriteGenre = value ?? '',
              ),

              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Tentang Saya",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _bio = value ?? '',
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Simpan Profil",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}