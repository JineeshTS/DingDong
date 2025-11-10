import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tag_entity.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

/// Tag data model for Firestore serialization
@freezed
class TagModel with _$TagModel {
  const factory TagModel({
    required String id,
    required String userId,
    String? workspaceId,
    required String name,
    String? description,
    @Default('#9E9E9E') String color,
    String? icon,
    String? parentTagId,
    @Default(0) int sortOrder,
    @Default(0) int usageCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _TagModel;

  const TagModel._();

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      userId: userId,
      workspaceId: workspaceId,
      name: name,
      description: description,
      color: color,
      icon: icon,
      parentTagId: parentTagId,
      sortOrder: sortOrder,
      usageCount: usageCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id,
      userId: entity.userId,
      workspaceId: entity.workspaceId,
      name: entity.name,
      description: entity.description,
      color: entity.color,
      icon: entity.icon,
      parentTagId: entity.parentTagId,
      sortOrder: entity.sortOrder,
      usageCount: entity.usageCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
    );
  }
}
