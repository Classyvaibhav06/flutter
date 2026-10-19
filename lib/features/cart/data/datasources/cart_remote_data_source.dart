import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<OrderResponseModel> placeOrder({
    required int userId,
    required List<CartItemEntity> items,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  const CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<OrderResponseModel> placeOrder({
    required int userId,
    required List<CartItemEntity> items,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.addCart,
        data: {
          'userId': userId > 0 ? userId : 1,
          'products': items
              .map(
                (e) => {
                  'id': e.productId,
                  'quantity': e.quantity,
                },
              )
              .toList(),
        },
      );

      final data = response.data;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data != null) {
        return OrderResponseModel.fromJson(data);
      }
      throw ServerException(
        message: 'Failed to place order.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw DioClient.mapDioException(e);
    }
  }
}
