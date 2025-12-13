import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
  });

  final String email;
  final String password;
  final String name;
  final String phone;
  final UserRole role;

  @override
  List<Object?> get props => [email, password, name, phone, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
