import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibration/vibration.dart';
import '../transaksi/notifikasi_pembayaran.dart';

class KonfirmasiPage extends StatelessWidget {
  final String paket;
  final String harga;

  const KonfirmasiPage({
    super.key,
    required this.paket,
    required this.harga,
  });

  int _getDurationDays() {
    switch (paket) {
      case "1 Bulan":
        return 30;
      case "3 Bulan":
        return 90;
      case "1 Tahun":
        return 365;
      default:
        return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konfirmasi Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.payment, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),

            Text("Detail Paket", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                title: Text(paket),
                subtitle: Text(harga),
              ),
            ),

            const SizedBox(height: 24),
            Text("Apakah kamu yakin ingin membeli paket ini?",
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser!.uid;

                      final now = DateTime.now();
                      final until = now.add(
                        Duration(days: _getDurationDays()),
                      );

                      // 1. Update status premium (pakai Timestamp)
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .set({
                        "isPremium": true,
                        "premiumUntil": Timestamp.fromDate(until),
                      }, SetOptions(merge: true));

                      // Getaran 2x
                      if (await Vibration.hasVibrator() ?? false) {
                        await Vibration.vibrate(
                          pattern: [0, 250, 120, 250],
                        );
                      }

// Notifikasi Android
                      await NotificationService.showPaymentSuccess();

                      // 2. Simpan transaksi
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .collection("transactions")
                          .add({
                        "paket": "Premium $paket",
                        "harga": harga,
                        "status": "Berhasil",
                        "tanggal": FieldValue.serverTimestamp(),
                      });

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Pembayaran $paket berhasil"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Konfirmasi"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // batal
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Batal"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
