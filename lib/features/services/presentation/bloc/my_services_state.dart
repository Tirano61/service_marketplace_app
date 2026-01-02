part of 'my_services_bloc.dart';

abstract class MyServicesState extends Equatable {
  const MyServicesState();

  @override
  List<Object?> get props => [];
}

class MyServicesInitial extends MyServicesState {}

class MyServicesLoading extends MyServicesState {}

class MyServicesLoaded extends MyServicesState {
  final List<Service> services;

  const MyServicesLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class MyServicesError extends MyServicesState {
  final String message;

  const MyServicesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ServiceDeleting extends MyServicesState {
  final String serviceId;

  const ServiceDeleting(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class ServiceDeleted extends MyServicesState {
  final String serviceId;

  const ServiceDeleted(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}
