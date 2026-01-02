import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/get_my_services_usecase.dart';
import '../../domain/usecases/delete_service_usecase.dart';

part 'my_services_event.dart';
part 'my_services_state.dart';

class MyServicesBloc extends Bloc<MyServicesEvent, MyServicesState> {
  final GetMyServicesUseCase getMyServicesUseCase;
  final DeleteServiceUseCase deleteServiceUseCase;

  MyServicesBloc({
    required this.getMyServicesUseCase,
    required this.deleteServiceUseCase,
  }) : super(MyServicesInitial()) {
    on<LoadMyServices>(_onLoadMyServices);
    on<RefreshMyServices>(_onRefreshMyServices);
    on<DeleteServiceEvent>(_onDeleteService);
  }

  Future<void> _onLoadMyServices(
    LoadMyServices event,
    Emitter<MyServicesState> emit,
  ) async {
    emit(MyServicesLoading());

    final result = await getMyServicesUseCase(event.providerId);

    result.fold(
      (failure) => emit(MyServicesError(failure.message ?? 'Error desconocido')),
      (services) => emit(MyServicesLoaded(services)),
    );
  }

  Future<void> _onRefreshMyServices(
    RefreshMyServices event,
    Emitter<MyServicesState> emit,
  ) async {
    final result = await getMyServicesUseCase(event.providerId);

    result.fold(
      (failure) => emit(MyServicesError(failure.message ?? 'Error desconocido')),
      (services) => emit(MyServicesLoaded(services)),
    );
  }

  Future<void> _onDeleteService(
    DeleteServiceEvent event,
    Emitter<MyServicesState> emit,
  ) async {
    emit(ServiceDeleting(event.serviceId));

    final result = await deleteServiceUseCase(event.serviceId);

    result.fold(
      (failure) => emit(MyServicesError(failure.message ?? 'Error desconocido')),
      (_) => emit(ServiceDeleted(event.serviceId)),
    );
  }
}
