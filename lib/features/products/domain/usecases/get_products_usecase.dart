import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  const GetProductsUseCase(this.repository);

  Future<Either<Failure, PaginatedProductsEntity>> call({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
    String? categorySlug,
    int? delayMs,
  }) {
    return repository.getProducts(
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
      categorySlug: categorySlug,
      delayMs: delayMs,
    );
  }
}

class SearchProductsUseCase {
  final ProductRepository repository;

  const SearchProductsUseCase(this.repository);

  Future<Either<Failure, PaginatedProductsEntity>> call({
    required String query,
    int limit = 20,
    int skip = 0,
  }) {
    return repository.searchProducts(
      query: query.trim(),
      limit: limit,
      skip: skip,
    );
  }
}

class GetCategoriesUseCase {
  final ProductRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}

class GetProductDetailUseCase {
  final ProductRepository repository;

  const GetProductDetailUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(int id) {
    return repository.getProductById(id);
  }
}
