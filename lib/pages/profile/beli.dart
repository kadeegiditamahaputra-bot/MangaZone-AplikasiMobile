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
      appBar: AppBar(
        title: const Text("Metode Pembayaran"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Paket Dipilih",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text(paket),
                subtitle: Text(harga),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Metode Pembayaran",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Gunakan widget reusable
            _buildPaymentMethod(
              icon: Icons.qr_code,
              title: "QRIS",
              subtitle: "Tersedia sekarang",
              available: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur pembayaran QRIS masih dalam pengembangan"),
                  ),
                );
              },
            ),
            _buildPaymentMethod(
              icon: Icons.account_balance,
              title: "Transfer Bank",
              subtitle: "Belum tersedia",
              available: false,
            ),
            _buildPaymentMethod(
              icon: Icons.account_balance_wallet,
              title: "E-Wallet",
              subtitle: "Belum tersedia",
              available: false,
            ),
            _buildPaymentMethod(
              icon: Icons.credit_card,
              title: "Kartu Kredit / Debit",
              subtitle: "Belum tersedia",
              available: false,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
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
                icon: const Icon(Icons.payment),
                label: const Text("Lanjut ke Pembayaran"),
              ),

            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget reusable untuk metode pembayaran
  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          available ? Icons.check_circle : Icons.lock,
          color: available ? Colors.green : Colors.grey,
        ),
        onTap: available ? onTap : null,
      ),
    );
  }
}
