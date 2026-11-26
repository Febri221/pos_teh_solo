import 'package:drift/drift.dart';
import 'orders_table.dart';
import 'products_table.dart';

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Relasi ke tabel Orders
  IntColumn get orderId => integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  
  // Relasi ke tabel Products
  IntColumn get productId => integer().references(Products, #id)();
  
  TextColumn get productName => text()();
  TextColumn get size => text()();
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get subtotal => real()();
}