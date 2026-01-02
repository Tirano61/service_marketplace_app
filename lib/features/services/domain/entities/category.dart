import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int serviceCount;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.serviceCount = 0,
  });

  @override
  List<Object?> get props => [id, name, icon, serviceCount];
}
