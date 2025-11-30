/// Comprehensive Mock Repositories for Testing
///
/// This file contains mock implementations for all domain repositories
/// Used for unit testing use cases and business logic.

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';

import '../../lib/core/errors/failures.dart';
import '../../lib/domain/entities/user_entity.dart';
import '../../lib/domain/entities/task_entity.dart';
import '../../lib/domain/entities/list_entity.dart';
import '../../lib/domain/entities/tag_entity.dart';
import '../../lib/domain/entities/reminder_entity.dart';
import '../../lib/domain/entities/comment_entity.dart';
import '../../lib/domain/entities/attachment_entity.dart';
import '../../lib/domain/entities/habit_entity.dart';
import '../../lib/domain/entities/focus_session_entity.dart';
import '../../lib/domain/entities/workspace_entity.dart';
import '../../lib/domain/repositories/auth_repository.dart';
import '../../lib/domain/repositories/user_repository.dart';
import '../../lib/domain/repositories/list_repository.dart';
import '../../lib/domain/repositories/tag_repository.dart';
import '../../lib/domain/repositories/reminder_repository.dart';
import '../../lib/domain/repositories/comment_repository.dart';
import '../../lib/domain/repositories/attachment_repository.dart';
import '../../lib/domain/repositories/habit_repository.dart';
import '../../lib/domain/repositories/focus_session_repository.dart';
import '../../lib/domain/repositories/workspace_repository.dart';

// ============================================================
// MOCK AUTH REPOSITORY
// ============================================================

class MockAuthRepository extends Mock implements AuthRepository {
  UserEntity? _currentUser;
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void setCurrentUser(UserEntity? user) => _currentUser = user;
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? AuthenticationFailure('Mock auth failure');
  }

  void reset() {
    _currentUser = null;
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final user = UserEntity(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: 'Test User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final user = UserEntity(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (_shouldFail) return Left(_failureToReturn!);
    final user = UserEntity(
      id: 'google_user_id',
      email: 'google@test.com',
      displayName: 'Google User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    if (_shouldFail) return Left(_failureToReturn!);
    final user = UserEntity(
      id: 'apple_user_id',
      email: 'apple@test.com',
      displayName: 'Apple User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (_shouldFail) return Left(_failureToReturn!);
    _currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (_shouldFail) return Left(_failureToReturn!);
    return Right(_currentUser);
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return Stream.value(_currentUser);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (_shouldFail) return Left(_failureToReturn!);
    _currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isEmailVerified() async {
    if (_shouldFail) return Left(_failureToReturn!);
    return const Right(true);
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    if (_shouldFail) return Left(_failureToReturn!);
    return const Right(null);
  }
}

// ============================================================
// MOCK USER REPOSITORY
// ============================================================

class MockUserRepository extends Mock implements UserRepository {
  final Map<String, UserEntity> _users = {};
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addUser(UserEntity user) => _users[user.id] = user;
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock user failure');
  }

  void reset() {
    _users.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, UserEntity>> getUser(String userId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final user = _users[userId];
    if (user == null) return Left(CacheFailure('User not found'));
    return Right(user);
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _users[user.id] = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? bio,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final user = _users[userId];
    if (user == null) return Left(CacheFailure('User not found'));
    final updated = user.copyWith(
      displayName: displayName ?? user.displayName,
      photoUrl: photoUrl ?? user.photoUrl,
      updatedAt: DateTime.now(),
    );
    _users[userId] = updated;
    return Right(updated);
  }

  @override
  Stream<Either<Failure, UserEntity>> watchUser(String userId) {
    if (_shouldFail) {
      return Stream.value(Left(_failureToReturn!));
    }
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      final user = _users[userId];
      if (user == null) return Left(CacheFailure('User not found'));
      return Right(user);
    });
  }
}

// ============================================================
// MOCK LIST REPOSITORY
// ============================================================

class MockListRepository extends Mock implements ListRepository {
  final List<ListEntity> _lists = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addLists(List<ListEntity> lists) => _lists.addAll(lists);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock list failure');
  }

  void reset() {
    _lists.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, ListEntity>> createList(ListEntity list) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _lists.add(list);
    return Right(list);
  }

  @override
  Future<Either<Failure, ListEntity>> getList(String listId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    try {
      final list = _lists.firstWhere((l) => l.id == listId);
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('List not found'));
    }
  }

  @override
  Future<Either<Failure, List<ListEntity>>> getLists({
    String? userId,
    String? workspaceId,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    var filtered = List<ListEntity>.from(_lists);
    if (userId != null) {
      filtered = filtered.where((l) => l.ownerId == userId).toList();
    }
    if (workspaceId != null) {
      filtered = filtered.where((l) => l.workspaceId == workspaceId).toList();
    }
    return Right(filtered);
  }

  @override
  Future<Either<Failure, ListEntity>> updateList(ListEntity list) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _lists.indexWhere((l) => l.id == list.id);
    if (index == -1) return Left(CacheFailure('List not found'));
    _lists[index] = list;
    return Right(list);
  }

  @override
  Future<Either<Failure, void>> deleteList(String listId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _lists.removeWhere((l) => l.id == listId);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<ListEntity>>> watchLists({
    String? userId,
    String? workspaceId,
  }) {
    if (_shouldFail) return Stream.value(Left(_failureToReturn!));
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      var filtered = List<ListEntity>.from(_lists);
      if (userId != null) {
        filtered = filtered.where((l) => l.ownerId == userId).toList();
      }
      return Right(filtered);
    });
  }
}

