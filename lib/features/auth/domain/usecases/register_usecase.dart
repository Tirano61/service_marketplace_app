import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required double latitude,
    required double longitude,
    required String province,
    required String city,
    required String address,
    double? workRadius,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
      latitude: latitude,
      longitude: longitude,
      province: province,
      city: city,
      address: address,
      workRadius: workRadius,
    );
  }
}
