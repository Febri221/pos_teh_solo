import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    
    // 1. Tambah Produk ke Keranjang
    on<AddToCart>((event, emit) {
      final updatedItems = List<CartItem>.from(state.items);
      
      // Cek apakah produk sudah ada di keranjang
      final existingIndex = updatedItems.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      if (existingIndex >= 0) {
        // Kalau sudah ada, tambah kuantitinya (dengan validasi stok sederhana)
        if (updatedItems[existingIndex].quantity < event.product.stock) {
          updatedItems[existingIndex].quantity += 1;
        }
      } else {
        // Kalau belum ada, masukkan sebagai item baru
        if (event.product.stock > 0) {
          updatedItems.add(CartItem(product: event.product, quantity: 1));
        }
      }

      emit(state.copyWith(items: updatedItems));
    });

    // 2. Kurangi / Hapus Produk dari Keranjang
    on<RemoveFromCart>((event, emit) {
      final updatedItems = List<CartItem>.from(state.items);
      
      final existingIndex = updatedItems.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      if (existingIndex >= 0) {
        if (updatedItems[existingIndex].quantity > 1) {
          updatedItems[existingIndex].quantity -= 1;
        } else {
          // Kalau sisa 1 dan dikurang, hapus item dari keranjang
          updatedItems.removeAt(existingIndex);
        }
      }

      emit(state.copyWith(items: updatedItems));
    });

    // 3. Kosongkan Keranjang (Setelah checkout sukses)
    on<ClearCart>((event, emit) {
      emit(const CartState(items: []));
    });
  }
}