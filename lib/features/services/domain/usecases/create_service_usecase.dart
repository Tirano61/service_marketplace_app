import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service.dart';
import '../repositories/services_repository.dart';

class CreateServiceParams {
  final String title;
  final String description;
  final String categoryId;
  final double? price;
  final String? priceType;
  final double coverageRadiusKm;
  final List<String> imagePaths;

  CreateServiceParams({
    required this.title,
    required this.description,
    required this.categoryId,
    this.price,
    this.priceType = 'negotiable',
    required this.coverageRadiusKm,
    required this.imagePaths,
  });
}

class CreateServiceUseCase {
  final ServicesRepository repository;

  CreateServiceUseCase(this.repository);

  Future<Either<Failure, Service>> call(CreateServiceParams params) async {
    return await repository.createService(
      title: params.title,
      description: params.description,
      categoryId: params.categoryId,
      price: params.price,
      priceType: params.priceType,
      coverageRadiusKm: params.coverageRadiusKm,
      imagePaths: params.imagePaths,
    );
  }
}
