part of 'service_form_bloc.dart';

abstract class ServiceFormEvent extends Equatable {
  const ServiceFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends ServiceFormEvent {}

class LoadServiceForEdit extends ServiceFormEvent {
  final Service service;

  const LoadServiceForEdit(this.service);

  @override
  List<Object?> get props => [service];
}

class TitleChanged extends ServiceFormEvent {
  final String title;

  const TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class DescriptionChanged extends ServiceFormEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class CategoryChanged extends ServiceFormEvent {
  final String categoryId;

  const CategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class PriceChanged extends ServiceFormEvent {
  final String price;

  const PriceChanged(this.price);

  @override
  List<Object?> get props => [price];
}

class PriceTypeChanged extends ServiceFormEvent {
  final String priceType;

  const PriceTypeChanged(this.priceType);

  @override
  List<Object?> get props => [priceType];
}

class CoverageRadiusChanged extends ServiceFormEvent {
  final double radius;

  const CoverageRadiusChanged(this.radius);

  @override
  List<Object?> get props => [radius];
}

class ImageAdded extends ServiceFormEvent {
  final String imagePath;

  const ImageAdded(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ImageRemoved extends ServiceFormEvent {
  final String imagePath;

  const ImageRemoved(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class SubmitForm extends ServiceFormEvent {}
