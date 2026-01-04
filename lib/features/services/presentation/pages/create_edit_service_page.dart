import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/entities/service.dart';
import '../bloc/service_form_bloc.dart';

class CreateEditServicePage extends StatefulWidget {
  final Service? service;

  const CreateEditServicePage({
    super.key,
    this.service,
  });

  @override
  State<CreateEditServicePage> createState() => _CreateEditServicePageState();
}

class _CreateEditServicePageState extends State<CreateEditServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing && widget.service != null) {
      context.read<ServiceFormBloc>().add(LoadServiceForEdit(widget.service!));
      _titleController.text = widget.service!.title;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.price?.toString() ?? '';
    } else {
      context.read<ServiceFormBloc>().add(LoadCategories());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Servicio' : 'Crear Servicio'),
      ),
      body: BlocConsumer<ServiceFormBloc, ServiceFormState>(
        listener: (context, state) {
          if (state is ServiceFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Servicio actualizado correctamente'
                      : 'Servicio creado correctamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ServiceFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ServiceFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServiceFormError && state is! ServiceFormReady) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ServiceFormBloc>().add(LoadCategories());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is! ServiceFormReady) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título del servicio *',
                        hintText: 'Ej: Reparación de cañerías',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 100,
                      onChanged: (value) {
                        context.read<ServiceFormBloc>().add(TitleChanged(value));
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El título es obligatorio';
                        }
                        if (value.length < 5) {
                          return 'El título debe tener al menos 5 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    DropdownButtonFormField<String>(
                      value: state.categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: state.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text('${category.icon} ${category.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<ServiceFormBloc>()
                              .add(CategoryChanged(value));
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccioná una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        hintText: 'Describí tu servicio en detalle...',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      maxLength: 500,
                      onChanged: (value) {
                        context
                            .read<ServiceFormBloc>()
                            .add(DescriptionChanged(value));
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción es obligatoria';
                        }
                        if (value.length < 20) {
                          return 'La descripción debe tener al menos 20 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de precio
                    DropdownButtonFormField<String>(
                      value: state.priceType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de precio',
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'negotiable',
                          child: Text('A convenir'),
                        ),
                        DropdownMenuItem(
                          value: 'fixed',
                          child: Text('Precio fijo'),
                        ),
                        DropdownMenuItem(
                          value: 'hourly',
                          child: Text('Por hora'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<ServiceFormBloc>()
                              .add(PriceTypeChanged(value));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Precio (si no es "a convenir")
                    if (state.priceType != 'negotiable')
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: state.priceType == 'hourly'
                              ? 'Precio por hora'
                              : 'Precio',
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        onChanged: (value) {
                          context.read<ServiceFormBloc>().add(PriceChanged(value));
                        },
                      ),
                    if (state.priceType != 'negotiable') const SizedBox(height: 16),

                    // Radio de cobertura
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Radio de cobertura: ${state.coverageRadiusKm.toStringAsFixed(0)} km',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          value: state.coverageRadiusKm,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label: '${state.coverageRadiusKm.toStringAsFixed(0)} km',
                          onChanged: (value) {
                            context
                                .read<ServiceFormBloc>()
                                .add(CoverageRadiusChanged(value));
                          },
                        ),
                        Text(
                          'Distancia máxima que estás dispuesto a viajar',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Imágenes
                    Text(
                      'Imágenes del servicio *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agregá hasta 5 fotos que muestren tu trabajo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Grid de imágenes
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...state.images.map((imagePath) {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildImageWidget(imagePath),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    context
                                        .read<ServiceFormBloc>()
                                        .add(ImageRemoved(imagePath));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        
                        // Botón para agregar imagen
                        if (state.images.length < 5)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 32, color: Colors.grey[600]),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Agregar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    if (state.images.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Agregá al menos una imagen',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Botón de guardar
                    ElevatedButton(
                      onPressed: state.isValid
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<ServiceFormBloc>()
                                    .add(SubmitForm());
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: Text(_isEditing ? 'Guardar Cambios' : 'Publicar Servicio'),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
              
              // Loading overlay
              if (state is ServiceFormSubmitting)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            if ((state as ServiceFormSubmitting).totalImages != null && 
                                (state as ServiceFormSubmitting).uploadingImageIndex != null)
                              Text(
                                'Subiendo imagen ${(state as ServiceFormSubmitting).uploadingImageIndex! + 1} de ${(state as ServiceFormSubmitting).totalImages}...',
                              )
                            else
                              const Text('Guardando...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    // Si es una URL (servicio existente)
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      );
    }
    
    // Si es un archivo local (nueva imagen)
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        context.read<ServiceFormBloc>().add(ImageAdded(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
