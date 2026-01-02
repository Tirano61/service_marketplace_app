import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.categoryId,
    required super.categoryName,
    required super.providerId,
    required super.providerName,
    required super.providerAvatar,
    super.price,
    super.priceType,
    required super.coverageRadiusKm,
    required super.images,
    super.rating,
    super.reviewCount,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      categoryName: json['category_name'] ?? json['categoryName'] ?? '',
      providerId: json['provider_id'] ?? json['providerId'] ?? '',
      providerName: json['provider_name'] ?? json['providerName'] ?? '',
      providerAvatar: json['provider_avatar'] ?? json['providerAvatar'] ?? '',
      price: json['price']?.toDouble(),
      priceType: json['price_type'] ?? json['priceType'] ?? 'negotiable',
      coverageRadiusKm: (json['coverage_radius_km'] ?? json['coverageRadiusKm'] ?? 10).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'provider_id': providerId,
      'provider_name': providerName,
      'provider_avatar': providerAvatar,
      'price': price,
      'price_type': priceType,
      'coverage_radius_km': coverageRadiusKm,
      'images': images,
      'rating': rating,
      'review_count': reviewCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Service toEntity() => this;
}
