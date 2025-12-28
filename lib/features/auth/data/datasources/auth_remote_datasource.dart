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
  Future<String> uploadAvatar({required String filePath});
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
      print('Cerrando sesión en el servidor...');
      await _dio.post('/auth/logout');
      print('Sesión cerrada en el servidor exitosamente');
    } on DioException catch (e) {
      print('Error al cerrar sesión en servidor: ${e.response?.statusCode}');
      // Aunque falle el logout en el servidor, permitimos continuar
      // para que se limpie el cache local
      if (e.response?.statusCode == 401) {
        print('Token ya inválido o expirado, continuando con logout local');
      } else {
        print('Error en logout del servidor, pero continuando con logout local');
      }
    } catch (e) {
      print('Error inesperado en logout: $e');
      // Permitimos continuar para limpiar el cache local
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

  @override
  Future<String> uploadAvatar({required String filePath}) async {
    try {
      print('Intentando subir avatar desde: $filePath');
      
      // Crear FormData con el archivo
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      print('Enviando petición a: /auth/avatar');
      final response = await _dio.post(
        '/auth/avatar',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Datos de respuesta completos: ${response.data}');
      print('Tipo de datos: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Intentar obtener la URL del avatar de diferentes formas posibles
        String? avatarUrl;
        
        if (data is Map<String, dynamic>) {
          // Intentar diferentes nombres de campo comunes
          avatarUrl = data['avatarUrl'] as String? ?? 
                     data['avatar'] as String? ?? 
                     data['url'] as String? ?? 
                     data['imageUrl'] as String? ??
                     data['avatarURL'] as String?;
          
          print('Avatar URL encontrada: $avatarUrl');
          
          // Si la respuesta tiene un objeto 'user' con el avatar
          if (avatarUrl == null && data['user'] != null) {
            final user = data['user'] as Map<String, dynamic>;
            avatarUrl = user['avatar'] as String? ?? 
                       user['avatarUrl'] as String? ??
                       user['photoUrl'] as String?;
            print('Avatar URL encontrada en user: $avatarUrl');
          }
        }
        
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          return avatarUrl;
        } else {
          print('ERROR: No se encontró URL del avatar en la respuesta');
          print('Estructura de respuesta: $data');
          throw ServerException(
            'El servidor procesó la imagen pero no devolvió la URL. '
            'Por favor, recarga la aplicación para ver los cambios.'
          );
        }
      } else {
        throw ServerException('Respuesta inesperada del servidor: ${response.statusCode}');
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print('Error DioException: ${e.response?.statusCode}');
      print('Mensaje de error: ${e.response?.data}');
      
      // Manejar diferentes códigos de error con mensajes amigables
      if (e.response?.statusCode == 404) {
        throw ServerException(
          'El servicio de subida de imágenes no está disponible en este momento. '
          'Por favor, contacta al administrador o intenta más tarde.'
        );
      }
      
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data is Map 
            ? (e.response?.data['message'] ?? 'Formato de archivo no válido')
            : 'El archivo seleccionado no es válido';
        throw ServerException(errorMessage);
      }
      
      if (e.response?.statusCode == 401) {
        throw ServerException(
          'Tu sesión ha expirado. Por favor, cierra sesión y vuelve a iniciar.'
        );
      }
      
      if (e.response?.statusCode == 413) {
        throw ServerException(
          'La imagen es demasiado grande. Por favor, selecciona una imagen más pequeña.'
        );
      }
      
      if (e.response?.statusCode == 500) {
        throw ServerException(
          'Error en el servidor. Por favor, intenta nuevamente en unos momentos.'
        );
      }
      
      // Error genérico de red
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          'La conexión está tardando mucho. Verifica tu conexión a internet e intenta nuevamente.'
        );
      }
      
      if (e.type == DioExceptionType.connectionError) {
        throw ServerException(
          'No se pudo conectar con el servidor. Verifica tu conexión a internet.'
        );
      }
      
      // Error desconocido
      throw ServerException(
        'No se pudo subir la imagen. Por favor, verifica tu conexión e intenta nuevamente.'
      );
    } catch (e) {
      print('Error inesperado: $e');
      throw ServerException(
        'Ocurrió un error inesperado al procesar la imagen. Por favor, intenta nuevamente.'
      );
    }
  }
}
