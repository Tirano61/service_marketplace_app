import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/create_service_usecase.dart';
import '../../domain/usecases/update_service_usecase.dart';

part 'service_form_event.dart';
part 'service_form_state.dart';

class ServiceFormBloc extends Bloc<ServiceFormEvent, ServiceFormState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final CreateServiceUseCase createServiceUseCase;
  final UpdateServiceUseCase updateServiceUseCase;

  ServiceFormBloc({
    required this.getCategoriesUseCase,
    required this.createServiceUseCase,
    required this.updateServiceUseCase,
  }) : super(ServiceFormInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadServiceForEdit>(_onLoadServiceForEdit);
    on<TitleChanged>(_onTitleChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<CategoryChanged>(_onCategoryChanged);
    on<PriceChanged>(_onPriceChanged);
    on<PriceTypeChanged>(_onPriceTypeChanged);
    on<CoverageRadiusChanged>(_onCoverageRadiusChanged);
    on<ImageAdded>(_onImageAdded);
    on<ImageRemoved>(_onImageRemoved);
    on<SubmitForm>(_onSubmitForm);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ServiceFormState> emit,
  ) async {
    print('🔄 ServiceFormBloc: Cargando categorías...');
    emit(ServiceFormLoading());

    final result = await getCategoriesUseCase();

    result.fold(
      (failure) {
        print('❌ ServiceFormBloc: Error al cargar categorías - ${failure.message}');
        emit(ServiceFormError(failure.message ?? 'Error desconocido'));
      },
      (categories) {
        print('✅ ServiceFormBloc: ${categories.length} categorías cargadas');
        emit(ServiceFormReady(categories: categories));
      },
    );
  }

  Future<void> _onLoadServiceForEdit(
    LoadServiceForEdit event,
    Emitter<ServiceFormState> emit,
  ) async {
    emit(ServiceFormLoading());

    final result = await getCategoriesUseCase();

    result.fold(
      (failure) => emit(ServiceFormError(failure.message ?? 'Error desconocido')),
      (categories) => emit(ServiceFormReady(
        categories: categories,
        editingServiceId: event.service.id,
        title: event.service.title,
        description: event.service.description,
        categoryId: event.service.categoryId,
        price: event.service.price?.toString() ?? '',
        priceType: event.service.priceType ?? 'negotiable',
        coverageRadiusKm: event.service.coverageRadiusKm,
        images: event.service.images,
        isValid: true,
      )),
    );
  }

  void _onTitleChanged(TitleChanged event, Emitter<ServiceFormState> emit) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      emit(currentState.copyWith(
        title: event.title,
        isValid: _validateForm(
          title: event.title,
          description: currentState.description,
          categoryId: currentState.categoryId,
          coverageRadiusKm: currentState.coverageRadiusKm,
          images: currentState.images,
        ),
      ));
    }
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<ServiceFormState> emit,
  ) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      emit(currentState.copyWith(
        description: event.description,
        isValid: _validateForm(
          title: currentState.title,
          description: event.description,
          categoryId: currentState.categoryId,
          coverageRadiusKm: currentState.coverageRadiusKm,
          images: currentState.images,
        ),
      ));
    }
  }

  void _onCategoryChanged(
    CategoryChanged event,
    Emitter<ServiceFormState> emit,
  ) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      emit(currentState.copyWith(
        categoryId: event.categoryId,
        isValid: _validateForm(
          title: currentState.title,
          description: currentState.description,
          categoryId: event.categoryId,
          coverageRadiusKm: currentState.coverageRadiusKm,
          images: currentState.images,
        ),
      ));
    }
  }

  void _onPriceChanged(PriceChanged event, Emitter<ServiceFormState> emit) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      emit(currentState.copyWith(price: event.price));
    }
  }

  void _onPriceTypeChanged(
    PriceTypeChanged event,
    Emitter<ServiceFormState> emit,
  ) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      emit(currentState.copyWith(priceType: event.priceType));
    }
  }

  void _onCoverageRadiusChanged(
    CoverageRadiusChanged event,
    Emitter<ServiceFormState> emit,
  ) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      emit(currentState.copyWith(
        coverageRadiusKm: event.radius,
        isValid: _validateForm(
          title: currentState.title,
          description: currentState.description,
          categoryId: currentState.categoryId,
          coverageRadiusKm: event.radius,
          images: currentState.images,
        ),
      ));
    }
  }

  void _onImageAdded(ImageAdded event, Emitter<ServiceFormState> emit) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      final newImages = [...currentState.images, event.imagePath];
      emit(currentState.copyWith(
        images: newImages,
        isValid: _validateForm(
          title: currentState.title,
          description: currentState.description,
          categoryId: currentState.categoryId,
          coverageRadiusKm: currentState.coverageRadiusKm,
          images: newImages,
        ),
      ));
    }
  }

  void _onImageRemoved(ImageRemoved event, Emitter<ServiceFormState> emit) {
    if (state is ServiceFormReady) {
      final currentState = state as ServiceFormReady;
      final newImages = currentState.images
          .where((img) => img != event.imagePath)
          .toList();
      emit(currentState.copyWith(
        images: newImages,
        isValid: _validateForm(
          title: currentState.title,
          description: currentState.description,
          categoryId: currentState.categoryId,
          coverageRadiusKm: currentState.coverageRadiusKm,
          images: newImages,
        ),
      ));
    }
  }

  Future<void> _onSubmitForm(
    SubmitForm event,
    Emitter<ServiceFormState> emit,
  ) async {
    if (state is! ServiceFormReady) return;

    final currentState = state as ServiceFormReady;

    if (!currentState.isValid) {
      emit(const ServiceFormError('Por favor completa todos los campos obligatorios'));
      emit(currentState);
      return;
    }

    emit(ServiceFormSubmitting());

    final double? price = currentState.price.isEmpty
        ? null
        : double.tryParse(currentState.price);

    if (currentState.editingServiceId != null) {
      // Actualizar servicio existente
      final result = await updateServiceUseCase(UpdateServiceParams(
        serviceId: currentState.editingServiceId!,
        title: currentState.title,
        description: currentState.description,
        categoryId: currentState.categoryId!,
        price: price,
        priceType: currentState.priceType,
        coverageRadiusKm: currentState.coverageRadiusKm,
        imagePaths: currentState.images,
      ));

      result.fold(
        (failure) {
          emit(ServiceFormError(failure.message ?? 'Error desconocido'));
          emit(currentState);
        },
        (service) => emit(ServiceFormSuccess(service)),
      );
    } else {
      // Crear nuevo servicio
      final result = await createServiceUseCase(CreateServiceParams(
        title: currentState.title,
        description: currentState.description,
        categoryId: currentState.categoryId!,
        price: price,
        priceType: currentState.priceType,
        coverageRadiusKm: currentState.coverageRadiusKm,
        imagePaths: currentState.images,
      ));

      result.fold(
        (failure) {
          emit(ServiceFormError(failure.message ?? 'Error desconocido'));
          emit(currentState);
        },
        (service) => emit(ServiceFormSuccess(service)),
      );
    }
  }

  bool _validateForm({
    required String title,
    required String description,
    required String? categoryId,
    required double coverageRadiusKm,
    required List<String> images,
  }) {
    return title.isNotEmpty &&
        title.length >= 5 &&
        description.isNotEmpty &&
        description.length >= 20 &&
        categoryId != null &&
        coverageRadiusKm > 0 &&
        images.isNotEmpty;
  }
}
