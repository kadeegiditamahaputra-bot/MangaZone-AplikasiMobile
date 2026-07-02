import 'package:flutter/material.dart';
import 'konfirmasi.dart';

class BeliPage extends StatelessWidget {
  final String paket;
  final String harga;

  const BeliPage({
    super.key,
    required this.paket,
    required this.harga,
  });

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
          "Metode Pembayaran",
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const Text(
                    "Paket Dipilih",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tampilan Paket dengan Gradasi Emas Premium
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 28),
                      ),
                      title: Text(
                        paket,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          harga,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Pilih Metode Pembayaran",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daftar metode pembayaran menggunakan widget reusable yang sudah dipercantik
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.qr_code_scanner_rounded,
                    title: "QRIS (Gopay, OVO, Dana, LinkAja)",
                    subtitle: "Proses instan & otomatis",
                    available: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Metode QRIS dipilih secara instan"),
                          backgroundColor: Colors.deepPurpleAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.account_balance_rounded,
                    title: "Transfer Bank / Virtual Account",
                    subtitle: "Belum tersedia",
                    available: false,
                  ),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: "E-Wallet Langsung",
                    subtitle: "Belum tersedia",
                    available: false,
                  ),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.credit_card_rounded,
                    title: "Kartu Kredit / Debit",
                    subtitle: "Belum tersedia",
                    available: false,
                  ),
                ],
              ),
            ),

            // Tombol Konfirmasi Pembayaran Tetap di Bagian Bawah Layar
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KonfirmasiPage(
                          paket: paket,
                          harga: harga,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 20),
                  label: const Text(
                    "Lanjut ke Pembayaran",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget reusable untuk opsi metode pembayaran
  Widget _buildPaymentMethod({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: available ? Colors.deepPurpleAccent.withOpacity(0.3) : Colors.white.withOpacity(0.02),
          width: available ? 1.5 : 1,
        ),
      ),
      child: Opacity(
        opacity: available ? 1.0 : 0.4, // Meredupkan opsi yang belum tersedia
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: available ? Colors.deepPurpleAccent.withOpacity(0.12) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: available ? Colors.deepPurpleAccent : Colors.white38,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: TextStyle(
                color: available ? Colors.greenAccent : Colors.white30,
                fontSize: 11,
              ),
            ),
          ),
          trailing: Icon(
            available ? Icons.radio_button_checked_rounded : Icons.lock_outline_rounded,
            color: available ? Colors.deepPurpleAccent : Colors.white24,
            size: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: available ? onTap : null,
        ),
      ),
    );
  }
}