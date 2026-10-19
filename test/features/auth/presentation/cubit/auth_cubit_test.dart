import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/either.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/auth/domain/entities/user_entity.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockCheckAuthUseCase extends Mock implements CheckAuthUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late AuthCubit authCubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockCheckAuthUseCase mockCheckAuthUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

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
    mockLoginUseCase = MockLoginUseCase();
    mockCheckAuthUseCase = MockCheckAuthUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();

    authCubit = AuthCubit(
      loginUseCase: mockLoginUseCase,
      checkAuthUseCase: mockCheckAuthUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  tearDown(() => authCubit.close());

  group('AuthCubit BLoC Tests', () {
    blocTest<AuthCubit, AuthState>(
      '16. emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(
          () => mockLoginUseCase(
            username: 'emilys',
            password: 'emilyspass',
          ),
        ).thenAnswer((_) async => const Right(tUser));
        return authCubit;
      },
      act: (cubit) => cubit.login(
        username: 'emilys',
        password: 'emilyspass',
      ),
      expect: () => const [
        AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '17. emits [AuthLoading, AuthFailure] when login fails with 400 Invalid credentials',
      build: () {
        when(
          () => mockLoginUseCase(
            username: 'emilys',
            password: 'wrongpassword',
          ),
        ).thenAnswer(
          (_) async => const Left(
            ServerFailure('Invalid credentials', statusCode: 400),
          ),
        );
        return authCubit;
      },
      act: (cubit) => cubit.login(
        username: 'emilys',
        password: 'wrongpassword',
      ),
      expect: () => const [
        AuthLoading(),
        AuthFailure('Invalid credentials'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '18. emits [AuthUnauthenticated] when logout is called',
      build: () {
        when(() => mockLogoutUseCase()).thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => const [
        AuthUnauthenticated(),
      ],
    );
  });
}
