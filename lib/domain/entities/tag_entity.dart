import 'package:equatable/equatable.dart';

/// Tag entity representing a tag in the domain layer
class TagEntity extends Equatable {
  final String id;
  final String userId;
  final String? workspaceId;
  final String name;
  final String? description;
  final String color; // Hex color code
  final String? icon;
  final String? parentTagId; // For nested/hierarchical tags
  final int sortOrder;
  final int usageCount; // Number of tasks with this tag
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const TagEntity({
    required this.id,
    required this.userId,
    this.workspaceId,
    required this.name,
    this.description,
    this.color = '#9E9E9E',
    this.icon,
    this.parentTagId,
    this.sortOrder = 0,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Check if tag is nested (has parent)
  bool get isNested => parentTagId != null;

  /// Copy with method
  TagEntity copyWith({
    String? id,
    String? userId,
    String? workspaceId,
    String? name,
    String? description,
    String? color,
    String? icon,
    String? parentTagId,
    int? sortOrder,
    int? usageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return TagEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      parentTagId: parentTagId ?? this.parentTagId,
      sortOrder: sortOrder ?? this.sortOrder,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        workspaceId,
        name,
        description,
        color,
        icon,
        parentTagId,
        sortOrder,
        usageCount,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}
