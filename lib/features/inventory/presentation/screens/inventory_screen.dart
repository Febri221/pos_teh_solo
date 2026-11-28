import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/app_database.dart';
import '../../data/datasources/inventory_local_data_source.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryLocalDataSource _inventoryDataSource = sl<InventoryLocalDataSource>();

  // Fungsi ambil data produk inventori
  Future<List<ProductEntityData>> _loadInventory() async {
    return await _inventoryDataSource.getInventoryProducts();
  }

  // Dialog Form untuk Input Opname Fisik
  void _showOpnameDialog(ProductEntityData product) {
    final TextEditingController actualStockController = TextEditingController(text: product.stock.toString());
    final TextEditingController reasonController = TextEditingController(text: 'Opname Rutin');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Opname Stok: ${product.name} (${product.size})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stok Sistem saat ini: ${product.stock}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: actualStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Stok Fisik Riil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan / Keterangan (Mis: Tumpah, Basi)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E6B45), foregroundColor: Colors.white),
            onPressed: () async {
              final int? actualStock = int.tryParse(actualStockController.text.trim());
              if (actualStock == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan angka stok yang valid!')));
                return;
              }

              try {
                // Eksekusi Opname via DataSource
                await _inventoryDataSource.submitStockOpname(
                  productId: product.id,
                  systemStock: product.stock,
                  actualStock: actualStock,
                  reason: reasonController.text.trim(),
                  cashierName: 'Owner / Mamak', // Bisa dinamis sesuai user login nanti
                );

                Navigator.pop(context); // Tutup dialog
                setState(() {}); // Refresh list inventori

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stok berhasil disesuaikan (Opname Sukses)! 📦'), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal opname: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Simpan Opname'),
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
        title: const Text('Inventori & Stok', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<List<ProductEntityData>>(
        future: _loadInventory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada produk di inventori.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.brown.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.brown.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown.shade50,
                    child: const Text('📦'),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Ukuran: ${product.size} | Harga: Rp ${product.price.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Stok Sistem', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: product.stock > 10 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.brown, size: 28),
                        tooltip: 'Sesuaikan Stok (Opname)',
                        onPressed: () => _showOpnameDialog(product),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}