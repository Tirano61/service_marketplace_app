part of 'service_form_bloc.dart';

abstract class ServiceFormState extends Equatable {
  const ServiceFormState();

  @override
  List<Object?> get props => [];
}

class ServiceFormInitial extends ServiceFormState {}

class ServiceFormLoading extends ServiceFormState {}

class ServiceFormReady extends ServiceFormState {
  final List<Category> categories;
  final String? editingServiceId;
  final String title;
  final String description;
  final String? categoryId;
  final String price;
  final String priceType;
  final double coverageRadiusKm;
  final List<String> images;
  final bool isValid;

  const ServiceFormReady({
    required this.categories,
    this.editingServiceId,
    this.title = '',
    this.description = '',
    this.categoryId,
    this.price = '',
    this.priceType = 'negotiable',
    this.coverageRadiusKm = 5.0,
    this.images = const [],
    this.isValid = false,
  });

  ServiceFormReady copyWith({
    List<Category>? categories,
    String? editingServiceId,
    String? title,
    String? description,
    String? categoryId,
    String? price,
    String? priceType,
    double? coverageRadiusKm,
    List<String>? images,
    bool? isValid,
  }) {
    return ServiceFormReady(
      categories: categories ?? this.categories,
      editingServiceId: editingServiceId ?? this.editingServiceId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      coverageRadiusKm: coverageRadiusKm ?? this.coverageRadiusKm,
      images: images ?? this.images,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        editingServiceId,
        title,
        description,
        categoryId,
        price,
        priceType,
        coverageRadiusKm,
        images,
        isValid,
      ];
}

class ServiceFormSubmitting extends ServiceFormState {
  final int? uploadingImageIndex;
  final int? totalImages;

  const ServiceFormSubmitting({
    this.uploadingImageIndex,
    this.totalImages,
  });

  @override
  List<Object?> get props => [uploadingImageIndex, totalImages];
}

class ServiceFormSuccess extends ServiceFormState {
  final Service service;

  const ServiceFormSuccess(this.service);

  @override
  List<Object?> get props => [service];
}

class ServiceFormError extends ServiceFormState {
  final String message;

  const ServiceFormError(this.message);

  @override
  List<Object?> get props => [message];
}
