import 'package:flutter/material.dart';
import 'package:teh_solo_pos/features/history/presentation/screen/report_screen.dart';
import '../../../pos/presentation/screens/cashier_screen.dart';


class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  // Index aktif untuk Bottom Navigation
  int _currentIndex = 0;

  // Daftar halaman utama aplikasi POS Teh Solo
  // Saat ini CashierPage sudah aktif, sisanya kita buatkan placeholder dulu
  final List<Widget> _pages = [
    const CashierScreen(),
    const PlaceholderPageWidget(title: 'Inventori & Stok'),
    const ReportScreen(),
    const PlaceholderPageWidget(title: 'Manajemen Shift'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar state halaman (seperti keranjang kasir) 
      // tidak hilang saat kasir bolak-balik pindah tab menu bawah.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF113F29), // Hijau gelap Teh Solo
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Kasir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Inventori',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time),
              label: 'Shift',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget sementara untuk halaman yang belum dibuat (Placeholder)
class PlaceholderPageWidget extends StatelessWidget {
  final String title;
  const PlaceholderPageWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.brown),
            const SizedBox(height: 16),
            Text(
              'Halaman $title\nSegera Hadir di Milestone Berikutnya!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}