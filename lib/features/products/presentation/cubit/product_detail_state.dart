import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends ProductDetailState {
  final ProductEntity product;
  final int selectedQuantity;

  const ProductDetailLoaded({
    required this.product,
    this.selectedQuantity = 1,
  });

  ProductDetailLoaded copyWith({
    ProductEntity? product,
    int? selectedQuantity,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      selectedQuantity: selectedQuantity ?? this.selectedQuantity,
    );
  }

  @override
  List<Object?> get props => [product, selectedQuantity];
}

class ProductDetailNotFound extends ProductDetailState {
  final String message;

  const ProductDetailNotFound([
    this.message = 'The requested product was not found (404).',
  ]);

  @override
  List<Object?> get props => [message];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
