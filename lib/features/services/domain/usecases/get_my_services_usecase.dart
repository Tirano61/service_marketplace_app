import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service.dart';
import '../repositories/services_repository.dart';

class GetMyServicesUseCase {
  final ServicesRepository repository;

  GetMyServicesUseCase(this.repository);

  Future<Either<Failure, List<Service>>> call(String providerId) async {
    return await repository.getMyServices(providerId);
  }
}
