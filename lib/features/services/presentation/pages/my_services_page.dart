import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/my_services_bloc.dart';
import '../widgets/service_card.dart';
import 'create_edit_service_page.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    // TODO: Obtener el ID del proveedor actual del AuthBloc
    context.read<MyServicesBloc>().add(const LoadMyServices('current_user_id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServices,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: BlocConsumer<MyServicesBloc, MyServicesState>(
        listener: (context, state) {
          if (state is MyServicesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ServiceDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Servicio eliminado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar servicios
            _loadServices();
          }
        },
        builder: (context, state) {
          if (state is MyServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyServicesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar servicios',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadServices,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Intentar nuevamente'),
                  ),
                ],
              ),
            );
          }

          if (state is MyServicesLoaded) {
            if (state.services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tenés servicios publicados',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Publicá tu primer servicio para empezar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateService(),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Servicio'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<MyServicesBloc>()
                    .add(const RefreshMyServices('current_user_id'));
                // Esperar un poco para que complete
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: state.services.length,
                itemBuilder: (context, index) {
                  final service = state.services[index];
                  return ServiceCard(
                    service: service,
                    showActions: true,
                    onTap: () {
                      // TODO: Navegar a detalle del servicio
                    },
                    onEdit: () => _navigateToEditService(service),
                    onDelete: () => _showDeleteDialog(service.id),
                    onToggleStatus: () {
                      // TODO: Implementar toggle de estado
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función disponible próximamente'),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<MyServicesBloc, MyServicesState>(
        builder: (context, state) {
          if (state is MyServicesLoaded && state.services.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _navigateToCreateService(),
              icon: const Icon(Icons.add),
              label: const Text('Crear Servicio'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _navigateToCreateService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEditServicePage(),
      ),
    );

    if (result == true && mounted) {
      _loadServices();
    }
  }

  Future<void> _navigateToEditService(service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditServicePage(service: service),
      ),
    );

    if (result == true && mounted) {
      _loadServices();
    }
  }

  Future<void> _showDeleteDialog(String serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: const Text(
          '¿Estás seguro de que querés eliminar este servicio?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<MyServicesBloc>().add(DeleteServiceEvent(serviceId));
    }
  }
}
