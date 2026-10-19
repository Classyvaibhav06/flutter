import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../error/exceptions.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;
  late final Dio _refreshDio;

  DioClient({
    required AuthLocalDataSource authLocalDataSource,
    void Function()? onSessionExpired,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _refreshDio = Dio(baseOptions);
    dio = Dio(baseOptions);

    dio.interceptors.add(
      AuthInterceptor(
        localDataSource: authLocalDataSource,
        refreshDio: _refreshDio,
        onSessionExpired: onSessionExpired,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }

  static Exception mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return const NetworkException(
        message:
            'Connection timed out or no internet access. Please check your network.',
      );
    }

    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String?;
    }

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedException(
        message:
            serverMessage ?? 'Your session has expired. Please sign in again.',
      );
    }

    if (statusCode == 404) {
      return NotFoundException(
        message: serverMessage ?? 'The requested item was not found (404).',
      );
    }

    if (statusCode == 400) {
      return ServerException(
        message: serverMessage ?? 'Invalid credentials or bad request.',
        statusCode: 400,
      );
    }

    return ServerException(
      message: serverMessage ??
          'Server error (${statusCode ?? 'unknown'}). Please try again.',
      statusCode: statusCode,
    );
  }
}
