import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al iniciar sesión'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final roleString = role == UserRole.provider ? 'provider' : 'client';
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: roleString,
      );
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al registrarse'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      if (user != null) {
        await _localDataSource.cacheUser(user);
      }
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener usuario actual'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
    UserLocation? location,
  }) async {
    // TODO: Implement when backend endpoint is ready
    return Left(ServerFailure('No implementado aún'));
  }
}