// ============================================================
// MOCK TAG REPOSITORY
// ============================================================

class MockTagRepository extends Mock implements TagRepository {
  final List<TagEntity> _tags = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addTags(List<TagEntity> tags) => _tags.addAll(tags);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock tag failure');
  }

  void reset() {
    _tags.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, TagEntity>> createTag(TagEntity tag) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _tags.add(tag);
    return Right(tag);
  }

  @override
  Future<Either<Failure, List<TagEntity>>> getTags(String userId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return Right(_tags.where((t) => t.userId == userId).toList());
  }

  @override
  Future<Either<Failure, TagEntity>> updateTag(TagEntity tag) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _tags.indexWhere((t) => t.id == tag.id);
    if (index == -1) return Left(CacheFailure('Tag not found'));
    _tags[index] = tag;
    return Right(tag);
  }

  @override
  Future<Either<Failure, void>> deleteTag(String tagId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _tags.removeWhere((t) => t.id == tagId);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<TagEntity>>> watchTags(String userId) {
    if (_shouldFail) return Stream.value(Left(_failureToReturn!));
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      return Right(_tags.where((t) => t.userId == userId).toList());
    });
  }
}

// ============================================================
// MOCK REMINDER REPOSITORY
// ============================================================

class MockReminderRepository extends Mock implements ReminderRepository {
  final List<ReminderEntity> _reminders = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addReminders(List<ReminderEntity> reminders) =>
      _reminders.addAll(reminders);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock reminder failure');
  }

  void reset() {
    _reminders.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, ReminderEntity>> createReminder(
      ReminderEntity reminder) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _reminders.add(reminder);
    return Right(reminder);
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getReminders({
    String? taskId,
    String? userId,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    var filtered = List<ReminderEntity>.from(_reminders);
    if (taskId != null) {
      filtered = filtered.where((r) => r.taskId == taskId).toList();
    }
    if (userId != null) {
      filtered = filtered.where((r) => r.userId == userId).toList();
    }
    return Right(filtered);
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _reminders.removeWhere((r) => r.id == reminderId);
    return const Right(null);
  }
}

// ============================================================
// MOCK COMMENT REPOSITORY
// ============================================================

class MockCommentRepository extends Mock implements CommentRepository {
  final List<CommentEntity> _comments = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addComments(List<CommentEntity> comments) => _comments.addAll(comments);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock comment failure');
  }

  void reset() {
    _comments.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, CommentEntity>> createComment(
      CommentEntity comment) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _comments.add(comment);
    return Right(comment);
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(
      String taskId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return Right(_comments.where((c) => c.taskId == taskId).toList());
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment(
      CommentEntity comment) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _comments.indexWhere((c) => c.id == comment.id);
    if (index == -1) return Left(CacheFailure('Comment not found'));
    _comments[index] = comment;
    return Right(comment);
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _comments.removeWhere((c) => c.id == commentId);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<CommentEntity>>> watchComments(String taskId) {
    if (_shouldFail) return Stream.value(Left(_failureToReturn!));
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      return Right(_comments.where((c) => c.taskId == taskId).toList());
    });
  }
}

// ============================================================
// MOCK ATTACHMENT REPOSITORY
// ============================================================

class MockAttachmentRepository extends Mock implements AttachmentRepository {
  final List<AttachmentEntity> _attachments = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addAttachments(List<AttachmentEntity> attachments) =>
      _attachments.addAll(attachments);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock attachment failure');
  }

  void reset() {
    _attachments.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, AttachmentEntity>> uploadAttachment({
    required String taskId,
    required String userId,
    required String filePath,
    required String fileName,
    required String mimeType,
    required int fileSize,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final attachment = AttachmentEntity(
      id: 'attachment_${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      userId: userId,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
      url: 'https://storage.test.com/$fileName',
      createdAt: DateTime.now(),
    );
    _attachments.add(attachment);
    return Right(attachment);
  }

  @override
  Future<Either<Failure, List<AttachmentEntity>>> getAttachments(
      String taskId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return Right(_attachments.where((a) => a.taskId == taskId).toList());
  }

  @override
  Future<Either<Failure, void>> deleteAttachment(String attachmentId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _attachments.removeWhere((a) => a.id == attachmentId);
    return const Right(null);
  }
}

// ============================================================
// MOCK HABIT REPOSITORY
// ============================================================

class MockHabitRepository extends Mock implements HabitRepository {
  final List<HabitEntity> _habits = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addHabits(List<HabitEntity> habits) => _habits.addAll(habits);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock habit failure');
  }

  void reset() {
    _habits.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, HabitEntity>> createHabit(HabitEntity habit) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _habits.add(habit);
    return Right(habit);
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits(String userId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return Right(_habits.where((h) => h.userId == userId).toList());
  }

  @override
  Future<Either<Failure, HabitEntity>> updateHabit(HabitEntity habit) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) return Left(CacheFailure('Habit not found'));
    _habits[index] = habit;
    return Right(habit);
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _habits.removeWhere((h) => h.id == habitId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, HabitEntity>> logHabitCompletion({
    required String habitId,
    required DateTime date,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return Left(CacheFailure('Habit not found'));
    return Right(_habits[index]);
  }

  @override
  Stream<Either<Failure, List<HabitEntity>>> watchHabits(String userId) {
    if (_shouldFail) return Stream.value(Left(_failureToReturn!));
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      return Right(_habits.where((h) => h.userId == userId).toList());
    });
  }
}

