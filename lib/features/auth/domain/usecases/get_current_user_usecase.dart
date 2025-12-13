import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User?>> call() {
    return _repository.getCurrentUser();
  }
}
