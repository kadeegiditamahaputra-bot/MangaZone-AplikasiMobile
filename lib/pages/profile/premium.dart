import 'package:flutter/material.dart';
import 'beli.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MangaZone Premium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 10),
            const Text(
              "Nikmati Manga Tanpa Iklan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Baca manga lebih nyaman tanpa gangguan iklan.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            _premiumCard(
              context,
              title: "1 Bulan",
              price: "Rp10.000",
            ),

            _premiumCard(
              context,
              title: "3 Bulan",
              price: "Rp25.000",
            ),

            _premiumCard(
              context,
              title: "1 Tahun",
              price: "Rp80.000",
            ),
          ],
        ),
      ),
    );
  }

  Widget _premiumCard(
      BuildContext context, {
        required String title,
        required String price,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: ListTile(
        leading: const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BeliPage(
                  paket: title,
                  harga: price,
                ),
              ),
            );
          },
          child: const Text("Beli"),
        ),
      ),
    );
  }
}