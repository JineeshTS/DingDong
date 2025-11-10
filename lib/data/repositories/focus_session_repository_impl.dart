import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/focus_session_entity.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../datasources/local/isar/isar_focus_session_local_data_source.dart';
import '../datasources/local/isar/schemas/focus_session_isar.dart';
import '../datasources/remote/firebase_focus_session_remote_data_source.dart';
import '../models/focus_session_model.dart';

/// Focus session repository implementation with offline-first architecture
class FocusSessionRepositoryImpl implements FocusSessionRepository {
  final FirebaseFocusSessionRemoteDataSource remoteDataSource;
  final IsarFocusSessionLocalDataSource localDataSource;

  FocusSessionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, FocusSessionEntity>> createFocusSession(
      FocusSessionEntity session) async {
    try {
      final model = FocusSessionModel.fromEntity(session);

      // Save to local first
      final isarSession = _modelToIsar(model);
      isarSession.isDirty = true;
      await localDataSource.upsertFocusSession(isarSession);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createFocusSession(model);

        // Update local with server data
        final syncedIsarSession = _modelToIsar(createdModel);
        await localDataSource.upsertFocusSession(syncedIsarSession);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(session);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to create focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> getFocusSession(
      String id) async {
    try {
      // Try local first
      final localSession = await localDataSource.getFocusSessionByFirebaseId(id);

      if (localSession != null) {
        return Right(_isarToEntity(localSession));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getFocusSession(id);

      // Save to local
      final isarSession = _modelToIsar(remoteModel);
      await localDataSource.upsertFocusSession(isarSession);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    FocusSessionType? type,
    FocusSessionStatus? status,
  }) async {
    try {
      // Try local first
      final localSessions = await localDataSource.getFocusSessionsByUser(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (localSessions.isNotEmpty) {
        var filtered = localSessions;

        if (type != null) {
          filtered = filtered
              .where((s) => s.type == _typeToIsar(type))
              .toList();
        }

        if (status != null) {
          filtered = filtered
              .where((s) => s.status == _statusToIsar(status))
              .toList();
        }

        return Right(filtered.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        type: type != null ? _typeToString(type) : null,
        status: status != null ? _statusToString(status) : null,
      );

      // Save to local
      final isarSessions = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertFocusSessions(isarSessions);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get focus sessions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessionsForTask(
      String taskId) async {
    try {
      // Get from local
      final localSessions = await localDataSource.getFocusSessionsForTask(taskId);

      return Right(localSessions.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get focus sessions for task: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity?>> getActiveFocusSession(
      String userId) async {
    try {
      // Get from local
      final localSession = await localDataSource.getActiveFocusSession(userId);

      if (localSession == null) {
        return const Right(null);
      }

      return Right(_isarToEntity(localSession));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get active focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessionsToday(
      String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Get from local
      final localSessions = await localDataSource.getFocusSessionsByUser(
        userId: userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      return Right(localSessions.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to get focus sessions today: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> updateFocusSession(
      FocusSessionEntity session) async {
    try {
      final model = FocusSessionModel.fromEntity(session);

      // Save to local first
      final isarSession = _modelToIsar(model);
      isarSession.isDirty = true;
      await localDataSource.upsertFocusSession(isarSession);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateFocusSession(model);

        // Update local with synced data
        final syncedIsarSession = _modelToIsar(updatedModel);
        await localDataSource.upsertFocusSession(syncedIsarSession);
        await localDataSource.markAsSynced(session.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(session);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to update focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> completeFocusSession({
    required String sessionId,
    String? notes,
  }) async {
    try {
      final model = await remoteDataSource.completeFocusSession(
        sessionId: sessionId,
        notes: notes,
      );

      // Update local
      final isarSession = _modelToIsar(model);
      await localDataSource.upsertFocusSession(isarSession);
      await localDataSource.markAsSynced(sessionId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to complete focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> cancelFocusSession(
      String sessionId) async {
    try {
      final model = await remoteDataSource.cancelFocusSession(sessionId);

      // Update local
      final isarSession = _modelToIsar(model);
      await localDataSource.upsertFocusSession(isarSession);
      await localDataSource.markAsSynced(sessionId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to cancel focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> pauseFocusSession(
      String sessionId) async {
    try {
      // Update locally first (instant feedback)
      await localDataSource.pauseFocusSession(sessionId);

      // Sync to remote in background
      remoteDataSource.pauseFocusSession(sessionId).then((model) {
        final isarSession = _modelToIsar(model);
        localDataSource.upsertFocusSession(isarSession);
        localDataSource.markAsSynced(sessionId);
      }).catchError((_) {
        localDataSource.markAsDirty(sessionId);
      });

      final localSession =
          await localDataSource.getFocusSessionByFirebaseId(sessionId);
      return Right(_isarToEntity(localSession!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to pause focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> resumeFocusSession(
      String sessionId) async {
    try {
      // Update locally first (instant feedback)
      await localDataSource.resumeFocusSession(sessionId);

      // Sync to remote in background
      remoteDataSource.resumeFocusSession(sessionId).then((model) {
        final isarSession = _modelToIsar(model);
        localDataSource.upsertFocusSession(isarSession);
        localDataSource.markAsSynced(sessionId);
      }).catchError((_) {
        localDataSource.markAsDirty(sessionId);
      });

      final localSession =
          await localDataSource.getFocusSessionByFirebaseId(sessionId);
      return Right(_isarToEntity(localSession!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to resume focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> addInterruption({
    required String sessionId,
    required Duration pauseDuration,
    String? reason,
  }) async {
    try {
      final model = await remoteDataSource.addInterruption(
        sessionId: sessionId,
        pauseDuration: pauseDuration,
        reason: reason,
      );

      // Update local
      final isarSession = _modelToIsar(model);
      await localDataSource.upsertFocusSession(isarSession);
      await localDataSource.markAsSynced(sessionId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add interruption: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFocusSession(String id) async {
    try {
      await remoteDataSource.deleteFocusSession(id);
      await localDataSource.deleteFocusSession(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to delete focus session: $e'));
    }
  }

  @override
  Future<Either<Failure, Duration>> getTotalFocusTime({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final totalSeconds = await remoteDataSource.getTotalFocusTime(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(Duration(seconds: totalSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get total focus time: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getFocusSessionCount({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final count = await remoteDataSource.getFocusSessionCount(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get focus session count: $e'));
    }
  }

  @override
  Future<Either<Failure, Duration>> getAverageFocusDuration({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final avgSeconds = await remoteDataSource.getAverageFocusDuration(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(Duration(seconds: avgSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to get average focus duration: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageFocusQuality({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final quality = await remoteDataSource.getAverageFocusQuality(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(quality);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to get average focus quality: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, Duration>>> getFocusTimeByTask({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final timeMap = await remoteDataSource.getFocusTimeByTask(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(timeMap);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get focus time by task: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, Duration>>> getFocusTimeByList({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final timeMap = await remoteDataSource.getFocusTimeByList(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(timeMap);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get focus time by list: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getLongestFocusStreak(String userId) async {
    try {
      final streak = await remoteDataSource.getLongestFocusStreak(userId);

      return Right(streak);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get longest focus streak: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getCurrentFocusStreak(String userId) async {
    try {
      final streak = await remoteDataSource.getCurrentFocusStreak(userId);

      return Right(streak);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get current focus streak: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFocusStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getFocusStatistics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get focus statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFocusTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final trends = await remoteDataSource.getFocusTrends(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(trends);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get focus trends: $e'));
    }
  }

  @override
  Stream<Either<Failure, FocusSessionEntity?>> watchActiveFocusSession(
      String userId) {
    try {
      return localDataSource.watchActiveFocusSession(userId).map((sessionIsar) {
        if (sessionIsar == null) {
          return const Right(null);
        }
        return Right(_isarToEntity(sessionIsar));
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch active session: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch active session: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<FocusSessionEntity>>> watchFocusSessions({
    required String userId,
    DateTime? startDate,
  }) {
    try {
      return localDataSource
          .watchFocusSessions(
        userId: userId,
        startDate: startDate,
      )
          .map((sessionsIsar) {
        return Right(sessionsIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch focus sessions: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch focus sessions: $e')));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert FocusSessionModel to FocusSessionIsar
  FocusSessionIsar _modelToIsar(FocusSessionModel model) {
    return FocusSessionIsar()
      ..sessionId = model.id
      ..userId = model.userId
      ..taskId = model.taskId
      ..listId = model.listId
      ..type = _typeToIsar(model.type as FocusSessionType)
      ..status = _statusToIsar(model.status as FocusSessionStatus)
      ..plannedDuration = model.plannedDurationSeconds ~/ 60
      ..actualDuration = model.actualDurationSeconds != null
          ? model.actualDurationSeconds! ~/ 60
          : null
      ..startTime = model.startTime
      ..endTime = model.endTime
      ..interruptionsJson = model.interruptions.isNotEmpty
          ? jsonEncode(model.interruptions
              .map((i) => {
                    'timestamp': i.timestamp.toIso8601String(),
                    'reason': i.reason,
                    'pauseDurationSeconds': i.pauseDurationSeconds,
                  })
              .toList())
          : null
      ..notes = model.notes
      ..createdAt = model.createdAt
      ..updatedAt = model.createdAt;
  }

  /// Convert FocusSessionIsar to FocusSessionEntity
  FocusSessionEntity _isarToEntity(FocusSessionIsar isar) {
    // Parse interruptions
    final interruptions = isar.interruptionsJson != null
        ? (jsonDecode(isar.interruptionsJson!) as List)
            .map((data) => FocusInterruption(
                  timestamp: DateTime.parse(data['timestamp'] as String),
                  reason: data['reason'] as String?,
                  pauseDuration: Duration(
                      seconds: data['pauseDurationSeconds'] as int? ?? 0),
                ))
            .toList()
        : <FocusInterruption>[];

    return FocusSessionEntity(
      id: isar.sessionId,
      userId: isar.userId,
      taskId: isar.taskId,
      listId: isar.listId,
      type: _typeFromIsar(isar.type),
      status: _statusFromIsar(isar.status),
      plannedDuration: Duration(minutes: isar.plannedDuration),
      actualDuration: isar.actualDuration != null
          ? Duration(minutes: isar.actualDuration!)
          : null,
      startTime: isar.startTime,
      endTime: isar.endTime,
      interruptionsCount: interruptions.length,
      interruptions: interruptions,
      notes: isar.notes,
      metadata: null,
      createdAt: isar.createdAt,
    );
  }

  /// Convert FocusSessionType to string
  String _typeToString(FocusSessionType type) {
    return type.toString().split('.').last;
  }

  /// Convert FocusSessionStatus to string
  String _statusToString(FocusSessionStatus status) {
    return status.toString().split('.').last;
  }

  /// Convert FocusSessionType to FocusSessionTypeIsar
  FocusSessionTypeIsar _typeToIsar(FocusSessionType type) {
    switch (type) {
      case FocusSessionType.pomodoro:
        return FocusSessionTypeIsar.pomodoro;
      case FocusSessionType.shortBreak:
        return FocusSessionTypeIsar.shortBreak;
      case FocusSessionType.longBreak:
        return FocusSessionTypeIsar.longBreak;
      case FocusSessionType.custom:
        return FocusSessionTypeIsar.custom;
    }
  }

  /// Convert FocusSessionTypeIsar to FocusSessionType
  FocusSessionType _typeFromIsar(FocusSessionTypeIsar type) {
    switch (type) {
      case FocusSessionTypeIsar.pomodoro:
        return FocusSessionType.pomodoro;
      case FocusSessionTypeIsar.deepWork:
        return FocusSessionType.custom;
      case FocusSessionTypeIsar.shortBreak:
        return FocusSessionType.shortBreak;
      case FocusSessionTypeIsar.longBreak:
        return FocusSessionType.longBreak;
      case FocusSessionTypeIsar.custom:
        return FocusSessionType.custom;
    }
  }

  /// Convert FocusSessionStatus to FocusSessionStatusIsar
  FocusSessionStatusIsar _statusToIsar(FocusSessionStatus status) {
    switch (status) {
      case FocusSessionStatus.inProgress:
        return FocusSessionStatusIsar.active;
      case FocusSessionStatus.paused:
        return FocusSessionStatusIsar.paused;
      case FocusSessionStatus.completed:
        return FocusSessionStatusIsar.completed;
      case FocusSessionStatus.cancelled:
        return FocusSessionStatusIsar.cancelled;
    }
  }

  /// Convert FocusSessionStatusIsar to FocusSessionStatus
  FocusSessionStatus _statusFromIsar(FocusSessionStatusIsar status) {
    switch (status) {
      case FocusSessionStatusIsar.active:
        return FocusSessionStatus.inProgress;
      case FocusSessionStatusIsar.paused:
        return FocusSessionStatus.paused;
      case FocusSessionStatusIsar.completed:
        return FocusSessionStatus.completed;
      case FocusSessionStatusIsar.cancelled:
        return FocusSessionStatus.cancelled;
    }
  }
}
