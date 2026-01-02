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
}

// Implementación MOCK temporal hasta que conectemos el backend
class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  // Datos mock para desarrollo
  final List<CategoryModel> _mockCategories = [
    const CategoryModel(id: '1', name: 'Plomería', icon: '🔧', serviceCount: 15),
    const CategoryModel(id: '2', name: 'Electricidad', icon: '⚡', serviceCount: 12),
    const CategoryModel(id: '3', name: 'Carpintería', icon: '🪚', serviceCount: 8),
    const CategoryModel(id: '4', name: 'Pintura', icon: '🎨', serviceCount: 10),
    const CategoryModel(id: '5', name: 'Jardinería', icon: '🌿', serviceCount: 6),
    const CategoryModel(id: '6', name: 'Limpieza', icon: '🧹', serviceCount: 20),
  ];

  final List<ServiceModel> _mockServices = [];

  ServicesRemoteDataSourceImpl() {
    // Inicializar con algunos servicios mock
    _mockServices.addAll([
      ServiceModel(
        id: '1',
        title: 'Reparación de Cañerías',
        description: 'Servicio profesional de plomería. Arreglo de filtraciones, cambio de cañerías, instalación de artefactos.',
        categoryId: '1',
        categoryName: 'Plomería',
        providerId: 'provider1',
        providerName: 'Juan Pérez',
        providerAvatar: 'https://ui-avatars.com/api/?name=Juan+Perez',
        price: 5000,
        priceType: 'fixed',
        coverageRadiusKm: 10,
        images: [
          'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400',
        ],
        rating: 4.5,
        reviewCount: 23,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular latencia
    return _mockCategories;
  }

  @override
  Future<List<ServiceModel>> getMyServices(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockServices.where((s) => s.providerId == providerId).toList();
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
    await Future.delayed(const Duration(seconds: 1));

    final category = _mockCategories.firstWhere((c) => c.id == categoryId);
    
    final newService = ServiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      categoryId: categoryId,
      categoryName: category.name,
      providerId: 'current_user_id', // Esto vendría del auth
      providerName: 'Usuario Actual',
      providerAvatar: 'https://ui-avatars.com/api/?name=Usuario+Actual',
      price: price,
      priceType: priceType ?? 'negotiable',
      coverageRadiusKm: coverageRadiusKm,
      images: imagePaths,
      rating: 0,
      reviewCount: 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockServices.add(newService);
    return newService;
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
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _mockServices.indexWhere((s) => s.id == serviceId);
    if (index == -1) {
      throw Exception('Service not found');
    }

    final oldService = _mockServices[index];
    String categoryName = oldService.categoryName;
    
    if (categoryId != null && categoryId != oldService.categoryId) {
      final category = _mockCategories.firstWhere((c) => c.id == categoryId);
      categoryName = category.name;
    }

    final updatedService = ServiceModel(
      id: oldService.id,
      title: title ?? oldService.title,
      description: description ?? oldService.description,
      categoryId: categoryId ?? oldService.categoryId,
      categoryName: categoryName,
      providerId: oldService.providerId,
      providerName: oldService.providerName,
      providerAvatar: oldService.providerAvatar,
      price: price ?? oldService.price,
      priceType: priceType ?? oldService.priceType,
      coverageRadiusKm: coverageRadiusKm ?? oldService.coverageRadiusKm,
      images: imagePaths ?? oldService.images,
      rating: oldService.rating,
      reviewCount: oldService.reviewCount,
      isActive: isActive ?? oldService.isActive,
      createdAt: oldService.createdAt,
      updatedAt: DateTime.now(),
    );

    _mockServices[index] = updatedService;
    return updatedService;
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockServices.removeWhere((s) => s.id == serviceId);
  }

  @override
  Future<void> toggleServiceStatus(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockServices.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final service = _mockServices[index];
      _mockServices[index] = ServiceModel(
        id: service.id,
        title: service.title,
        description: service.description,
        categoryId: service.categoryId,
        categoryName: service.categoryName,
        providerId: service.providerId,
        providerName: service.providerName,
        providerAvatar: service.providerAvatar,
        price: service.price,
        priceType: service.priceType,
        coverageRadiusKm: service.coverageRadiusKm,
        images: service.images,
        rating: service.rating,
        reviewCount: service.reviewCount,
        isActive: !service.isActive,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockServices.firstWhere((s) => s.id == id);
  }

  @override
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    double? latitude,
    double? longitude,
    int? page,
    int? limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    var filtered = _mockServices.where((s) => s.isActive).toList();
    
    if (categoryId != null) {
      filtered = filtered.where((s) => s.categoryId == categoryId).toList();
    }
    
    return filtered;
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final lowerQuery = query.toLowerCase();
    return _mockServices.where((s) =>
      s.title.toLowerCase().contains(lowerQuery) ||
      s.description.toLowerCase().contains(lowerQuery) ||
      s.categoryName.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
