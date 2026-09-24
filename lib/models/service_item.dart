import '../core/utils/date_formatter.dart';

class ServiceItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isActive;
  final DateTime? createdAt;

  ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isActive = true,
    this.createdAt,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'build',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateFormatter.parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
