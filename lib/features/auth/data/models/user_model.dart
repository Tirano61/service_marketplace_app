import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.role,
    required super.latitude,
    required super.longitude,
    super.photoUrl,
    super.province,
    super.city,
    super.address,
    super.workRadius,
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
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      photoUrl: json['avatar'] as String? ?? json['photoUrl'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      workRadius: json['workRadius'] != null ? _parseDouble(json['workRadius']) : null,
      rating: json['rating'] != null ? _parseDouble(json['rating']) : null,
      completedJobs: json['completedJobs'] as int? ?? json['totalReviews'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': _roleToString(role),
      'latitude': latitude,
      'longitude': longitude,
      'avatar': photoUrl,
      'province': province,
      'city': city,
      'address': address,
      'workRadius': workRadius,
      'rating': rating,
      'completedJobs': completedJobs,
    };
  }

  static UserRole _roleFromString(String role) {
    return role.toUpperCase() == 'PROVIDER' ? UserRole.provider : UserRole.client;
  }

  static String _roleToString(UserRole role) {
    return role == UserRole.provider ? 'PROVIDER' : 'CLIENT';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
