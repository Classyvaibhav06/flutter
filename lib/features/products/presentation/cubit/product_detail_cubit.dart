import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;

  ProductDetailCubit({required this.getProductDetailUseCase})
      : super(const ProductDetailInitial());

  Future<void> loadProduct(int productId) async {
    emit(const ProductDetailLoading());
    final result = await getProductDetailUseCase(productId);
    result.fold(
      (failure) {
        if (failure is NotFoundFailure || failure.statusCode == 404) {
          emit(ProductDetailNotFound(failure.message));
        } else {
          emit(ProductDetailError(failure.message));
        }
      },
      (product) => emit(
        ProductDetailLoaded(
          product: product,
          selectedQuantity: 1,
        ),
      ),
    );
  }

  void incrementQuantity() {
    final current = state;
    if (current is ProductDetailLoaded) {
      if (current.selectedQuantity < current.product.stock) {
        emit(current.copyWith(selectedQuantity: current.selectedQuantity + 1));
      }
    }
  }

  void decrementQuantity() {
    final current = state;
    if (current is ProductDetailLoaded) {
      if (current.selectedQuantity > 1) {
        emit(current.copyWith(selectedQuantity: current.selectedQuantity - 1));
      }
    }
  }
}
