import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
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

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      } else {
        throw ServerException('Login failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': role,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      } else {
        throw ServerException('Registration failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw ServerException(e.message);
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
      throw ServerException(e.message);
    }
  }
}
