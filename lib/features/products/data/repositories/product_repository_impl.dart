import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  const ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, PaginatedProductsEntity>> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
    String? categorySlug,
    int? delayMs,
  }) async {
    try {
      final response = await remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
        sortBy: sortBy,
        order: order,
        categorySlug: categorySlug,
        delayMs: delayMs,
      );

      if (skip == 0 && categorySlug == null && response.products.isNotEmpty) {
        await localDataSource.cacheProducts(
          response.products.whereType<ProductModel>().toList(),
        );
      }

      return Right(response);
    } on NetworkException catch (e) {
      if (skip == 0) {
        final cached = await localDataSource.getCachedProducts();
        if (cached.isNotEmpty) {
          return Right(
            PaginatedProductsModel(
              products: cached,
              total: cached.length,
              skip: 0,
              limit: cached.length,
              isFromCache: true,
            ),
          );
        }
      }
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error loading products.'));
    }
  }

  @override
  Future<Either<Failure, PaginatedProductsEntity>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
      );
      return Right(response);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error during search.'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(ServerFailure('Failed to fetch categories.'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(ServerFailure('Unable to load product details.'));
    }
  }
}
