import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/calculate_cart_totals_usecase.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/products/data/datasources/product_local_data_source.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/cubit/product_detail_cubit.dart';
import '../../features/products/presentation/cubit/product_list_cubit.dart';
import '../../features/profile/presentation/cubit/theme_cubit.dart';
import '../../features/wishlist/presentation/cubit/wishlist_cubit.dart';
import '../network/dio_client.dart';
import '../network/session_manager.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Network
  sl.registerLazySingleton<SessionManager>(() => SessionManager());
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      authLocalDataSource: sl(),
      onSessionExpired: () => sl<SessionManager>()
          .expireSession('Your session has expired. Please sign in again.'),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailUseCase(sl()));

  sl.registerLazySingleton(() => const CalculateCartTotalsUseCase());
  sl.registerLazySingleton(() => PlaceOrderUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      checkAuthUseCase: sl(),
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductListCubit(
      getProductsUseCase: sl(),
      searchProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductDetailCubit(
      getProductDetailUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CartCubit(
      cartRepository: sl(),
      calculateCartTotalsUseCase: sl(),
      placeOrderUseCase: sl(),
    ),
  );

  sl.registerFactory(() => WishlistCubit(sharedPreferences: sl()));
  sl.registerFactory(() => ThemeCubit(sharedPreferences: sl()));
}
