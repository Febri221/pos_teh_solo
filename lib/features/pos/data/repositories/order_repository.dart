import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/cart_item.dart';

class OrderRepository {
  final AppDatabase database;

  OrderRepository(this.database);

  Future<void> checkout({
    required List<CartItem> items,
    required double totalAmount,
    required String paymentMethod,
    required double amountTendered,
    required String cashierName,
  }) async {
    // Generate nomor invoice unik berbasis timestamp (Contoh: INV-20261125-183022)
    final invoiceNo = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // Jalankan Transaction di Drift (Atomic: Sukses semua atau batal semua)
    await database.transaction(() async {
      // 1. Insert ke tabel Orders dan ambil ID yang baru saja dibuat
      final orderId = await database.into(database.orders).insert(
            OrdersCompanion.insert(
              invoiceNumber: invoiceNo,
              createdAt: now,
              totalAmount: totalAmount,
              paymentMethod: paymentMethod,
              amountTendered: amountTendered,
              cashierName: cashierName,
            ),
          );

      // 2. Loop semua item keranjang untuk dimasukkan ke OrderItems & Potong Stok Produk
      for (var cartItem in items) {
        // Masukkan ke OrderItems
        await database.into(database.orderItems).insert(
              OrderItemsCompanion.insert(
                orderId: orderId,
                productId: cartItem.product.id,
                productName: cartItem.product.name,
                size: cartItem.product.size,
                unitPrice: cartItem.product.price,
                quantity: cartItem.quantity,
                subtotal: cartItem.subtotal,
              ),
            );

        // Potong stok di tabel Products
        final currentStock = cartItem.product.stock;
        final newStock = currentStock - cartItem.quantity;

        await (database.update(database.products)
              ..where((p) => p.id.equals(cartItem.product.id)))
            .write(
          ProductsCompanion(
            stock: Value(newStock < 0 ? 0 : newStock), // Hindari stok minus
          ),
        );
      }
    });
  }
}