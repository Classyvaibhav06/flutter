import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 30,
        },
      );

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return UserModel.fromJson(data);
      }
      throw ServerException(
        message: 'Invalid username or password.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw DioClient.mapDioException(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return UserModel.fromJson(data);
      }
      throw ServerException(
        message: 'Failed to load profile.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw DioClient.mapDioException(e);
    }
  }
}
