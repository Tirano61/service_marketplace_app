import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service.dart';
import '../repositories/services_repository.dart';

class UpdateServiceParams {
  final String serviceId;
  final String? title;
  final String? description;
  final String? categoryId;
  final double? price;
  final String? priceType;
  final double? coverageRadiusKm;
  final List<String>? imagePaths;
  final bool? isActive;

  UpdateServiceParams({
    required this.serviceId,
    this.title,
    this.description,
    this.categoryId,
    this.price,
    this.priceType,
    this.coverageRadiusKm,
    this.imagePaths,
    this.isActive,
  });
}

class UpdateServiceUseCase {
  final ServicesRepository repository;

  UpdateServiceUseCase(this.repository);

  Future<Either<Failure, Service>> call(UpdateServiceParams params) async {
    return await repository.updateService(
      serviceId: params.serviceId,
      title: params.title,
      description: params.description,
      categoryId: params.categoryId,
      price: params.price,
      priceType: params.priceType,
      coverageRadiusKm: params.coverageRadiusKm,
      imagePaths: params.imagePaths,
      isActive: params.isActive,
    );
  }
}
