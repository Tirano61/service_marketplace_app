import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    super.serviceCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['_id'] ?? json['value'] ?? '',
      name: json['name'] ?? json['label'] ?? '',
      icon: json['icon'] ?? _getIconForCategory(json['value'] ?? json['id'] ?? ''),
      serviceCount: json['service_count'] ?? json['serviceCount'] ?? 0,
    );
  }

  // Método auxiliar para asignar iconos según la categoría
  static String _getIconForCategory(String categoryValue) {
    const Map<String, String> categoryIcons = {
      'WATER_PLUMBING': '🚰',
      'GAS_PLUMBING': '🔥',
      'ELECTRICAL': '⚡',
      'CLEANING': '🧹',
      'PAINTING': '🎨',
      'CARPENTRY': '🔨',
      'GARDENING': '🌿',
      'APPLIANCE_REPAIR': '🔧',
      'LOCKSMITH': '🔑',
      'MOVING': '📦',
      'AC_HEATING': '❄️',
      'MASONRY': '🧱',
      'GLASS': '🪟',
      'PEST_CONTROL': '🐛',
      'OTHER': '🔧',
    };
    return categoryIcons[categoryValue] ?? '🔧';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'service_count': serviceCount,
    };
  }

  Category toEntity() => this;
}
