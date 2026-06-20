import 'package:flutter/material.dart';

class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> transaksi = [
      {
        "paket": "Premium Bulanan",
        "harga": "Rp 29.000",
        "tanggal": "20 Juni 2026",
        "status": "Berhasil",
      },
      {
        "paket": "Premium Tahunan",
        "harga": "Rp 299.000",
        "tanggal": "10 Mei 2026",
        "status": "Berhasil",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: transaksi.isEmpty
          ? const Center(
        child: Text("Belum ada transaksi"),
      )
          : ListView.builder(
        itemCount: transaksi.length,
        itemBuilder: (context, index) {
          final item = transaksi[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                ),
              ),
              title: Text(item["paket"]!),
              subtitle: Text(
                "${item["tanggal"]}\n${item["harga"]}",
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item["status"]!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}