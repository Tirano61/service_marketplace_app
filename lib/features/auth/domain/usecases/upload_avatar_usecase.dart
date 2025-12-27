import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class UploadAvatarUseCase {
  UploadAvatarUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String>> call({required String filePath}) {
    return _repository.uploadAvatar(filePath: filePath);
  }
}
