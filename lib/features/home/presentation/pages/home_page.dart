import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:service_marketplace_app/core/constants/app_routes.dart';
import 'package:service_marketplace_app/core/theme/text_styles.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Service Marketplace'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido, ${user?.name}!',
                    style: TextStyles.h2,
                  ),
                  const SizedBox(height: 24),
                  
                  // User info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Información de perfil', style: TextStyles.h4),
                          const SizedBox(height: 16),
                          _buildInfoRow('Email', user?.email ?? '-'),
                          _buildInfoRow('Teléfono', user?.phone ?? '-'),
                          _buildInfoRow('Rol', _getRoleDisplayName(user?.role.toString() ?? '')),
                          _buildInfoRow('Ciudad', user?.city ?? '-'),
                          _buildInfoRow('Provincia', user?.province ?? '-'),
                          if (user?.workRadius != null && user!.workRadius! > 0)
                            _buildInfoRow('Radio de cobertura', '${user.workRadius} km'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Location info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ubicación', style: TextStyles.h4),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Latitud',
                            user?.latitude.toStringAsFixed(4) ?? '-',
                          ),
                          _buildInfoRow(
                            'Longitud',
                            user?.longitude.toStringAsFixed(4) ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Features placeholder
                  Text('Próximas características', style: TextStyles.h4),
                  const SizedBox(height: 12),
                  
                  if (user?.role.toString().contains('CLIENT') ?? false)
                    _buildFeatureItem(
                      'Explorar servicios',
                      'Encuentra proveedores cerca de ti',
                      Icons.search,
                    ),
                  
                  if (user?.role.toString().contains('PROVIDER') ?? false)
                    _buildFeatureItem(
                      'Gestionar servicios',
                      'Administra tus servicios ofrecidos',
                      Icons.business,
                    ),
                  
                  _buildFeatureItem(
                    'Citas y reservas',
                    'Gestiona tus reservas',
                    Icons.calendar_today,
                  ),
                  
                  _buildFeatureItem(
                    'Mensajería',
                    'Comunícate con otros usuarios',
                    Icons.chat,
                  ),
                  
                  _buildFeatureItem(
                    'Reseñas',
                    'Lee y deja reseñas',
                    Icons.star,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyles.body2.copyWith(color: Colors.grey[600])),
          Text(value, style: TextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    if (role.contains('PROVIDER')) return 'Proveedor de servicios';
    if (role.contains('CLIENT')) return 'Cliente';
    return role;
  }
}
