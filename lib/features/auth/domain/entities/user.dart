import 'package:equatable/equatable.dart';

enum UserRole { client, provider }

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.location,
    this.rating,
    this.completedJobs,
  });

  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final UserLocation? location;
  final double? rating; // Para proveedores
  final int? completedJobs; // Para proveedores

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        role,
        photoUrl,
        location,
        rating,
        completedJobs,
      ];
}

class UserLocation extends Equatable {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  @override
  List<Object?> get props => [latitude, longitude, address];
}
