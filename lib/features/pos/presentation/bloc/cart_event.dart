import 'package:equatable/equatable.dart';
import '../../../../core/database/app_database.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class AddToCart extends CartEvent {
  final ProductEntityData product;
  const AddToCart(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final ProductEntityData product;
  const RemoveFromCart(this.product);
  @override
  List<Object> get props => [product];
}

class ClearCart extends CartEvent {}