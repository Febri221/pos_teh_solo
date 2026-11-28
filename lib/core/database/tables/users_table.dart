import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Nama pengguna (Contoh: "Owner", "Mamak")
  TextColumn get name => text().unique()();
  
  // PIN 4-6 digit untuk login lokal (disimpan dalam bentuk string/hash)
  TextColumn get pin => text()();
  
  // Role / Peran ("owner" atau "cashier")
  TextColumn get role => text()(); 
  
  // Status aktif
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}