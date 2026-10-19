import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/either.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/auth/domain/entities/user_entity.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  const tUser = UserEntity(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase Tests', () {
    test('10. returns ValidationFailure when username is empty', () async {
      final result = await useCase(username: '   ', password: 'emilyspass');

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('11. returns ValidationFailure when password is shorter than 4 chars',
        () async {
      final result = await useCase(username: 'emilys', password: '123');

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('12. delegates to AuthRepository when credentials are valid',
        () async {
      when(
        () => mockRepository.login(
          username: 'emilys',
          password: 'emilyspass',
        ),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result, const Right<Failure, UserEntity>(tUser));
      verify(
        () => mockRepository.login(
          username: 'emilys',
          password: 'emilyspass',
        ),
      ).called(1);
    });
  });
}
