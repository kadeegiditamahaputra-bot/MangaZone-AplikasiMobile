import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibration/vibration.dart';
import '../transaksi/notifikasi_pembayaran.dart';

class KonfirmasiPage extends StatefulWidget {
  final String paket;
  final String harga;

  const KonfirmasiPage({
    super.key,
    required this.paket,
    required this.harga,
  });

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  bool _isProcessing = false; // State untuk mengontrol loading indicator saat bayar

  int _getDurationDays() {
    switch (widget.paket) {
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
      backgroundColor: const Color(0xFF0B0B14), // Tema Gelap MangaZone
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Konfirmasi Pembayaran",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 1),

            // Visualisasi Ikon Dompet/Pembayaran yang Estetik
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 72,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              "Ringkasan Transaksi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),

            // Tampilan Detail Paket Terpilih
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141424),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.02)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 24),
                ),
                title: Text(
                  "Premium ${widget.paket}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.harga,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Informasi/Pertanyaan Konfirmasi
            Center(
              child: Text(
                "Apakah kamu yakin ingin melanjutkan transaksi ini?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Tombol Aksi (Batal & Konfirmasi)
            Row(
              children: [
                // Tombol Batal
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white60,
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Tombol Konfirmasi Pembayaran
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                        setState(() {
                          _isProcessing = true;
                        });

                        try {
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          final now = DateTime.now();
                          final until = now.add(
                            Duration(days: _getDurationDays()),
                          );

                          // 1. Update status premium ke Firestore
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .set({
                            "isPremium": true,
                            "premiumUntil": Timestamp.fromDate(until),
                          }, SetOptions(merge: true));

                          // Efek Getaran Haptic 2x
                          if (await Vibration.hasVibrator() ?? false) {
                            await Vibration.vibrate(pattern: [0, 250, 120, 250]);
                          }

                          // Notifikasi Push Lokal / Android
                          await NotificationService.showPaymentSuccess();

                          // 2. Simpan Riwayat Transaksi
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("transactions")
                              .add({
                            "paket": "Premium ${widget.paket}",
                            "harga": widget.harga,
                            "status": "Berhasil",
                            "tanggal": FieldValue.serverTimestamp(),
                          });

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Pembayaran ${widget.paket} berhasil!"),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );

                          Navigator.pop(context, true);
                        } catch (e) {
                          debugPrint("Gagal memproses transaksi: $e");
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Terjadi kesalahan teknis. Coba lagi."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isProcessing = false;
                            });
                          }
                        }
                      },
                      icon: _isProcessing
                          ? const SizedBox.shrink()
                          : const Icon(Icons.check_rounded, size: 18),
                      label: _isProcessing
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Konfirmasi",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.deepPurpleAccent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}