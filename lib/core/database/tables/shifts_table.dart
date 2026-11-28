import 'package:drift/drift.dart';

class Shifts extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Siapa yang bertugas (Owner atau Mamak)
  TextColumn get cashierName => text()();
  
  // Waktu buka & tutup shift
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  
  // Uang modal awal di laci kasir
  RealColumn get initialCash => real()();
  
  // Uang fisik aktual di laci saat tutup shift (dihitung manual)
  RealColumn get finalCashPhysical => real().nullable()();
  
  // Total penjualan sistem selama shift
  RealColumn get totalSalesSystem => real().withDefault(const Constant(0.0))();
  
  // Selisih (Kurang/Lebih uang di laci)
  RealColumn get discrepancy => real().withDefault(const Constant(0.0))();
  
  // Keterangan / Catatan penutupan shift
  TextColumn get notes => text().nullable()();
  
  // Status shift ("OPEN" atau "CLOSED")
  TextColumn get status => text().withDefault(const Constant('OPEN'))();
}