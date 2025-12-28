import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

enum AuthStatus { 
  initial, 
  loading, 
  authenticated, 
  unauthenticated, 
  error,
  emailVerificationPending,
  uploadingAvatar,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.emailVerificationPending,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? emailVerificationPending; // Email waiting for verification

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? emailVerificationPending,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      emailVerificationPending: emailVerificationPending ?? this.emailVerificationPending,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, emailVerificationPending];
}
