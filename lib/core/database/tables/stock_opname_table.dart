import 'package:drift/drift.dart';
import 'products_table.dart';

class StockOpnames extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get systemStock => integer()();
  IntColumn get actualStock => integer()();
  IntColumn get discrepancy => integer()(); 
  TextColumn get reason => text().nullable()(); 
  TextColumn get cashierName => text()();
}