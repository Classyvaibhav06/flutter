import 'package:equatable/equatable.dart';
import 'review_entity.dart';

class ProductEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand; // Null-safe: absent on some products in DummyJSON
  final String? sku;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final String? returnPolicy;
  final List<String> images;
  final String thumbnail;
  final List<ReviewEntity> reviews;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    this.sku,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.returnPolicy,
    required this.images,
    required this.thumbnail,
    required this.reviews,
  });

  bool get isOutOfStock => stock <= 0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        price,
        discountPercentage,
        rating,
        stock,
        brand,
        sku,
        warrantyInformation,
        shippingInformation,
        availabilityStatus,
        returnPolicy,
        images,
        thumbnail,
        reviews,
      ];
}
