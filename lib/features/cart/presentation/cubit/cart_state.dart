import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartState extends Equatable {
  final List<CartItemEntity> items;
  final CartSummaryEntity summary;
  final bool isPlacingOrder;
  final OrderResponseEntity? completedOrder;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.summary = const CartSummaryEntity(),
    this.isPlacingOrder = false,
    this.completedOrder,
    this.errorMessage,
  });

  CartState copyWith({
    List<CartItemEntity>? items,
    CartSummaryEntity? summary,
    bool? isPlacingOrder,
    OrderResponseEntity? completedOrder,
    bool clearCompletedOrder = false,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      completedOrder:
          clearCompletedOrder ? null : (completedOrder ?? this.completedOrder),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        items,
        summary,
        isPlacingOrder,
        completedOrder,
        errorMessage,
      ];
}
