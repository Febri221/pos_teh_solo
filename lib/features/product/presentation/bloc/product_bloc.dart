import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';
import 'product_event.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      // HAPUS ATAU JANGAN EMIT ProductLoading JIKA TIDAK PERLU, 
      // ATAU GUNAKAN LOADING HANYA JIKA LIST PRODUK MASIH KOSONG (STATE AWAL)
      if (state is! ProductLoaded) {
        emit(ProductLoading());
      }
      
      try {
        final products = await repository.getProducts();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}