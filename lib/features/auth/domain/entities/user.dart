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

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? province,
    String? city,
    String? address,
    double? workRadius,
    double? rating,
    int? completedJobs,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      province: province ?? this.province,
      city: city ?? this.city,
      address: address ?? this.address,
      workRadius: workRadius ?? this.workRadius,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
    );
  }

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
