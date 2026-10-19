import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final CartRemoteDataSource remoteDataSource;

  const CartRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<CartItemEntity>> getCartItems() {
    return localDataSource.getCartItems();
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) {
    final models = items.map(CartItemModel.fromEntity).toList();
    return localDataSource.saveCartItems(models);
  }

  @override
  Future<void> clearCart() {
    return localDataSource.clearCart();
  }

  @override
  Future<Either<Failure, OrderResponseEntity>> placeOrder({
    required int userId,
    required List<CartItemEntity> items,
  }) async {
    try {
      final orderResponse = await remoteDataSource.placeOrder(
        userId: userId,
        items: items,
      );
      await localDataSource.clearCart();
      return Right(orderResponse);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error placing order.'));
    }
  }
}
