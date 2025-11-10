import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/list_entity.dart';

part 'list_model.freezed.dart';
part 'list_model.g.dart';

/// List data model for Firestore serialization
@freezed
class ListModel with _$ListModel {
  const factory ListModel({
    required String id,
    required String userId,
    String? workspaceId,
    String? parentListId,
    required String name,
    String? description,
    @Default('personal') String type,
    String? icon,
    @Default('#2196F3') String color,
    @Default('list') String defaultViewType,
    @Default('manual') String defaultSortType,
    @Default(true) bool sortAscending,
    @Default(0) int sortOrder,
    @Default(false) bool isArchived,
    @Default(false) bool isDeleted,
    @Default(false) bool isFavorite,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
    String? lastModifiedBy,
    Map<String, dynamic>? settings,
    ListShareSettingsModel? shareSettings,
  }) = _ListModel;

  const ListModel._();

  factory ListModel.fromJson(Map<String, dynamic> json) =>
      _$ListModelFromJson(json);

  ListEntity toEntity() {
    return ListEntity(
      id: id,
      userId: userId,
      workspaceId: workspaceId,
      parentListId: parentListId,
      name: name,
      description: description,
      type: _typeFromString(type),
      icon: icon,
      color: color,
      defaultViewType: _viewTypeFromString(defaultViewType),
      defaultSortType: _sortTypeFromString(defaultSortType),
      sortAscending: sortAscending,
      sortOrder: sortOrder,
      isArchived: isArchived,
      isDeleted: isDeleted,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      lastModifiedBy: lastModifiedBy,
      settings: settings,
      shareSettings: shareSettings?.toEntity(),
    );
  }

  factory ListModel.fromEntity(ListEntity entity) {
    return ListModel(
      id: entity.id,
      userId: entity.userId,
      workspaceId: entity.workspaceId,
      parentListId: entity.parentListId,
      name: entity.name,
      description: entity.description,
      type: _typeToString(entity.type),
      icon: entity.icon,
      color: entity.color,
      defaultViewType: _viewTypeToString(entity.defaultViewType),
      defaultSortType: _sortTypeToString(entity.defaultSortType),
      sortAscending: entity.sortAscending,
      sortOrder: entity.sortOrder,
      isArchived: entity.isArchived,
      isDeleted: entity.isDeleted,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      lastModifiedBy: entity.lastModifiedBy,
      settings: entity.settings,
      shareSettings: entity.shareSettings != null
          ? ListShareSettingsModel.fromEntity(entity.shareSettings!)
          : null,
    );
  }

  static String _typeToString(ListType type) {
    return type.toString().split('.').last;
  }

  static ListType _typeFromString(String type) {
    switch (type) {
      case 'personal':
        return ListType.personal;
      case 'shared':
        return ListType.shared;
      case 'smart':
        return ListType.smart;
      case 'template':
        return ListType.template;
      default:
        return ListType.personal;
    }
  }

  static String _viewTypeToString(ListViewType type) {
    return type.toString().split('.').last;
  }

  static ListViewType _viewTypeFromString(String type) {
    switch (type) {
      case 'list':
        return ListViewType.list;
      case 'compact':
        return ListViewType.compact;
      case 'detailed':
        return ListViewType.detailed;
      case 'grouped':
        return ListViewType.grouped;
      default:
        return ListViewType.list;
    }
  }

  static String _sortTypeToString(ListSortType type) {
    return type.toString().split('.').last;
  }

  static ListSortType _sortTypeFromString(String type) {
    switch (type) {
      case 'manual':
        return ListSortType.manual;
      case 'dueDate':
        return ListSortType.dueDate;
      case 'priority':
        return ListSortType.priority;
      case 'name':
        return ListSortType.name;
      case 'createdDate':
        return ListSortType.createdDate;
      case 'completedDate':
        return ListSortType.completedDate;
      case 'custom':
        return ListSortType.custom;
      default:
        return ListSortType.manual;
    }
  }
}

/// List share settings model
@freezed
class ListShareSettingsModel with _$ListShareSettingsModel {
  const factory ListShareSettingsModel({
    @Default(false) bool isPublic,
    String? shareLink,
    DateTime? shareLinkExpiresAt,
    @Default([]) List<ListCollaboratorModel> collaborators,
    @Default(false) bool allowGuests,
    @Default('view') String defaultPermission,
  }) = _ListShareSettingsModel;

  const ListShareSettingsModel._();

  factory ListShareSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$ListShareSettingsModelFromJson(json);

  ListShareSettings toEntity() {
    return ListShareSettings(
      isPublic: isPublic,
      shareLink: shareLink,
      shareLinkExpiresAt: shareLinkExpiresAt,
      collaborators: collaborators.map((c) => c.toEntity()).toList(),
      allowGuests: allowGuests,
      defaultPermission: _permissionFromString(defaultPermission),
    );
  }

  factory ListShareSettingsModel.fromEntity(ListShareSettings entity) {
    return ListShareSettingsModel(
      isPublic: entity.isPublic,
      shareLink: entity.shareLink,
      shareLinkExpiresAt: entity.shareLinkExpiresAt,
      collaborators:
          entity.collaborators.map((c) => ListCollaboratorModel.fromEntity(c)).toList(),
      allowGuests: entity.allowGuests,
      defaultPermission: _permissionToString(entity.defaultPermission),
    );
  }

  static String _permissionToString(ListPermission permission) {
    return permission.toString().split('.').last;
  }

  static ListPermission _permissionFromString(String permission) {
    switch (permission) {
      case 'view':
        return ListPermission.view;
      case 'comment':
        return ListPermission.comment;
      case 'edit':
        return ListPermission.edit;
      case 'admin':
        return ListPermission.admin;
      default:
        return ListPermission.view;
    }
  }
}

/// List collaborator model
@freezed
class ListCollaboratorModel with _$ListCollaboratorModel {
  const factory ListCollaboratorModel({
    required String userId,
    String? email,
    required String permission,
    required DateTime addedAt,
    required String addedBy,
    @Default(false) bool isAccepted,
  }) = _ListCollaboratorModel;

  const ListCollaboratorModel._();

  factory ListCollaboratorModel.fromJson(Map<String, dynamic> json) =>
      _$ListCollaboratorModelFromJson(json);

  ListCollaborator toEntity() {
    return ListCollaborator(
      userId: userId,
      email: email,
      permission: _permissionFromString(permission),
      addedAt: addedAt,
      addedBy: addedBy,
      isAccepted: isAccepted,
    );
  }

  factory ListCollaboratorModel.fromEntity(ListCollaborator entity) {
    return ListCollaboratorModel(
      userId: entity.userId,
      email: entity.email,
      permission: _permissionToString(entity.permission),
      addedAt: entity.addedAt,
      addedBy: entity.addedBy,
      isAccepted: entity.isAccepted,
    );
  }

  static String _permissionToString(ListPermission permission) {
    return permission.toString().split('.').last;
  }

  static ListPermission _permissionFromString(String permission) {
    switch (permission) {
      case 'view':
        return ListPermission.view;
      case 'comment':
        return ListPermission.comment;
      case 'edit':
        return ListPermission.edit;
      case 'admin':
        return ListPermission.admin;
      default:
        return ListPermission.view;
    }
  }
}
