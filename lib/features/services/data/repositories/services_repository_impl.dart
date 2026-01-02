import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;

  ServicesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Service>>> getServices({
    String? categoryId,
    double? latitude,
    double? longitude,
    int? page,
    int? limit,
  }) async {
    try {
      final services = await remoteDataSource.getServices(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        page: page,
        limit: limit,
      );
      return Right(services);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al obtener servicios'));
    }
  }

  @override
  Future<Either<Failure, Service>> getServiceById(String id) async {
    try {
      final service = await remoteDataSource.getServiceById(id);
      return Right(service);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al obtener el servicio'));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> searchServices(String query) async {
    try {
      final services = await remoteDataSource.searchServices(query);
      return Right(services);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error en la búsqueda'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al obtener categorías'));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getMyServices(String providerId) async {
    try {
      final services = await remoteDataSource.getMyServices(providerId);
      return Right(services);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al obtener tus servicios'));
    }
  }

  @override
  Future<Either<Failure, Service>> createService({
    required String title,
    required String description,
    required String categoryId,
    double? price,
    String? priceType,
    required double coverageRadiusKm,
    required List<String> imagePaths,
  }) async {
    try {
      final service = await remoteDataSource.createService(
        title: title,
        description: description,
        categoryId: categoryId,
        price: price,
        priceType: priceType,
        coverageRadiusKm: coverageRadiusKm,
        imagePaths: imagePaths,
      );
      return Right(service);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al crear el servicio'));
    }
  }

  @override
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
  }) async {
    try {
      final service = await remoteDataSource.updateService(
        serviceId: serviceId,
        title: title,
        description: description,
        categoryId: categoryId,
        price: price,
        priceType: priceType,
        coverageRadiusKm: coverageRadiusKm,
        imagePaths: imagePaths,
        isActive: isActive,
      );
      return Right(service);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar el servicio'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String serviceId) async {
    try {
      await remoteDataSource.deleteService(serviceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al eliminar el servicio'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleServiceStatus(String serviceId) async {
    try {
      await remoteDataSource.toggleServiceStatus(serviceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al cambiar el estado'));
    }
  }
}
