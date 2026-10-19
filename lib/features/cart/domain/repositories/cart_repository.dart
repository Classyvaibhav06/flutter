import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> saveCartItems(List<CartItemEntity> items);
  Future<void> clearCart();

  Future<Either<Failure, OrderResponseEntity>> placeOrder({
    required int userId,
    required List<CartItemEntity> items,
  });
}
