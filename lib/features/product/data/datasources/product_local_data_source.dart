import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class ProductLocalDataSource {
  final AppDatabase database;

  ProductLocalDataSource(this.database);

  // 1. Ambil semua produk dari database lokal
  Future<List<ProductEntityData>> getAllProducts() async {
    return await database.select(database.products).get();
  }

  // 2. Tambah produk baru (misal: Es Teh Solo Original)
  Future<int> insertProduct(ProductsCompanion product) async {
    return await database.into(database.products).insert(product);
  }

  // 3. (Opsional untuk awal) Seeding data awal jika produk masih kosong
  Future<void> seedInitialProducts() async {
    final existingProducts = await getAllProducts();
    if (existingProducts.isEmpty) {
      // Masukkan produk default Teh Solo
      await database.batch((batch) {
        batch.insertAll(
          database.products,
          [
            ProductsCompanion.insert(
              name: 'Teh Solo Original',
              size: 'Regular',
              price: 3000,
              stock: const Value(100),
            ),
            ProductsCompanion.insert(
              name: 'Teh Solo Original',
              size: 'Jumbo',
              price: 5000,
              stock: const Value(100),
            ),
            ProductsCompanion.insert(
              name: 'Teh Solo Lemon',
              size: 'Regular',
              price: 4000,
              stock: const Value(80),
            ),
          ],
        );
      });
    }
  }
}