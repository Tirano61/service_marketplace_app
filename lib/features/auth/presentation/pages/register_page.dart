import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

import 'package:service_marketplace_app/core/constants/app_colors.dart';
import 'package:service_marketplace_app/core/constants/app_routes.dart';
import 'package:service_marketplace_app/core/theme/text_styles.dart';
import 'package:service_marketplace_app/core/utils/location_helper.dart';
import 'package:service_marketplace_app/core/utils/validators.dart';
import 'package:service_marketplace_app/features/auth/domain/entities/user.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:service_marketplace_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:service_marketplace_app/features/auth/presentation/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late PageController _pageController;
  int _currentStep = 0;

  // Step 1: Credentials
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Personal info
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 3: Role
  UserRole _selectedRole = UserRole.client;

  // Step 4: Location
  double? _latitude;
  double? _longitude;
  String? _locationError;

  // Step 5: Address & Coverage
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _workRadiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _workRadiusController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _locationError = null);
      
      final position = await LocationHelper.getCurrentPosition();
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Try to get address from coordinates
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _provinceController.text = place.administrativeArea ?? '';
            _cityController.text = place.locality ?? '';
            _addressController.text = 
                '${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}'.trim();
          });
        }
      } catch (e) {
        // Location retrieved but address lookup failed
        debugPrint('Address lookup failed: $e');
      }
    } catch (e) {
      final errorMessage = e.toString().contains('Location permission denied')
          ? 'Permiso de ubicación denegado. Por favor, habilita los permisos en la configuración de la aplicación.'
          : 'Error al obtener ubicación: ${e.toString()}';
      setState(() => _locationError = errorMessage);
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Validate email and password
        if (!Validators.isValidEmail(_emailController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email inválido')),
          );
          return false;
        }
        if (_passwordController.text.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
          );
          return false;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Las contraseñas no coinciden')),
          );
          return false;
        }
        return true;
      case 1:
        // Validate name and phone
        if (!Validators.isNotEmpty(_nameController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El nombre es requerido')),
          );
          return false;
        }
        if (!Validators.isNotEmpty(_phoneController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El teléfono es requerido')),
          );
          return false;
        }
        return true;
      case 2:
        // Role validation (always valid)
        return true;
      case 3:
        // Validate location
        if (_latitude == null || _longitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes obtener tu ubicación')),
          );
          return false;
        }
        return true;
      case 4:
        // Validate address and coverage
        if (!Validators.isNotEmpty(_provinceController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La provincia es requerida')),
          );
          return false;
        }
        if (!Validators.isNotEmpty(_cityController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La ciudad es requerida')),
          );
          return false;
        }
        if (!Validators.isNotEmpty(_addressController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La dirección es requerida')),
          );
          return false;
        }
        if (_selectedRole == UserRole.provider) {
          if (!Validators.isNotEmpty(_workRadiusController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El radio de cobertura es requerido')),
            );
            return false;
          }
          try {
            double.parse(_workRadiusController.text);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El radio de cobertura debe ser un número')),
            );
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  void _submitRegistration() {
    if (!_validateCurrentStep()) return;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        role: _selectedRole == UserRole.provider ? UserRole.provider : UserRole.client,
        latitude: _latitude!,
        longitude: _longitude!,
        province: _provinceController.text,
        city: _cityController.text,
        address: _addressController.text,
        workRadius: _selectedRole == UserRole.provider
            ? double.parse(_workRadiusController.text)
            : 0.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error en registro'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Paso ${_currentStep + 1} de 5'),
          elevation: 0,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildStep1(), // Credentials
                _buildStep2(), // Personal info
                _buildStep3(), // Role selection
                _buildStep4(), // Location
                _buildStep5(), // Address & Coverage
              ],
            );
          },
        ),
        bottomNavigationBar: _buildNavigationButtons(context),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crear cuenta', style: TextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Introduce tu email y crea una contraseña segura',
            style: TextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Contraseña',
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirmar contraseña',
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información personal', style: TextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Ayúdanos a conocerte mejor',
            style: TextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _nameController,
            label: 'Nombre completo',
            prefixIcon: Icons.person_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Teléfono',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo de cuenta', style: TextStyles.h3),
          const SizedBox(height: 8),
          Text(
            '¿Qué tipo de usuario eres?',
            style: TextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildRoleCard(
            role: UserRole.client,
            title: 'Cliente',
            description: 'Busco servicios para contratar',
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: UserRole.provider,
            title: 'Proveedor de servicios',
            description: 'Ofrezco mis servicios a clientes',
            icon: Icons.business_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyles.body1),
                  Text(
                    description,
                    style: TextStyles.body2.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu ubicación', style: TextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Necesitamos saber dónde te encuentras',
            style: TextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          if (_latitude != null && _longitude != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.success),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ubicación obtenida', style: TextStyles.body2),
                        Text(
                          'Lat: ${_latitude?.toStringAsFixed(4)}, Lon: ${_longitude?.toStringAsFixed(4)}',
                          style: TextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber),
                  const SizedBox(width: 12),
                  Text(
                    'Ubicación no obtenida',
                    style: TextStyles.body2.copyWith(color: Colors.amber[900]),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          if (_locationError != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.danger),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationError!,
                    style: TextStyles.body2.copyWith(color: AppColors.danger),
                  ),
                  if (_locationError!.contains('Permiso'))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: Geolocator.openLocationSettings,
                          child: const Text('Abrir configuración de permisos'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Obtener mi ubicación'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información de dirección', style: TextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Completa los detalles de tu ubicación',
            style: TextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _provinceController,
            label: 'Provincia',
            prefixIcon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cityController,
            label: 'Ciudad',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _addressController,
            label: 'Dirección',
            prefixIcon: Icons.home_outlined,
          ),
          if (_selectedRole == UserRole.provider) ...[
            const SizedBox(height: 16),
            CustomTextField(
              controller: _workRadiusController,
              label: 'Radio de cobertura (km)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.radio_button_checked,
            ),
            const SizedBox(height: 12),
            Text(
              'Indica el radio en kilómetros dentro del cual estás dispuesto a prestar servicios',
              style: TextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Atrás'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.status == AuthStatus.loading ? null : () {
                    if (_currentStep < 4) {
                      _nextStep();
                    } else {
                      _submitRegistration();
                    }
                  },
                  child: state.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_currentStep == 4 ? 'Registrarse' : 'Siguiente'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
