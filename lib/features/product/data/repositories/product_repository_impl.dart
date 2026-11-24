import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl(this.localDataSource);

  @override
  Future<List<ProductEntityData>> getProducts() async {
    
    await localDataSource.seedInitialProducts();
    return await localDataSource.getAllProducts();
  }

  @override
  Future<void> addProduct(String name, String size, double price, int stock) async {
    final companion = ProductsCompanion.insert(
      name: name,
      size: size,
      price: price,
      stock: Value(stock),
    );
    await localDataSource.insertProduct(companion);
  }
}