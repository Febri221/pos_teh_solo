import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teh_solo_pos/features/auth/presentation/screens/login_screen.dart';
import '../bloc/cart_state.dart';
import 'package:teh_solo_pos/features/pos/presentation/bloc/cart_event.dart';
import 'package:teh_solo_pos/features/product/presentation/bloc/product_event.dart';
import 'package:teh_solo_pos/features/product/presentation/bloc/product_state.dart';
import '../../../../core/di/injection.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_bottom_sheet.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita bungkus dengan MultiBlocProvider agar ProductBloc dan CartBloc bisa diakses bersamaan
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) => sl<ProductBloc>()..add(LoadProducts()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => sl<CartBloc>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'POS Teh Solo - Kasir',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          actions: [
            // Tombol Refresh Produk
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ProductBloc>().add(LoadProducts());
              },
            ),

            // ---> TOMBOL LOGOUT / GANTI SHIFT <---
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Konfirmasi sebelum logout
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar Aplikasi'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Batal
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Tutup dialog konfirmasi
                          Navigator.pop(context);

                          // Lempar balik ke LoginScreen dan hapus riwayat navigasi sebelumnya
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LoginScreen(), // Pastikan mengarah ke LoginScreen lo
                            ),
                            (route) =>
                                false, // Hapus semua tumpukan halaman sebelumnya
                          );
                        },
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // 1. Grid Produk Menu Teh Solo
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoaded) {
                  final products = state.products;
                  if (products.isEmpty) {
                    return const Center(child: Text('Belum ada menu produk.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16,
                        100), // Padding bawah agar tidak tertutup floating bar
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return InkWell(
                        onTap: () {
                          // Masukkan produk ke keranjang saat diklik!
                          context.read<CartBloc>().add(AddToCart(product));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('+1 ${product.name} (${product.size})'),
                              duration: const Duration(milliseconds: 500),
                              backgroundColor: Colors.brown.shade700,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.brown.shade100),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon cangkir kecil penanda teh
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.brown.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('🍵',
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.brown.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product.size,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E6B45),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Stok: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ProductError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),

            // 2. Floating Bottom Bar (Ala Figma - Muncul di bawah kalau keranjang ada isinya)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return const SizedBox
                        .shrink(); // Sembunyikan kalau keranjang kosong
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFF113F29), // Hijau gelap elegan ala Figma
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () async {
                        // Buka Modal Keranjang saat bar bawah diklik
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => BlocProvider.value(
                            value: context.read<CartBloc>(),
                            child: const CartBottomSheet(),
                          ),
                        );

                        if (context.mounted) {
                          context.read<ProductBloc>().add(LoadProducts());
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    const Icon(Icons.shopping_cart, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Lihat Pesanan (${state.totalItemCount})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Rp ${state.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
