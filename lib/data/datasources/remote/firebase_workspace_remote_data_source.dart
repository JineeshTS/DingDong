import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/workspace_entity.dart';
import '../../models/workspace_model.dart';

/// Firebase remote data source for workspace operations
abstract class FirebaseWorkspaceRemoteDataSource {
  /// Create a new workspace
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace);

  /// Get workspace by ID
  Future<WorkspaceModel> getWorkspace(String id);

  /// Get all workspaces for user
  Future<List<WorkspaceModel>> getWorkspaces({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get workspaces where user is owner
  Future<List<WorkspaceModel>> getOwnedWorkspaces(String userId);

  /// Get workspaces where user is member
  Future<List<WorkspaceModel>> getMemberWorkspaces(String userId);

  /// Update workspace
  Future<WorkspaceModel> updateWorkspace(WorkspaceModel workspace);

  /// Delete workspace (soft delete)
  Future<void> deleteWorkspace(String id);

  /// Permanently delete workspace
  Future<void> permanentlyDeleteWorkspace(String id);

  /// Restore workspace
  Future<WorkspaceModel> restoreWorkspace(String id);

  /// Archive workspace
  Future<WorkspaceModel> archiveWorkspace(String id);

  /// Unarchive workspace
  Future<WorkspaceModel> unarchiveWorkspace(String id);

  /// Add member to workspace
  Future<WorkspaceModel> addMember({
    required String workspaceId,
    required String userId,
    String? email,
    required String role,
    required String invitedBy,
  });

  /// Remove member from workspace
  Future<WorkspaceModel> removeMember({
    required String workspaceId,
    required String userId,
  });

  /// Update member role
  Future<WorkspaceModel> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  });

  /// Accept workspace invitation
  Future<WorkspaceModel> acceptInvitation(String workspaceId);

  /// Decline workspace invitation
  Future<void> declineInvitation(String workspaceId);

  /// Leave workspace
  Future<void> leaveWorkspace(String workspaceId);

  /// Transfer ownership
  Future<WorkspaceModel> transferOwnership({
    required String workspaceId,
    required String newOwnerId,
  });

  /// Update workspace settings
  Future<WorkspaceModel> updateSettings({
    required String workspaceId,
    required Map<String, dynamic> settings,
  });

  /// Update workspace subscription
  Future<WorkspaceModel> updateSubscription({
    required String workspaceId,
    required Map<String, dynamic> subscription,
  });

  /// Get workspace members
  Future<List<Map<String, dynamic>>> getMembers(String workspaceId);

  /// Get pending invitations for workspace
  Future<List<Map<String, dynamic>>> getPendingInvitations(String workspaceId);

  /// Get workspace statistics
  Future<Map<String, dynamic>> getWorkspaceStatistics(String workspaceId);

  /// Get workspace activity
  Future<List<Map<String, dynamic>>> getWorkspaceActivity({
    required String workspaceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Check if user has permission
  Future<bool> hasPermission({
    required String workspaceId,
    required String userId,
    required String requiredRole,
  });

  /// Watch workspace (stream)
  Stream<WorkspaceModel> watchWorkspace(String id);

  /// Watch workspaces (stream)
  Stream<List<WorkspaceModel>> watchWorkspaces({
    required String userId,
  });

  /// Watch workspace members (stream)
  Stream<List<Map<String, dynamic>>> watchMembers(String workspaceId);
}

/// Firebase implementation of workspace remote data source
class FirebaseWorkspaceRemoteDataSourceImpl
    implements FirebaseWorkspaceRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseWorkspaceRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(workspace.id);
      final workspaceData = workspace.toJson();
      workspaceData['createdAt'] = FieldValue.serverTimestamp();
      workspaceData['updatedAt'] = FieldValue.serverTimestamp();

      await workspaceRef.set(workspaceData);

      // Get the created workspace with server timestamps
      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create workspace',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> getWorkspace(String id) async {
    try {
      final snapshot = await _firestore.collection('workspaces').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Workspace not found',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<List<WorkspaceModel>> getWorkspaces({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      // Get workspaces where user is owner or member
      Query<Map<String, dynamic>> ownerQuery = _firestore
          .collection('workspaces')
          .where('ownerId', isEqualTo: userId);

      if (!includeArchived) {
        ownerQuery = ownerQuery.where('isArchived', isEqualTo: false);
      }

      if (!includeDeleted) {
        ownerQuery = ownerQuery.where('isDeleted', isEqualTo: false);
      }

      final ownerSnapshot = await ownerQuery.get();

      // Get workspaces where user is a member (not owner)
      final memberSnapshot = await _firestore
          .collection('workspaces')
          .where('members', arrayContains: {'userId': userId})
          .get();

      // Combine results
      final workspaces = <WorkspaceModel>[];
      final seenIds = <String>{};

      for (final doc in ownerSnapshot.docs) {
        final workspace = WorkspaceModel.fromJson(doc.data());
        if (!seenIds.contains(workspace.id)) {
          workspaces.add(workspace);
          seenIds.add(workspace.id);
        }
      }

      for (final doc in memberSnapshot.docs) {
        final workspace = WorkspaceModel.fromJson(doc.data());
        if (!seenIds.contains(workspace.id)) {
          if (includeDeleted || !workspace.isDeleted) {
            if (includeArchived || !workspace.isArchived) {
              workspaces.add(workspace);
              seenIds.add(workspace.id);
            }
          }
        }
      }

      // Sort by name
      workspaces.sort((a, b) => a.name.compareTo(b.name));

      return workspaces;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get workspaces',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get workspaces',
        originalException: e,
      );
    }
  }

  @override
  Future<List<WorkspaceModel>> getOwnedWorkspaces(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('workspaces')
          .where('ownerId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => WorkspaceModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get owned workspaces',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get owned workspaces',
        originalException: e,
      );
    }
  }

  @override
  Future<List<WorkspaceModel>> getMemberWorkspaces(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('workspaces')
          .where('members', arrayContains: {'userId': userId})
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => WorkspaceModel.fromJson(doc.data()))
          .where((w) => w.ownerId != userId) // Exclude owned workspaces
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get member workspaces',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get member workspaces',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> updateWorkspace(WorkspaceModel workspace) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(workspace.id);
      final workspaceData = workspace.toJson();
      workspaceData['updatedAt'] = FieldValue.serverTimestamp();

      await workspaceRef.update(workspaceData);

      // Get the updated workspace with server timestamps
      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update workspace',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteWorkspace(String id) async {
    try {
      await _firestore.collection('workspaces').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteWorkspace(String id) async {
    try {
      await _firestore.collection('workspaces').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> restoreWorkspace(String id) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(id);

      await workspaceRef.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to restore workspace',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to restore workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to restore workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> archiveWorkspace(String id) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(id);

      await workspaceRef.update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to archive workspace',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to archive workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to archive workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> unarchiveWorkspace(String id) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(id);

      await workspaceRef.update({
        'isArchived': false,
        'archivedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to unarchive workspace',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to unarchive workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to unarchive workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> addMember({
    required String workspaceId,
    required String userId,
    String? email,
    required String role,
    required String invitedBy,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);

      final members = List<Map<String, dynamic>>.from(
        workspace.members.map((m) => {
              'userId': m.userId,
              'email': m.email,
              'role': m.role,
              'joinedAt': m.joinedAt?.toIso8601String(),
              'invitedBy': m.invitedBy,
              'status': m.status,
            }),
      );

      // Check if user is already a member
      if (members.any((m) => m['userId'] == userId)) {
        throw const ValidationException(
          message: 'User is already a member of this workspace',
        );
      }

      members.add({
        'userId': userId,
        'email': email,
        'role': role,
        'joinedAt': DateTime.now().toIso8601String(),
        'invitedBy': invitedBy,
        'status': 'pending',
      });

      final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

      await workspaceRef.update({
        'members': members,
        'memberCount': members.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to add member',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to add member',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);

      if (workspace.ownerId == userId) {
        throw const ValidationException(
          message: 'Cannot remove workspace owner',
        );
      }

      final members = List<Map<String, dynamic>>.from(
        workspace.members
            .where((m) => m.userId != userId)
            .map((m) => {
                  'userId': m.userId,
                  'email': m.email,
                  'role': m.role,
                  'joinedAt': m.joinedAt?.toIso8601String(),
                  'invitedBy': m.invitedBy,
                  'status': m.status,
                }),
      );

      final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

      await workspaceRef.update({
        'members': members,
        'memberCount': members.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to remove member',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to remove member',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);

      if (workspace.ownerId == userId) {
        throw const ValidationException(
          message: 'Cannot change owner role',
        );
      }

      final members = List<Map<String, dynamic>>.from(
        workspace.members.map((m) => {
              'userId': m.userId,
              'email': m.email,
              'role': m.userId == userId ? role : m.role,
              'joinedAt': m.joinedAt?.toIso8601String(),
              'invitedBy': m.invitedBy,
              'status': m.status,
            }),
      );

      final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

      await workspaceRef.update({
        'members': members,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update member role',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to update member role',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> acceptInvitation(String workspaceId) async {
    try {
      // In production, this would update invitation status
      // For now, just return the workspace
      return await getWorkspace(workspaceId);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to accept invitation',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to accept invitation',
        originalException: e,
      );
    }
  }

  @override
  Future<void> declineInvitation(String workspaceId) async {
    try {
      // In production, this would update invitation status or remove pending invite
      // For now, this is a no-op
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to decline invitation',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to decline invitation',
        originalException: e,
      );
    }
  }

  @override
  Future<void> leaveWorkspace(String workspaceId) async {
    try {
      // User leaving workspace - remove them from members
      // This should be handled by removeMember in production
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to leave workspace',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to leave workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> transferOwnership({
    required String workspaceId,
    required String newOwnerId,
  }) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

      await workspaceRef.update({
        'ownerId': newOwnerId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to transfer ownership',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to transfer ownership',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to transfer ownership',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> updateSettings({
    required String workspaceId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

      await workspaceRef.update({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update settings',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update settings',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update settings',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceModel> updateSubscription({
    required String workspaceId,
    required Map<String, dynamic> subscription,
  }) async {
    try {
      final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

      await workspaceRef.update({
        'subscription': subscription,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await workspaceRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update subscription',
        );
      }

      return WorkspaceModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update subscription',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update subscription',
        originalException: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMembers(String workspaceId) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      return workspace.members
          .map((m) => {
                'userId': m.userId,
                'email': m.email,
                'role': m.role,
                'joinedAt': m.joinedAt?.toIso8601String(),
                'invitedBy': m.invitedBy,
                'status': m.status,
              })
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get members',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get members',
        originalException: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingInvitations(
      String workspaceId) async {
    try {
      final members = await getMembers(workspaceId);
      return members.where((m) => m['status'] == 'pending').toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get pending invitations',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get pending invitations',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getWorkspaceStatistics(
      String workspaceId) async {
    try {
      final workspace = await getWorkspace(workspaceId);

      // Get task count
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('workspaceId', isEqualTo: workspaceId)
          .where('isDeleted', isEqualTo: false)
          .count()
          .get();

      // Get list count
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('workspaceId', isEqualTo: workspaceId)
          .where('isDeleted', isEqualTo: false)
          .count()
          .get();

      return {
        'workspaceId': workspaceId,
        'name': workspace.name,
        'memberCount': workspace.memberCount,
        'taskCount': tasksSnapshot.count ?? 0,
        'listCount': listsSnapshot.count ?? 0,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get workspace statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get workspace statistics',
        originalException: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWorkspaceActivity({
    required String workspaceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('activity_logs')
          .where('workspaceId', isEqualTo: workspaceId);

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('timestamp', descending: true).limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get workspace activity',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get workspace activity',
        originalException: e,
      );
    }
  }

  @override
  Future<bool> hasPermission({
    required String workspaceId,
    required String userId,
    required String requiredRole,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);

      // Owner has all permissions
      if (workspace.ownerId == userId) {
        return true;
      }

      // Check member role
      final member = workspace.members.firstWhere(
        (m) => m.userId == userId,
        orElse: () => throw const ValidationException(
          message: 'User is not a member of this workspace',
        ),
      );

      // Role hierarchy: owner > admin > member > viewer
      const roleHierarchy = {
        'owner': 4,
        'admin': 3,
        'member': 2,
        'viewer': 1,
      };

      final userRoleLevel = roleHierarchy[member.role] ?? 0;
      final requiredRoleLevel = roleHierarchy[requiredRole] ?? 0;

      return userRoleLevel >= requiredRoleLevel;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to check permission',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to check permission',
        originalException: e,
      );
    }
  }

  @override
  Stream<WorkspaceModel> watchWorkspace(String id) {
    try {
      return _firestore
          .collection('workspaces')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'Workspace not found',
          );
        }
        return WorkspaceModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch workspace',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<WorkspaceModel>> watchWorkspaces({
    required String userId,
  }) {
    try {
      // Watch owned workspaces
      return _firestore
          .collection('workspaces')
          .where('ownerId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => WorkspaceModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch workspaces',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchMembers(String workspaceId) {
    try {
      return watchWorkspace(workspaceId).map((workspace) => workspace.members
          .map((m) => {
                'userId': m.userId,
                'email': m.email,
                'role': m.role,
                'joinedAt': m.joinedAt?.toIso8601String(),
                'invitedBy': m.invitedBy,
                'status': m.status,
              })
          .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch members',
        originalException: e,
      );
    }
  }
}
