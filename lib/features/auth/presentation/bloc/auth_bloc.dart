import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message ?? 'Error al iniciar sesión',
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _registerUseCase(
      email: event.email,
      password: event.password,
      name: event.name,
      phone: event.phone,
      role: event.role,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message ?? 'Error al registrarse',
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message ?? 'Error al cerrar sesión',
        ),
      ),
      (_) => emit(
        const AuthState(status: AuthStatus.unauthenticated),
      ),
    );
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => emit(
        const AuthState(status: AuthStatus.unauthenticated),
      ),
      (user) {
        if (user != null) {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
            ),
          );
        } else {
          emit(
            const AuthState(status: AuthStatus.unauthenticated),
          );
        }
      },
    );
  }
}
