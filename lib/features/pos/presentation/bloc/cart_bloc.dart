import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

// --- GANTI SELURUH ISI BLOC CLASS DENGAN KODE INI ---
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    
    // 1. Tambah Produk ke Keranjang (Immutable & Reactive)
    on<AddToCart>((event, emit) {
      // Buat salinan list lama
      final updatedItems = List<CartItem>.from(state.items);
      
      final existingIndex = updatedItems.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      if (existingIndex >= 0) {
        // Ambil item lama, buat objek CartItem baru dengan quantity + 1
        final existingItem = updatedItems[existingIndex];
        if (existingItem.quantity < event.product.stock) {
          updatedItems[existingIndex] = CartItem(
            product: existingItem.product,
            quantity: existingItem.quantity + 1,
          );
        }
      } else {
        if (event.product.stock > 0) {
          updatedItems.add(CartItem(product: event.product, quantity: 1));
        }
      }

      // Emit state baru dengan list baru (memaksa UI untuk rebuild/berubah)
      emit(state.copyWith(items: List.from(updatedItems)));
    });

    // 2. Kurangi / Hapus Produk dari Keranjang (Immutable & Reactive)
    on<RemoveFromCart>((event, emit) {
      // Buat salinan list lama
      final updatedItems = List<CartItem>.from(state.items);
      
      final existingIndex = updatedItems.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      if (existingIndex >= 0) {
        final existingItem = updatedItems[existingIndex];
        if (existingItem.quantity > 1) {
          // Buat objek CartItem baru dengan quantity - 1
          updatedItems[existingIndex] = CartItem(
            product: existingItem.product,
            quantity: existingItem.quantity - 1,
          );
        } else {
          // Hapus item jika kuantiti habis
          updatedItems.removeAt(existingIndex);
        }
      }

      // Emit state baru dengan list baru
      emit(state.copyWith(items: List.from(updatedItems)));
    });

    // 3. Kosongkan Keranjang
    on<ClearCart>((event, emit) {
      emit(const CartState(items: []));
    });
  }
}