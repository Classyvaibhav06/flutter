import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, PaginatedProductsEntity>> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
    String? categorySlug,
    int? delayMs,
  });

  Future<Either<Failure, PaginatedProductsEntity>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, ProductEntity>> getProductById(int id);
}
