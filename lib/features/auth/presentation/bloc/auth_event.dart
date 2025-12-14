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
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.city,
    required this.address,
    this.workRadius,
  });

  final String name;
  final String email;
  final String password;
  final String phone;
  final UserRole role;
  final double latitude;
  final double longitude;
  final String province;
  final String city;
  final String address;
  final double? workRadius;

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        phone,
        role,
        latitude,
        longitude,
        province,
        city,
        address,
        workRadius,
      ];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
