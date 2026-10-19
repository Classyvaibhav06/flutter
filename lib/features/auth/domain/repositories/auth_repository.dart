import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<bool> hasValidSession();

  Future<void> logout();
}
