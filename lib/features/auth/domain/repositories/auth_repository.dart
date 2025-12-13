import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
    UserLocation? location,
  });
}
