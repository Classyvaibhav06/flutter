import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class CategoryEntity extends Equatable {
  final String slug;
  final String name;
  final String url;

  const CategoryEntity({
    required this.slug,
    required this.name,
    required this.url,
  });

  @override
  List<Object?> get props => [slug, name, url];
}

class PaginatedProductsEntity extends Equatable {
  final List<ProductEntity> products;
  final int total;
  final int skip;
  final int limit;
  final bool isFromCache;

  const PaginatedProductsEntity({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
    this.isFromCache = false,
  });

  bool get hasReachedMax =>
      (skip + products.length) >= total || products.isEmpty;

  @override
  List<Object?> get props => [products, total, skip, limit, isFromCache];
}