// ============================================================
// MOCK FOCUS SESSION REPOSITORY
// ============================================================

class MockFocusSessionRepository extends Mock
    implements FocusSessionRepository {
  final List<FocusSessionEntity> _sessions = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addSessions(List<FocusSessionEntity> sessions) =>
      _sessions.addAll(sessions);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock focus session failure');
  }

  void reset() {
    _sessions.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> startSession({
    required String userId,
    required int duration,
    String? taskId,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final session = FocusSessionEntity(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      taskId: taskId,
      duration: duration,
      startTime: DateTime.now(),
      status: FocusSessionStatus.active,
      createdAt: DateTime.now(),
    );
    _sessions.add(session);
    return Right(session);
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> endSession(
      String sessionId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return Left(CacheFailure('Session not found'));
    final ended = _sessions[index].copyWith(
      endTime: DateTime.now(),
      status: FocusSessionStatus.completed,
    );
    _sessions[index] = ended;
    return Right(ended);
  }

  @override
  Future<Either<Failure, List<FocusSessionEntity>>> getSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return Right(_sessions.where((s) => s.userId == userId).toList());
  }

  @override
  Future<Either<Failure, FocusSessionEntity?>> getActiveSession(
      String userId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    try {
      final session = _sessions.firstWhere(
        (s) => s.userId == userId && s.status == FocusSessionStatus.active,
      );
      return Right(session);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Stream<Either<Failure, FocusSessionEntity?>> watchActiveSession(
      String userId) {
    if (_shouldFail) return Stream.value(Left(_failureToReturn!));
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      try {
        final session = _sessions.firstWhere(
          (s) => s.userId == userId && s.status == FocusSessionStatus.active,
        );
        return Right(session);
      } catch (e) {
        return const Right(null);
      }
    });
  }
}

// ============================================================
// MOCK WORKSPACE REPOSITORY
// ============================================================

class MockWorkspaceRepository extends Mock implements WorkspaceRepository {
  final List<WorkspaceEntity> _workspaces = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  void addWorkspaces(List<WorkspaceEntity> workspaces) =>
      _workspaces.addAll(workspaces);
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock workspace failure');
  }

  void reset() {
    _workspaces.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> createWorkspace(
      WorkspaceEntity workspace) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _workspaces.add(workspace);
    return Right(workspace);
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> getWorkspace(
      String workspaceId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    try {
      final workspace = _workspaces.firstWhere((w) => w.id == workspaceId);
      return Right(workspace);
    } catch (e) {
      return Left(CacheFailure('Workspace not found'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceEntity>>> getWorkspaces(
      String userId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    return Right(
        _workspaces.where((w) => w.members.contains(userId)).toList());
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> updateWorkspace(
      WorkspaceEntity workspace) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _workspaces.indexWhere((w) => w.id == workspace.id);
    if (index == -1) return Left(CacheFailure('Workspace not found'));
    _workspaces[index] = workspace;
    return Right(workspace);
  }

  @override
  Future<Either<Failure, void>> deleteWorkspace(String workspaceId) async {
    if (_shouldFail) return Left(_failureToReturn!);
    _workspaces.removeWhere((w) => w.id == workspaceId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> addMember({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) return Left(CacheFailure('Workspace not found'));
    final updated = _workspaces[index].copyWith(
      members: [..._workspaces[index].members, userId],
    );
    _workspaces[index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    if (_shouldFail) return Left(_failureToReturn!);
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) return Left(CacheFailure('Workspace not found'));
    final updated = _workspaces[index].copyWith(
      members: _workspaces[index].members.where((m) => m != userId).toList(),
    );
    _workspaces[index] = updated;
    return Right(updated);
  }

  @override
  Stream<Either<Failure, List<WorkspaceEntity>>> watchWorkspaces(
      String userId) {
    if (_shouldFail) return Stream.value(Left(_failureToReturn!));
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      return Right(
          _workspaces.where((w) => w.members.contains(userId)).toList());
    });
  }
}
