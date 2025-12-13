import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) {
    return _repository.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );
  }
}
