import 'package:flutter/material.dart';

class ReaderPage extends StatelessWidget {
  final String chapterName;

  const ReaderPage({
    super.key,
    required this.chapterName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chapterName),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Image.network(
              "https://picsum.photos/800/1200?random=${index + 1}",
              fit: BoxFit.cover,
              loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                  ) {
                if (loadingProgress == null) return child;

                return const SizedBox(
                  height: 500,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  height: 500,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text("Gagal memuat gambar"),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}