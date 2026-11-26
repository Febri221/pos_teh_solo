import 'package:drift/drift.dart';

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()(); 
  RealColumn get amountTendered => real()(); 
  TextColumn get cashierName => text()();
}