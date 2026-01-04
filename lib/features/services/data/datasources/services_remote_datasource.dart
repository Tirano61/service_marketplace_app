import 'dart:io';
import 'package:dio/dio.dart';
import '../models/service_model.dart';
import '../models/category_model.dart';

abstract class ServicesRemoteDataSource {
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    double? latitude,
    double? longitude,
    int? page,
    int? limit,
  });

  Future<ServiceModel> getServiceById(String id);

  Future<List<ServiceModel>> searchServices(String query);

  Future<List<CategoryModel>> getCategories();

  Future<List<ServiceModel>> getMyServices(String providerId);

  Future<ServiceModel> createService({
    required String title,
    required String description,
    required String categoryId,
    double? price,
    String? priceType,
    required double coverageRadiusKm,
    required List<String> imagePaths,
  });

  Future<ServiceModel> updateService({
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

  Future<void> deleteService(String serviceId);

  Future<void> toggleServiceStatus(String serviceId);

  Future<String> uploadServiceImage(String serviceId, String imagePath);

  Future<void> deleteServiceImage(String serviceId, String imageUrl);
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final Dio _dio;

  ServicesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo categorías: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceModel>> getMyServices(String providerId) async {
    try {
      final response = await _dio.get('/services/my-services');
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo mis servicios: $e');
      rethrow;
    }
  }

  @override
  Future<ServiceModel> createService({
    required String title,
    required String description,
    required String categoryId,
    double? price,
    String? priceType,
    required double coverageRadiusKm,
    required List<String> imagePaths,
  }) async {
    try {
      final response = await _dio.post(
        '/services/create',
        data: {
          'title': title,
          'description': description,
          'categoryId': categoryId,
          'price': price,
          'priceType': priceType ?? 'negotiable',
          'coverageRadiusKm': coverageRadiusKm,
        },
      );

      final createdService = ServiceModel.fromJson(response.data);

      // Subir las imágenes una por una
      for (final imagePath in imagePaths) {
        try {
          await uploadServiceImage(createdService.id, imagePath);
        } catch (e) {
          print('Error subiendo imagen: $e');
        }
      }

      return createdService;
    } catch (e) {
      print('Error creando servicio: $e');
      rethrow;
    }
  }

  @override
  Future<ServiceModel> updateService({
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
      final response = await _dio.patch(
        '/services/$serviceId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (categoryId != null) 'categoryId': categoryId,
          if (price != null) 'price': price,
          if (priceType != null) 'priceType': priceType,
          if (coverageRadiusKm != null) 'coverageRadiusKm': coverageRadiusKm,
          if (isActive != null) 'isActive': isActive,
        },
      );

      final updatedService = ServiceModel.fromJson(response.data);

      // Si hay imágenes, gestionarlas
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (final imagePath in imagePaths) {
          if (!imagePath.startsWith('http')) {
            try {
              await uploadServiceImage(serviceId, imagePath);
            } catch (e) {
              print('Error subiendo imagen: $e');
            }
          }
        }
      }

      return updatedService;
    } catch (e) {
      print('Error actualizando servicio: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      await _dio.delete('/services/$serviceId');
    } catch (e) {
      print('Error eliminando servicio: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleServiceStatus(String serviceId) async {
    try {
      await _dio.patch('/services/$serviceId/toggle-status');
    } catch (e) {
      print('Error cambiando estado del servicio: $e');
      rethrow;
    }
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await _dio.get('/services/$id');
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      print('Error obteniendo servicio: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    double? latitude,
    double? longitude,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/services',
        queryParameters: {
          if (categoryId != null) 'categoryId': categoryId,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo servicios: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final response = await _dio.get(
        '/services/search',
        queryParameters: {'query': query},
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      print('Error buscando servicios: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadServiceImage(String serviceId, String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/upload/service-images/$serviceId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final serviceData = response.data;
      if (serviceData is Map<String, dynamic>) {
        final images = serviceData['images'] as List?;
        if (images != null && images.isNotEmpty) {
          return images.last as String;
        }
      }

      throw Exception('No se pudo obtener la URL de la imagen');
    } catch (e) {
      print('Error subiendo imagen: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteServiceImage(String serviceId, String imageUrl) async {
    try {
      await _dio.delete(
        '/services/$serviceId/images',
        data: {'imageUrl': imageUrl},
      );
    } catch (e) {
      print('Error eliminando imagen: $e');
      rethrow;
    }
  }
}
