import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/workspace_entity.dart';

part 'workspace_model.freezed.dart';
part 'workspace_model.g.dart';

/// Workspace data model for Firestore serialization
@freezed
class WorkspaceModel with _$WorkspaceModel {
  const factory WorkspaceModel({
    required String id,
    required String name,
    String? description,
    String? icon,
    @Default('#2196F3') String? color,
    required String type,
    required String ownerId,
    @Default([]) List<WorkspaceMemberModel> members,
    required WorkspaceSettingsModel settings,
    required WorkspaceSubscriptionModel subscription,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isArchived,
    @Default(false) bool isDeleted,
  }) = _WorkspaceModel;

  const WorkspaceModel._();

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceModelFromJson(json);

  WorkspaceEntity toEntity() {
    return WorkspaceEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
      color: color ?? '#2196F3',
      type: _typeFromString(type),
      ownerId: ownerId,
      members: members.map((m) => m.toEntity()).toList(),
      settings: settings.toEntity(),
      subscription: subscription.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
    );
  }

  factory WorkspaceModel.fromEntity(WorkspaceEntity entity) {
    return WorkspaceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      color: entity.color,
      type: _typeToString(entity.type),
      ownerId: entity.ownerId,
      members: entity.members.map((m) => WorkspaceMemberModel.fromEntity(m)).toList(),
      settings: WorkspaceSettingsModel.fromEntity(entity.settings),
      subscription: WorkspaceSubscriptionModel.fromEntity(entity.subscription),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isArchived: entity.isArchived,
      isDeleted: entity.isDeleted,
    );
  }

  static String _typeToString(WorkspaceType type) {
    return type.toString().split('.').last;
  }

  static WorkspaceType _typeFromString(String type) {
    switch (type) {
      case 'personal':
        return WorkspaceType.personal;
      case 'team':
        return WorkspaceType.team;
      case 'family':
        return WorkspaceType.family;
      case 'enterprise':
        return WorkspaceType.enterprise;
      default:
        return WorkspaceType.personal;
    }
  }
}

/// Workspace member model
@freezed
class WorkspaceMemberModel with _$WorkspaceMemberModel {
  const factory WorkspaceMemberModel({
    required String userId,
    String? email,
    required String role,
    required DateTime joinedAt,
    required String invitedBy,
    @Default(true) bool isActive,
    @Default(false) bool hasAccepted,
  }) = _WorkspaceMemberModel;

  const WorkspaceMemberModel._();

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceMemberModelFromJson(json);

  WorkspaceMember toEntity() {
    return WorkspaceMember(
      userId: userId,
      email: email,
      role: _roleFromString(role),
      joinedAt: joinedAt,
      invitedBy: invitedBy,
      isActive: isActive,
      hasAccepted: hasAccepted,
    );
  }

  factory WorkspaceMemberModel.fromEntity(WorkspaceMember entity) {
    return WorkspaceMemberModel(
      userId: entity.userId,
      email: entity.email,
      role: _roleToString(entity.role),
      joinedAt: entity.joinedAt,
      invitedBy: entity.invitedBy,
      isActive: entity.isActive,
      hasAccepted: entity.hasAccepted,
    );
  }

  static String _roleToString(WorkspaceRole role) {
    return role.toString().split('.').last;
  }

  static WorkspaceRole _roleFromString(String role) {
    switch (role) {
      case 'owner':
        return WorkspaceRole.owner;
      case 'admin':
        return WorkspaceRole.admin;
      case 'member':
        return WorkspaceRole.member;
      case 'guest':
        return WorkspaceRole.guest;
      default:
        return WorkspaceRole.member;
    }
  }
}

/// Workspace settings model
@freezed
class WorkspaceSettingsModel with _$WorkspaceSettingsModel {
  const factory WorkspaceSettingsModel({
    @Default(false) bool allowGuestAccess,
    @Default(true) bool requireInviteApproval,
    @Default(false) bool enablePublicSharing,
    @Default('private') String visibility,
    Map<String, dynamic>? customSettings,
  }) = _WorkspaceSettingsModel;

  const WorkspaceSettingsModel._();

  factory WorkspaceSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceSettingsModelFromJson(json);

  WorkspaceSettings toEntity() {
    return WorkspaceSettings(
      allowGuestAccess: allowGuestAccess,
      requireInviteApproval: requireInviteApproval,
      enablePublicSharing: enablePublicSharing,
      visibility: _visibilityFromString(visibility),
      customSettings: customSettings,
    );
  }

  factory WorkspaceSettingsModel.fromEntity(WorkspaceSettings entity) {
    return WorkspaceSettingsModel(
      allowGuestAccess: entity.allowGuestAccess,
      requireInviteApproval: entity.requireInviteApproval,
      enablePublicSharing: entity.enablePublicSharing,
      visibility: _visibilityToString(entity.visibility),
      customSettings: entity.customSettings,
    );
  }

  static String _visibilityToString(WorkspaceVisibility visibility) {
    return visibility.toString().split('.').last;
  }

  static WorkspaceVisibility _visibilityFromString(String visibility) {
    switch (visibility) {
      case 'private':
        return WorkspaceVisibility.private;
      case 'unlisted':
        return WorkspaceVisibility.unlisted;
      case 'public':
        return WorkspaceVisibility.public;
      default:
        return WorkspaceVisibility.private;
    }
  }
}

/// Workspace subscription model
@freezed
class WorkspaceSubscriptionModel with _$WorkspaceSubscriptionModel {
  const factory WorkspaceSubscriptionModel({
    required String tier,
    DateTime? expiresAt,
    @Default(true) bool isActive,
    @Default(10) int maxMembers,
    Map<String, dynamic>? features,
  }) = _WorkspaceSubscriptionModel;

  const WorkspaceSubscriptionModel._();

  factory WorkspaceSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceSubscriptionModelFromJson(json);

  WorkspaceSubscription toEntity() {
    return WorkspaceSubscription(
      tier: _tierFromString(tier),
      expiresAt: expiresAt,
      isActive: isActive,
      maxMembers: maxMembers,
      features: features,
    );
  }

  factory WorkspaceSubscriptionModel.fromEntity(WorkspaceSubscription entity) {
    return WorkspaceSubscriptionModel(
      tier: _tierToString(entity.tier),
      expiresAt: entity.expiresAt,
      isActive: entity.isActive,
      maxMembers: entity.maxMembers,
      features: entity.features,
    );
  }

  static String _tierToString(WorkspaceSubscriptionTier tier) {
    return tier.toString().split('.').last;
  }

  static WorkspaceSubscriptionTier _tierFromString(String tier) {
    switch (tier) {
      case 'free':
        return WorkspaceSubscriptionTier.free;
      case 'teams':
        return WorkspaceSubscriptionTier.teams;
      case 'enterprise':
        return WorkspaceSubscriptionTier.enterprise;
      default:
        return WorkspaceSubscriptionTier.free;
    }
  }
}
