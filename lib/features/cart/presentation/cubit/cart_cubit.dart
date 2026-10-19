import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/calculate_cart_totals_usecase.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository cartRepository;
  final CalculateCartTotalsUseCase calculateCartTotalsUseCase;
  final PlaceOrderUseCase placeOrderUseCase;

  CartCubit({
    required this.cartRepository,
    required this.calculateCartTotalsUseCase,
    required this.placeOrderUseCase,
  }) : super(const CartState());

  Future<void> loadCart() async {
    final items = await cartRepository.getCartItems();
    _emitUpdatedItems(items);
  }

  Future<void> addItem(ProductEntity product, int quantity) async {
    if (quantity <= 0) return;

    final current = List<CartItemEntity>.from(state.items);
    final existingIdx = current.indexWhere((e) => e.productId == product.id);

    if (existingIdx >= 0) {
      final existing = current[existingIdx];
      final updatedQty = (existing.quantity + quantity).clamp(1, product.stock);
      current[existingIdx] = existing.copyWith(quantity: updatedQty);
    } else {
      current.add(
        CartItemEntity(
          productId: product.id,
          title: product.title,
          price: product.price,
          discountPercentage: product.discountPercentage,
          thumbnail: product.thumbnail,
          quantity: quantity.clamp(1, product.stock > 0 ? product.stock : 99),
          stock: product.stock,
        ),
      );
    }

    await cartRepository.saveCartItems(current);
    _emitUpdatedItems(current);
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    final current = List<CartItemEntity>.from(state.items);
    final index = current.indexWhere((e) => e.productId == productId);
    if (index < 0) return;

    if (newQuantity <= 0) {
      current.removeAt(index);
    } else {
      final item = current[index];
      final clamped =
          item.stock > 0 ? newQuantity.clamp(1, item.stock) : newQuantity;
      current[index] = item.copyWith(quantity: clamped);
    }

    await cartRepository.saveCartItems(current);
    _emitUpdatedItems(current);
  }

  Future<void> removeItem(int productId) async {
    final current = state.items.where((e) => e.productId != productId).toList();
    await cartRepository.saveCartItems(current);
    _emitUpdatedItems(current);
  }

  Future<void> clearCart() async {
    await cartRepository.clearCart();
    _emitUpdatedItems(const []);
  }

  Future<void> checkout({required int userId}) async {
    if (state.items.isEmpty) return;

    emit(state.copyWith(isPlacingOrder: true, errorMessage: null));
    final result = await placeOrderUseCase(
      userId: userId,
      items: state.items,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isPlacingOrder: false,
          errorMessage: failure.message,
        ),
      ),
      (orderResponse) => emit(
        CartState(
          items: const [],
          summary: const CartSummaryEntity(),
          isPlacingOrder: false,
          completedOrder: orderResponse,
        ),
      ),
    );
  }

  void clearCompletedOrder() {
    emit(state.copyWith(clearCompletedOrder: true));
  }

  void _emitUpdatedItems(List<CartItemEntity> items) {
    final summary = calculateCartTotalsUseCase(items);
    emit(
      state.copyWith(
        items: items,
        summary: summary,
        errorMessage: null,
      ),
    );
  }
}
