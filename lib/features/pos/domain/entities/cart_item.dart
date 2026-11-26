import '../../../../core/database/app_database.dart';

class CartItem {
  final ProductEntityData product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;
}