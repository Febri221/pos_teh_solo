import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/app_database.dart';
import 'package:intl/intl.dart'; 
import 'package:drift/drift.dart' as drift;

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportScreen> {
  // Ambil instance database dari GetIt
  final AppDatabase _database = sl<AppDatabase>();

  
Future<List<Order>> _fetchOrders() async {
  return await (_database.select(_database.orders)
        ..orderBy([
          (t) => drift.OrderingTerm.desc(t.createdAt),
        ]))
      .get();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh data
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularIndicatorSafe());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada transaksi tercatat.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // Format tanggal pakai package intl
              final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.brown.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        'Rp ${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E6B45),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            order.paymentMethod,
                            style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    FutureBuilder<List<OrderItem>>(
                      future: (_database.select(_database.orderItems)
                            ..where((tbl) => tbl.orderId.equals(order.id)))
                          .get(),
                      builder: (context, itemSnapshot) {
                        if (!itemSnapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        final items = itemSnapshot.data!;
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const Text(
                                'Detail Produk:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              ...items.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${item.productName} (${item.size}) x${item.quantity}'),
                                        Text('Rp ${item.subtotal.toStringAsFixed(0)}'),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Widget aman untuk muter loading
class CircularIndicatorSafe extends StatelessWidget {
  const CircularIndicatorSafe({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Colors.brown));
  }
}