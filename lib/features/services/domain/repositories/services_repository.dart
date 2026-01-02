import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service.dart';
import '../entities/category.dart';

abstract class ServicesRepository {
  // Para clientes
  Future<Either<Failure, List<Service>>> getServices({
    String? categoryId,
    double? latitude,
    double? longitude,
    int? page,
    int? limit,
  });

  Future<Either<Failure, Service>> getServiceById(String id);

  Future<Either<Failure, List<Service>>> searchServices(String query);

  Future<Either<Failure, List<Category>>> getCategories();

  // Para proveedores
  Future<Either<Failure, List<Service>>> getMyServices(String providerId);

  Future<Either<Failure, Service>> createService({
    required String title,
    required String description,
    required String categoryId,
    double? price,
    String? priceType,
    required double coverageRadiusKm,
    required List<String> imagePaths,
  });

  Future<Either<Failure, Service>> updateService({
    required String serviceId,
    String? title,
    String? description,
    String? categoryId,
    double? price,
    String? priceType,
    double? coverageRadiusKm,
    List<String>? imagePaths,
    bool? isActive,
  });

  Future<Either<Failure, void>> deleteService(String serviceId);

  Future<Either<Failure, void>> toggleServiceStatus(String serviceId);
}
