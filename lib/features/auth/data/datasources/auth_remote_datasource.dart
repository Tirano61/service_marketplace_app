import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required double latitude,
    required double longitude,
    required String province,
    required String city,
    required String address,
    double? workRadius,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Login response status: ${response.statusCode}');
        print('Login response data: ${response.data}');
        
        // Check if response has 'user' field
        if (response.data is Map<String, dynamic> && response.data['user'] != null) {
          return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
        } else {
          throw ServerException('Respuesta del servidor inválida: no contiene datos de usuario');
        }
      } else {
        throw ServerException('Login failed');
      }
    } on ServerException {
      rethrow; // Pass through ServerException
    } on DioException catch (e) {
      print('Login DioException: ${e.response?.statusCode}');
      print('Login error data: ${e.response?.data}');
      
      // Handle specific HTTP error codes
      if (e.response?.statusCode == 401) {
        throw ServerException('Email o contraseña incorrectos. Por favor, verifica tus credenciales.');
      }
      if (e.response?.statusCode == 404) {
        throw ServerException('Este email no está registrado. Por favor, crea una nueva cuenta.');
      }
      throw ServerException(e.message ?? 'Error en login');
    } catch (e) {
      print('Login unexpected error: $e');
      throw ServerException('Error inesperado al procesar el login: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required double latitude,
    required double longitude,
    required String province,
    required String city,
    required String address,
    double? workRadius,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
        'latitude': latitude,
        'longitude': longitude,
        'province': province,
        'city': city,
        'address': address,
      };

      if (workRadius != null) {
        data['workRadius'] = workRadius;
      }

      final response = await _dio.post(
        '/auth/register',
        data: data,
      );

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Check if registration requires email verification (no user object returned)
        if (responseData.containsKey('user')) {
          // User object present - direct registration success
          return UserModel.fromJson(responseData['user'] as Map<String, dynamic>);
        } else {
          // No user object - email verification required
          final emailFromResponse = responseData['email'] as String? ?? email;
          final message = responseData['message'] as String? ?? 'Registro exitoso. Revisa tu email para verificar tu cuenta.';
          throw EmailVerificationPendingException(
            message: message,
            email: emailFromResponse,
          );
        }
      } else {
        throw ServerException('Registration failed');
      }
    } on EmailVerificationPendingException {
      rethrow; // Pass through email verification exception
    } on DioException catch (e) {
      // Handle specific HTTP error codes
      if (e.response?.statusCode == 409) {
        throw ServerException('Este email ya está registrado. Por favor, usa otro email o intenta iniciar sesión.');
      }
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Datos de registro inválidos';
        throw ServerException('Error en registro: $errorMessage');
      }
      throw ServerException(e.message ?? 'Error en registro');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Error en logout');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200 && response.data['user'] != null) {
        return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null; // No authenticated
      }
      throw ServerException(e.message ?? 'Error obteniendo usuario');
    }
  }
}
