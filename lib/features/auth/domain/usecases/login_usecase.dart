import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      return const Left(ValidationFailure('Username is required.'));
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password is required.'));
    }
    if (password.length < 4) {
      return const Left(
        ValidationFailure('Password must be at least 4 characters.'),
      );
    }

    return repository.login(
      username: trimmedUsername,
      password: password,
    );
  }
}
