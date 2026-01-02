import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:service_marketplace_app/core/constants/app_routes.dart';
import 'package:service_marketplace_app/core/theme/text_styles.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:service_marketplace_app/features/auth/domain/entities/user.dart';
import 'package:service_marketplace_app/features/services/presentation/pages/my_services_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          final isProvider = user?.role == UserRole.provider;

          return Scaffold(
            appBar: AppBar(
              title: Text(isProvider ? 'Proveedor' : 'Service Marketplace'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Navegar a notificaciones
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificaciones - Próximamente')),
                    );
                  },
                ),
              ],
            ),
            body: _getBody(isProvider),
            bottomNavigationBar: _buildBottomNavigationBar(isProvider),
          );
        },
      ),
    );
  }

  Widget _getBody(bool isProvider) {
    if (isProvider) {
      // Navegación para PROVEEDORES
      switch (_currentIndex) {
        case 0:
          return const MyServicesPage();
        case 1:
          return _ProviderRequestsTab();
        case 2:
          return _ProviderAgendaTab();
        case 3:
          return _ChatTab();
        case 4:
          return _ProfileTab();
        default:
          return const MyServicesPage();
      }
    } else {
      // Navegación para CLIENTES
      switch (_currentIndex) {
        case 0:
          return _ExploreServicesTab();
        case 1:
          return _MyAppointmentsTab();
        case 2:
          return _ChatTab();
        case 3:
          return _ProfileTab();
        default:
          return _ExploreServicesTab();
      }
    }
  }

  Widget _buildBottomNavigationBar(bool isProvider) {
    if (isProvider) {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Mis Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      );
    } else {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Mis Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      );
    }
  }
}

// ==================== TABS PARA PROVEEDORES ====================

// Tab 1 PROVEEDOR: Mis Servicios (servicios publicados)
// IMPLEMENTADO: Ver lib/features/services/presentation/pages/my_services_page.dart

/// Tab 2 PROVEEDOR: Solicitudes (appointments pendientes)
class _ProviderRequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Solicitudes',
            style: TextStyles.h3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aquí verás las solicitudes de servicio pendientes',
              style: TextStyles.body2.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 3 PROVEEDOR: Agenda (appointments aceptados)
class _ProviderAgendaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Agenda',
            style: TextStyles.h3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Gestiona tus citas y trabajos programados',
              style: TextStyles.body2.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TABS PARA CLIENTES ====================

/// Tab 1 CLIENTE: Explorar (buscar servicios)
class _ExploreServicesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar servicios...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtros - Próximamente')),
                  );
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Explorar Servicios',
                  style: TextStyles.h3,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Encuentra proveedores de servicios cerca de ti',
                    style: TextStyles.body2.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tab 2 CLIENTE: Mis Citas (appointments)
class _MyAppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Mis Citas',
            style: TextStyles.h3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Gestiona tus servicios solicitados y reservas',
              style: TextStyles.body2.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TABS COMUNES ====================

/// Tab COMÚN: Chat
class _ChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Mensajes',
            style: TextStyles.h3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Comunícate con tus clientes o proveedores',
              style: TextStyles.body2.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab COMÚN: Perfil
class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar con círculo
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text(
                        _getInitials(user?.name),
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                user?.name ?? 'Usuario',
                style: TextStyles.h2,
              ),
              const SizedBox(height: 8),

              Text(
                _getRoleDisplayName(user?.role),
                style: TextStyles.body1.copyWith(color: Colors.grey[600]),
              ),

              if (user?.role == UserRole.provider && user?.rating != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        user!.rating!.toStringAsFixed(1),
                        style: TextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.completedJobs != null)
                        Text(
                          ' (${user.completedJobs} trabajos)',
                          style: TextStyles.body2.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Información personal
              _buildSectionCard(
                title: 'Información Personal',
                children: [
                  _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
                  _buildInfoRow(Icons.phone_outlined, 'Teléfono', user?.phone ?? '-'),
                  _buildInfoRow(
                    Icons.location_city_outlined,
                    'Ubicación',
                    '${user?.city ?? ''}, ${user?.province ?? ''}',
                  ),
                  if (user?.address != null && user!.address!.isNotEmpty)
                    _buildInfoRow(Icons.home_outlined, 'Dirección', user.address!),
                ],
              ),

              // Información de servicio (solo para proveedores)
              if (user?.role == UserRole.provider) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Información de Servicio',
                  children: [
                    if (user?.workRadius != null && user!.workRadius! > 0)
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Radio de cobertura',
                        '${user.workRadius} km',
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Opciones del perfil
              _buildMenuOption(
                icon: Icons.edit_outlined,
                title: 'Editar perfil',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editar perfil - Próximamente')),
                  );
                },
              ),

              _buildMenuOption(
                icon: Icons.lock_outline,
                title: 'Cambiar contraseña',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cambiar contraseña - Próximamente')),
                  );
                },
              ),

              _buildMenuOption(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuración - Próximamente')),
                  );
                },
              ),

              _buildMenuOption(
                icon: Icons.help_outline,
                title: 'Ayuda y soporte',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ayuda - Próximamente')),
                  );
                },
              ),

              _buildMenuOption(
                icon: Icons.description_outlined,
                title: 'Términos y condiciones',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Términos - Próximamente')),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Botón de cerrar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyles.h4),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.body2.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getRoleDisplayName(UserRole? role) {
    if (role == UserRole.provider) return 'Proveedor de servicios';
    if (role == UserRole.client) return 'Cliente';
    return 'Usuario';
  }
}
