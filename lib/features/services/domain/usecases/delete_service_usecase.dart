import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/services_repository.dart';

class DeleteServiceUseCase {
  final ServicesRepository repository;

  DeleteServiceUseCase(this.repository);

  Future<Either<Failure, void>> call(String serviceId) async {
    return await repository.deleteService(serviceId);
  }
}
