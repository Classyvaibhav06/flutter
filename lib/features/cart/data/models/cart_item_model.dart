import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.productId,
    required super.title,
    required super.price,
    required super.discountPercentage,
    required super.thumbnail,
    required super.quantity,
    required super.stock,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      productId: entity.productId,
      title: entity.title,
      price: entity.price,
      discountPercentage: entity.discountPercentage,
      thumbnail: entity.thumbnail,
      quantity: entity.quantity,
      stock: entity.stock,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      stock: (json['stock'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'discountPercentage': discountPercentage,
      'thumbnail': thumbnail,
      'quantity': quantity,
      'stock': stock,
    };
  }
}

class OrderResponseModel extends OrderResponseEntity {
  const OrderResponseModel({
    required super.orderId,
    required super.totalProducts,
    required super.totalQuantity,
    required super.total,
    required super.discountedTotal,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      orderId: (json['id'] as num?)?.toInt() ?? 100,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 1,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
