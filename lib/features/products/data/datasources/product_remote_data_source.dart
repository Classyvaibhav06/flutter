import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<PaginatedProductsModel> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
    String? categorySlug,
    int? delayMs,
  });

  Future<PaginatedProductsModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  });

  Future<List<CategoryModel>> getCategories();

  Future<ProductModel> getProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  const ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedProductsModel> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
    String? categorySlug,
    int? delayMs,
  }) async {
    try {
      final path = (categorySlug != null && categorySlug.isNotEmpty)
          ? ApiEndpoints.productsByCategory(categorySlug)
          : ApiEndpoints.products;

      final queryParams = <String, dynamic>{
        'limit': limit,
        'skip': skip,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
        if (order != null && order.isNotEmpty) 'order': order,
        if (delayMs != null && delayMs > 0) 'delay': delayMs,
      };

      final response = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return PaginatedProductsModel.fromJson(data);
      }
      throw ServerException(
        message: 'Failed to load products.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw DioClient.mapDioException(e);
    }
  }

  @override
  Future<PaginatedProductsModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.searchProducts,
        queryParameters: {
          'q': query,
          'limit': limit,
          'skip': skip,
        },
      );

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return PaginatedProductsModel.fromJson(data);
      }
      throw ServerException(
        message: 'Failed to search products.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw DioClient.mapDioException(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get<List<dynamic>>(ApiEndpoints.categories);
      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList();
      }
      throw ServerException(
        message: 'Failed to load categories.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw DioClient.mapDioException(e);
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.productById(id),
      );
      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return ProductModel.fromJson(data);
      }
      throw ServerException(
        message: 'Failed to load product details.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw DioClient.mapDioException(e);
    }
  }
}
