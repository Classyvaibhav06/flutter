import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int productId;
  final String title;
  final double price;
  final double discountPercentage;
  final String thumbnail;
  final int quantity;
  final int stock;

  const CartItemEntity({
    required this.productId,
    required this.title,
    required this.price,
    required this.discountPercentage,
    required this.thumbnail,
    required this.quantity,
    required this.stock,
  });

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      productId: productId,
      title: title,
      price: price,
      discountPercentage: discountPercentage,
      thumbnail: thumbnail,
      quantity: quantity ?? this.quantity,
      stock: stock,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        title,
        price,
        discountPercentage,
        thumbnail,
        quantity,
        stock,
      ];
}

class CartSummaryEntity extends Equatable {
  final double subtotal;
  final double totalDiscount;
  final double grandTotal;
  final int totalItems;

  const CartSummaryEntity({
    this.subtotal = 0.0,
    this.totalDiscount = 0.0,
    this.grandTotal = 0.0,
    this.totalItems = 0,
  });

  @override
  List<Object?> get props => [subtotal, totalDiscount, grandTotal, totalItems];
}

class OrderResponseEntity extends Equatable {
  final int orderId;
  final int totalProducts;
  final int totalQuantity;
  final double total;
  final double discountedTotal;

  const OrderResponseEntity({
    required this.orderId,
    required this.totalProducts,
    required this.totalQuantity,
    required this.total,
    required this.discountedTotal,
  });

  @override
  List<Object?> get props => [
        orderId,
        totalProducts,
        totalQuantity,
        total,
        discountedTotal,
      ];
}
