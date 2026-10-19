import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final Dio refreshDio;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required this.localDataSource,
    required this.refreshDio,
    this.onSessionExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = options.path.contains(ApiEndpoints.login) ||
        options.path.contains(ApiEndpoints.refresh);

    if (!isAuthEndpoint) {
      final accessToken = await localDataSource.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    final isAuthPath = requestOptions.path.contains(ApiEndpoints.login) ||
        requestOptions.path.contains(ApiEndpoints.refresh);

    if (statusCode == 401 &&
        !isAuthPath &&
        requestOptions.extra['retried'] != true) {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
            ApiEndpoints.refresh,
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': 30,
            },
          );

          final data = refreshResponse.data;
          if (refreshResponse.statusCode == 200 && data != null) {
            final newAccess = data['accessToken'] as String? ?? '';
            final newRefresh = data['refreshToken'] as String? ?? refreshToken;

            if (newAccess.isNotEmpty) {
              await localDataSource.saveTokens(
                accessToken: newAccess,
                refreshToken: newRefresh,
              );

              requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              requestOptions.extra['retried'] = true;

              final clonedResponse =
                  await refreshDio.fetch<dynamic>(requestOptions);
              return handler.resolve(clonedResponse);
            }
          }
        } on DioException catch (_) {
          await localDataSource.clearSession();
          onSessionExpired?.call();
        }
      } else {
        await localDataSource.clearSession();
        onSessionExpired?.call();
      }
    }

    handler.next(err);
  }
}
