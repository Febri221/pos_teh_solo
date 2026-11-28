import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/products_table.dart';
import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';
import 'tables/stock_opname_table.dart';
import 'tables/users_table.dart';
import 'tables/shifts_table.dart';


part 'app_database.g.dart';

@DriftDatabase(tables: [Products, Orders, OrderItems, StockOpnames, Users, Shifts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'teh_solo_pos_db',
    );
  }
}