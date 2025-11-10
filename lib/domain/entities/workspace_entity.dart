import 'package:equatable/equatable.dart';

/// Workspace entity representing a team workspace
class WorkspaceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final WorkspaceType type;
  final String ownerId;
  final List<WorkspaceMember> members;
  final WorkspaceSettings settings;
  final WorkspaceSubscription subscription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isDeleted;

  const WorkspaceEntity({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color = '#2196F3',
    required this.type,
    required this.ownerId,
    this.members = const [],
    required this.settings,
    required this.subscription,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isDeleted = false,
  });

  /// Get member count
  int get memberCount => members.length;

  /// Check if user is owner
  bool isOwner(String userId) => ownerId == userId;

  /// Check if user is admin
  bool isAdmin(String userId) {
    final member = members.where((m) => m.userId == userId).firstOrNull;
    return member?.role == WorkspaceRole.admin || isOwner(userId);
  }

  /// Get member by user ID
  WorkspaceMember? getMember(String userId) {
    return members.where((m) => m.userId == userId).firstOrNull;
  }

  /// Copy with method
  WorkspaceEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    WorkspaceType? type,
    String? ownerId,
    List<WorkspaceMember>? members,
    WorkspaceSettings? settings,
    WorkspaceSubscription? subscription,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return WorkspaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      settings: settings ?? this.settings,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        color,
        type,
        ownerId,
        members,
        settings,
        subscription,
        createdAt,
        updatedAt,
        isArchived,
        isDeleted,
      ];
}

/// Workspace types
enum WorkspaceType {
  personal, // Personal workspace (default)
  team, // Team workspace
  family, // Family workspace
  enterprise, // Enterprise workspace
}

/// Workspace member
class WorkspaceMember extends Equatable {
  final String userId;
  final String? email; // For pending invitations
  final WorkspaceRole role;
  final DateTime joinedAt;
  final String invitedBy;
  final bool isActive;
  final bool hasAccepted; // For invitation acceptance

  const WorkspaceMember({
    required this.userId,
    this.email,
    required this.role,
    required this.joinedAt,
    required this.invitedBy,
    this.isActive = true,
    this.hasAccepted = false,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        role,
        joinedAt,
        invitedBy,
        isActive,
        hasAccepted,
      ];
}

/// Workspace roles
enum WorkspaceRole {
  owner, // Full control
  admin, // Can manage members and settings
  member, // Regular member
  guest, // Limited access
}

/// Workspace settings
class WorkspaceSettings extends Equatable {
  final bool allowGuestAccess;
  final bool requireInviteApproval;
  final bool enablePublicSharing;
  final WorkspaceVisibility visibility;
  final Map<String, dynamic>? customSettings;

  const WorkspaceSettings({
    this.allowGuestAccess = false,
    this.requireInviteApproval = true,
    this.enablePublicSharing = false,
    this.visibility = WorkspaceVisibility.private,
    this.customSettings,
  });

  @override
  List<Object?> get props => [
        allowGuestAccess,
        requireInviteApproval,
        enablePublicSharing,
        visibility,
        customSettings,
      ];
}

/// Workspace visibility
enum WorkspaceVisibility {
  private, // Only members can access
  unlisted, // Accessible via link but not discoverable
  public, // Publicly discoverable
}

/// Workspace subscription
class WorkspaceSubscription extends Equatable {
  final WorkspaceSubscriptionTier tier;
  final DateTime? expiresAt;
  final bool isActive;
  final int maxMembers;
  final Map<String, dynamic>? features;

  const WorkspaceSubscription({
    required this.tier,
    this.expiresAt,
    this.isActive = true,
    this.maxMembers = 10,
    this.features,
  });

  @override
  List<Object?> get props => [
        tier,
        expiresAt,
        isActive,
        maxMembers,
        features,
      ];
}

/// Workspace subscription tiers
enum WorkspaceSubscriptionTier {
  free,
  teams,
  enterprise,
}
