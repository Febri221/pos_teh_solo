import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class InventoryLocalDataSource {
  final AppDatabase database;

  InventoryLocalDataSource(this.database);

  // Ambil semua produk untuk dimonitor stoknya
  Future<List<ProductEntityData>> getInventoryProducts() async {
    return await database.select(database.products).get();
  }

  // Kirim data opname (Catat selisih & update stok produk secara atomic transaction)
  Future<void> submitStockOpname({
    required int productId,
    required int systemStock,
    required int actualStock,
    required String reason,
    required String cashierName,
  }) async {
    final discrepancy = actualStock - systemStock; // Selisih (bisa minus atau plus)
    final now = DateTime.now();

    await database.transaction(() async {
      // 1. Catat ke tabel StockOpnames
      await database.into(database.stockOpnames).insert(
            StockOpnamesCompanion.insert(
              productId: productId,
              date: now,
              systemStock: systemStock,
              actualStock: actualStock,
              discrepancy: discrepancy,
              reason: Value(reason),
              cashierName: cashierName,
            ),
          );

      // 2. Update stok asli di tabel Products
      await (database.update(database.products)
            ..where((p) => p.id.equals(productId)))
          .write(
        ProductsCompanion(
          stock: Value(actualStock),
        ),
      );
    });
  }
}