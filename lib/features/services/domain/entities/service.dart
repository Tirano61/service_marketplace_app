import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final String providerId;
  final String providerName;
  final String providerAvatar;
  final double? price;
  final String? priceType; // 'fixed', 'hourly', 'negotiable'
  final double coverageRadiusKm;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Service({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.providerId,
    required this.providerName,
    required this.providerAvatar,
    this.price,
    this.priceType = 'negotiable',
    required this.coverageRadiusKm,
    required this.images,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Service copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    String? providerId,
    String? providerName,
    String? providerAvatar,
    double? price,
    String? priceType,
    double? coverageRadiusKm,
    List<String>? images,
    double? rating,
    int? reviewCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerAvatar: providerAvatar ?? this.providerAvatar,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      coverageRadiusKm: coverageRadiusKm ?? this.coverageRadiusKm,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categoryId,
        categoryName,
        providerId,
        providerName,
        providerAvatar,
        price,
        priceType,
        coverageRadiusKm,
        images,
        rating,
        reviewCount,
        isActive,
        createdAt,
        updatedAt,
      ];
}
