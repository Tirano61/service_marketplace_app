part of 'my_services_bloc.dart';

abstract class MyServicesEvent extends Equatable {
  const MyServicesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyServices extends MyServicesEvent {
  final String providerId;

  const LoadMyServices(this.providerId);

  @override
  List<Object?> get props => [providerId];
}

class RefreshMyServices extends MyServicesEvent {
  final String providerId;

  const RefreshMyServices(this.providerId);

  @override
  List<Object?> get props => [providerId];
}

class DeleteServiceEvent extends MyServicesEvent {
  final String serviceId;

  const DeleteServiceEvent(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class ToggleServiceStatus extends MyServicesEvent {
  final String serviceId;

  const ToggleServiceStatus(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}
