import 'package:equatable/equatable.dart';

enum UserRole { client, provider }

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.province,
    this.city,
    this.address,
    this.workRadius, // Solo para proveedores
    this.rating,
    this.completedJobs,
  });

  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String? province;
  final String? city;
  final String? address;
  final double? workRadius; // Para proveedores
  final double? rating;
  final int? completedJobs;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        role,
        latitude,
        longitude,
        photoUrl,
        province,
        city,
        address,
        workRadius,
        rating,
        completedJobs,
      ];
}
