import '../../../../core/database/app_database.dart';

abstract class ProductRepository {
 
  Future<List<ProductEntityData>> getProducts();


  Future<void> addProduct(String name, String size, double price, int stock);
}