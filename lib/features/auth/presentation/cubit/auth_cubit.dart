import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.checkAuthUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial());

  Future<void> checkSession() async {
    emit(const AuthLoading());
    final hasSession = await checkAuthUseCase();
    if (!hasSession) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        if (failure.statusCode == 401) {
          emit(AuthUnauthenticated(message: failure.message));
        } else {
          emit(const AuthAuthenticated());
        }
      },
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      username: username,
      password: password,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> logout({String? reason}) async {
    await logoutUseCase();
    emit(AuthUnauthenticated(message: reason));
  }
}
