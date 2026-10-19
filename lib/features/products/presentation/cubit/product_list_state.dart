import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

enum ProductSortOption {
  featured('Featured', null, null),
  priceLowToHigh('Price: Low to High', 'price', 'asc'),
  priceHighToLow('Price: High to Low', 'price', 'desc'),
  ratingHigh('Top Rated', 'rating', 'desc'),
  titleAZ('Title: A to Z', 'title', 'asc');

  final String label;
  final String? sortBy;
  final String? order;

  const ProductSortOption(this.label, this.sortBy, this.order);
}

enum ProductListStatus {
  initial,
  loading,
  success,
  empty,
  loadingMore,
  failure,
}

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String? selectedCategorySlug;
  final String searchQuery;
  final ProductSortOption sortOption;
  final int total;
  final bool hasReachedMax;
  final bool isOfflineCache;
  final String? errorMessage;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategorySlug,
    this.searchQuery = '',
    this.sortOption = ProductSortOption.featured,
    this.total = 0,
    this.hasReachedMax = false,
    this.isOfflineCache = false,
    this.errorMessage,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? selectedCategorySlug,
    bool clearCategory = false,
    String? searchQuery,
    ProductSortOption? sortOption,
    int? total,
    bool? hasReachedMax,
    bool? isOfflineCache,
    String? errorMessage,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategorySlug: clearCategory
          ? null
          : (selectedCategorySlug ?? this.selectedCategorySlug),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isOfflineCache: isOfflineCache ?? this.isOfflineCache,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categories,
        selectedCategorySlug,
        searchQuery,
        sortOption,
        total,
        hasReachedMax,
        isOfflineCache,
        errorMessage,
      ];
}
