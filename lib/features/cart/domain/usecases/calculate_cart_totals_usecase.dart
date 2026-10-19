import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class CalculateCartTotalsUseCase {
  const CalculateCartTotalsUseCase();

  CartSummaryEntity call(List<CartItemEntity> items) {
    double subtotal = 0.0;
    double discountSavings = 0.0;
    int totalItems = 0;

    for (final item in items) {
      if (item.quantity <= 0) continue;

      final originalUnitPrice =
          (item.discountPercentage > 0 && item.discountPercentage < 100)
              ? item.price / (1 - (item.discountPercentage / 100.0))
              : item.price;

      final lineSubtotal = originalUnitPrice * item.quantity;
      final linePaid = item.price * item.quantity;

      subtotal += lineSubtotal;
      discountSavings += (lineSubtotal - linePaid).clamp(0.0, double.infinity);
      totalItems += item.quantity;
    }

    final grandTotal = (subtotal - discountSavings).clamp(0.0, double.infinity);

    return CartSummaryEntity(
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      totalDiscount: double.parse(discountSavings.toStringAsFixed(2)),
      grandTotal: double.parse(grandTotal.toStringAsFixed(2)),
      totalItems: totalItems,
    );
  }
}

class PlaceOrderUseCase {
  final CartRepository repository;

  const PlaceOrderUseCase(this.repository);

  Future<Either<Failure, OrderResponseEntity>> call({
    required int userId,
    required List<CartItemEntity> items,
  }) async {
    if (items.isEmpty) {
      return const Left(ValidationFailure('Your cart is empty.'));
    }
    return repository.placeOrder(userId: userId, items: items);
  }
}
