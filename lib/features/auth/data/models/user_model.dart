import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.role,
    super.photoUrl,
    super.location,
    super.rating,
    super.completedJobs,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: _roleFromString(json['role'] as String),
      photoUrl: json['photo_url'] as String?,
      location: json['location'] != null
          ? UserLocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      completedJobs: json['completed_jobs'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': _roleToString(role),
      'photo_url': photoUrl,
      'location': location != null ? (location as UserLocationModel).toJson() : null,
      'rating': rating,
      'completed_jobs': completedJobs,
    };
  }

  static UserRole _roleFromString(String role) {
    return role == 'provider' ? UserRole.provider : UserRole.client;
  }

  static String _roleToString(UserRole role) {
    return role == UserRole.provider ? 'provider' : 'client';
  }
}

class UserLocationModel extends UserLocation {
  const UserLocationModel({
    required super.latitude,
    required super.longitude,
    super.address,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
