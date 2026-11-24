import 'package:drift/drift.dart';

@DataClassName('ProductEntityData') // Nama class model yang akan digenerate Drift
class Products extends Table {
  // Kolom ID (Primary Key, Auto Increment)
  IntColumn get id => integer().autoIncrement()();
  
  // Nama Produk (Contoh: "Teh Solo Original", "Teh Solo Lemon")
  TextColumn get name => text().withLength(min: 1, max: 100)();
  
  // Ukuran (Contoh: "Regular", "Large", "Jumbo")
  TextColumn get size => text().withLength(min: 1, max: 20)();
  
  // Harga Satuan
  RealColumn get price => real()();
  
  // Stok Saat Ini
  IntColumn get stock => integer().withDefault(const Constant(0))();
  
  // Status Aktif Produk (Untuk menyembunyikan produk jika habis/tidak dijual)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Timestamp kapan produk dibuat/diubah
  DateTimeColumn get updatedAt => dateTime().nullable()();
}