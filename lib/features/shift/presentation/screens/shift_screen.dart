import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/app_database.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final AppDatabase _database = sl<AppDatabase>();

  // Fungsi untuk mengecek apakah ada shift yang sedang 'OPEN'
  Future<Shift?> _getActiveShift() async {
    return await (_database.select(_database.shifts)
          ..where((tbl) => tbl.status.equals('OPEN'))
          ..limit(1))
        .getSingleOrNull();
  }

  // Dialog Buka Shift (Open Shift)
  void _showOpenShiftDialog() {
    final TextEditingController cashController = TextEditingController(text: '100000');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Buka Shift Baru (Open Shift)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan modal uang tunai awal yang ada di laci kasir saat ini:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Modal Awal (Rp)',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E6B45), foregroundColor: Colors.white),
            onPressed: () async {
              final double? initialCash = double.tryParse(cashController.text.trim());
              if (initialCash == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nominal modal yang valid!')));
                return;
              }

              // Simpan shift baru ke Drift
              await _database.into(_database.shifts).insert(
                    ShiftsCompanion.insert(
                      cashierName: 'Owner / Mamak', // Nanti bisa dinamis dari User yang login
                      startTime: DateTime.now(),
                      initialCash: initialCash,
                      status: const Value('OPEN'),
                    ),
                  );

              Navigator.pop(context);
              setState(() {}); // Refresh UI

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift berhasil dibuka! Selamat berjualan 🍵'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Mulai Buka Shift'),
          ),
        ],
      ),
    );
  }

  // Dialog Tutup Shift (Close Shift & Hitung Selisih Uang Laci)
  void _showCloseShiftDialog(Shift activeShift) async {
    // Hitung total penjualan sistem selama shift ini berlangsung (dari tabel orders)
    // Untuk sederhana, kita ambil total seluruh order sejak startTime shift ini
    final salesQuery = await (_database.select(_database.orders)
          ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(activeShift.startTime)))
        .get();

    double totalSystemSales = 0.0;
    for (var order in salesQuery) {
      totalSystemSales += order.totalAmount;
    }

    final double expectedCash = activeShift.initialCash + totalSystemSales;
    final TextEditingController physicalCashController = TextEditingController(text: expectedCash.toStringAsFixed(0));
    final TextEditingController notesController = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Shift (End of Shift)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Modal Awal: Rp ${activeShift.initialCash.toStringAsFixed(0)}'),
              Text('Penjualan Sistem: Rp ${totalSystemSales.toStringAsFixed(0)}'),
              const Divider(height: 20),
              Text(
                'Harusnya Uang di Laci: Rp ${expectedCash.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: physicalCashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hitung Fisik Uang di Laci (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan / Alasan Selisih (Jika ada)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () async {
              final double? physicalCash = double.tryParse(physicalCashController.text.trim());
              if (physicalCash == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nominal fisik yang valid!')));
                return;
              }

              final double discrepancy = physicalCash - expectedCash; // Selisih (bisa minus/plus)

              // Update shift di database jadi CLOSED
              await (_database.update(_database.shifts)
                    ..where((tbl) => tbl.id.equals(activeShift.id)))
                  .write(
                ShiftsCompanion(
                  endTime: Value(DateTime.now()),
                  finalCashPhysical: Value(physicalCash),
                  totalSalesSystem: Value(totalSystemSales),
                  discrepancy: Value(discrepancy),
                  notes: Value(notesController.text.trim()),
                  status: const Value('CLOSED'),
                ),
              );

              Navigator.pop(context);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shift ditutup! Selisih laci: Rp ${discrepancy.toStringAsFixed(0)}'),
                  backgroundColor: discrepancy < 0 ? Colors.orange : Colors.green,
                ),
              );
            },
            child: const Text('Konfirmasi Tutup Shift'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Manajemen Shift Kasir', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Shift?>(
        future: _getActiveShift(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          }

          final activeShift = snapshot.data;
          final isOpen = activeShift != null;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner Status Shift Saat Ini
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isOpen ? Colors.green.shade200 : Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isOpen ? Icons.lock_open : Icons.lock_outline,
                        size: 48,
                        color: isOpen ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isOpen ? 'STATUS: SHIFT SEDANG DIBUKA' : 'STATUS: TIDAK ADA SHIFT AKTIF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isOpen ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOpen
                            ? 'Petugas: ${activeShift.cashierName}\nMulai: ${DateFormat('dd MMM yyyy, HH:mm').format(activeShift.startTime)}'
                            : 'Silakan buka shift terlebih dahulu untuk mulai mencatat keuangan laci kasir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Tombol Aksi Buka / Tutup Shift
                if (!isOpen)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6B45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text('BUKA SHIFT BARU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () => _showOpenShiftDialog(),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.stop_rounded, size: 28),
                    label: const Text('TUTUP SHIFT (END OF SHIFT)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () => _showCloseShiftDialog(activeShift),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}