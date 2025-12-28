import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class ApiClient {
  ApiClient({Dio? dio, SharedPreferences? sharedPreferences}) 
      : _dio = dio ?? Dio(_defaultOptions),
        _sharedPreferences = sharedPreferences {
    _setupInterceptors();
  }

  final Dio _dio;
  final SharedPreferences? _sharedPreferences;

  static BaseOptions get _defaultOptions {
    return BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.defaultTimeout,
      receiveTimeout: ApiConstants.defaultTimeout,
      sendTimeout: ApiConstants.defaultTimeout,
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token a todas las peticiones
          if (_sharedPreferences != null) {
            final token = _sharedPreferences.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              print('Token agregado al header: Bearer ${token.substring(0, 20)}...');
            } else {
              print('No hay token guardado');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Guardar token si viene en la respuesta (login/register)
          if (_sharedPreferences != null) {
            final data = response.data;
            if (data is Map<String, dynamic> && data.containsKey('access_token')) {
              final token = data['access_token'] as String;
              _sharedPreferences.setString('auth_token', token);
              print('Token guardado desde respuesta');
            }
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          print('Error en petición: ${error.response?.statusCode}');
          print('URL: ${error.requestOptions.uri}');
          print('Headers: ${error.requestOptions.headers}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get client => _dio;
}
