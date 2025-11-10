import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/focus_session_entity.dart';
import '../../models/focus_session_model.dart';

/// Firebase remote data source for focus session operations
abstract class FirebaseFocusSessionRemoteDataSource {
  /// Create a new focus session
  Future<FocusSessionModel> createFocusSession(FocusSessionModel session);

  /// Get focus session by ID
  Future<FocusSessionModel> getFocusSession(String id);

  /// Get all focus sessions for user
  Future<List<FocusSessionModel>> getFocusSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? status,
  });

  /// Get focus sessions for task
  Future<List<FocusSessionModel>> getFocusSessionsForTask(String taskId);

  /// Get active focus session for user
  Future<FocusSessionModel?> getActiveFocusSession(String userId);

  /// Get focus sessions for today
  Future<List<FocusSessionModel>> getFocusSessionsToday(String userId);

  /// Update focus session
  Future<FocusSessionModel> updateFocusSession(FocusSessionModel session);

  /// Complete focus session
  Future<FocusSessionModel> completeFocusSession({
    required String sessionId,
    String? notes,
  });

  /// Cancel focus session
  Future<FocusSessionModel> cancelFocusSession(String sessionId);

  /// Pause focus session
  Future<FocusSessionModel> pauseFocusSession(String sessionId);

  /// Resume focus session
  Future<FocusSessionModel> resumeFocusSession(String sessionId);

  /// Add interruption to session
  Future<FocusSessionModel> addInterruption({
    required String sessionId,
    required Duration pauseDuration,
    String? reason,
  });

  /// Delete focus session
  Future<void> deleteFocusSession(String id);

  /// Get total focus time
  Future<Duration> getTotalFocusTime({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus session count
  Future<int> getFocusSessionCount({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get average session duration
  Future<Duration> getAverageFocusDuration({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus quality score (average)
  Future<double> getAverageFocusQuality({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus time by task
  Future<Map<String, Duration>> getFocusTimeByTask({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus time by list
  Future<Map<String, Duration>> getFocusTimeByList({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get longest focus streak (consecutive days)
  Future<int> getLongestFocusStreak(String userId);

  /// Get current focus streak
  Future<int> getCurrentFocusStreak(String userId);

  /// Get focus statistics
  Future<Map<String, dynamic>> getFocusStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus trends (daily/weekly/monthly)
  Future<Map<String, dynamic>> getFocusTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Watch active focus session (stream)
  Stream<FocusSessionModel?> watchActiveFocusSession(String userId);

  /// Watch focus sessions (stream)
  Stream<List<FocusSessionModel>> watchFocusSessions({
    required String userId,
    DateTime? startDate,
  });
}

/// Firebase implementation of focus session remote data source
class FirebaseFocusSessionRemoteDataSourceImpl
    implements FirebaseFocusSessionRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseFocusSessionRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<FocusSessionModel> createFocusSession(FocusSessionModel session) async {
    try {
      final sessionRef = _firestore.collection('focus_sessions').doc(session.id);
      final sessionData = session.toJson();
      sessionData['createdAt'] = FieldValue.serverTimestamp();
      sessionData['updatedAt'] = FieldValue.serverTimestamp();

      await sessionRef.set(sessionData);

      // Get the created session with server timestamps
      final snapshot = await sessionRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create focus session',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel> getFocusSession(String id) async {
    try {
      final snapshot = await _firestore.collection('focus_sessions').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Focus session not found',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionModel>> getFocusSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('focus_sessions')
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('startTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('startTime', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => FocusSessionModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus sessions',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionModel>> getFocusSessionsForTask(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('focus_sessions')
          .where('taskId', isEqualTo: taskId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FocusSessionModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus sessions for task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus sessions for task',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel?> getActiveFocusSession(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('focus_sessions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return FocusSessionModel.fromJson(snapshot.docs.first.data());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get active focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get active focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionModel>> getFocusSessionsToday(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return getFocusSessions(
        userId: userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus sessions today',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus sessions today',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel> updateFocusSession(FocusSessionModel session) async {
    try {
      final sessionRef = _firestore.collection('focus_sessions').doc(session.id);
      final sessionData = session.toJson();
      sessionData['updatedAt'] = FieldValue.serverTimestamp();

      await sessionRef.update(sessionData);

      // Get the updated session with server timestamps
      final snapshot = await sessionRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update focus session',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel> completeFocusSession({
    required String sessionId,
    String? notes,
  }) async {
    try {
      final sessionRef = _firestore.collection('focus_sessions').doc(sessionId);

      final updateData = {
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await sessionRef.update(updateData);

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to complete focus session',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to complete focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to complete focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel> cancelFocusSession(String sessionId) async {
    try {
      final sessionRef = _firestore.collection('focus_sessions').doc(sessionId);

      await sessionRef.update({
        'status': 'cancelled',
        'endTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to cancel focus session',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to cancel focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to cancel focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel> pauseFocusSession(String sessionId) async {
    try {
      final sessionRef = _firestore.collection('focus_sessions').doc(sessionId);

      await sessionRef.update({
        'status': 'paused',
        'pausedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to pause focus session',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to pause focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to pause focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel> resumeFocusSession(String sessionId) async {
    try {
      final sessionRef = _firestore.collection('focus_sessions').doc(sessionId);

      await sessionRef.update({
        'status': 'active',
        'resumedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to resume focus session',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to resume focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to resume focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionModel> addInterruption({
    required String sessionId,
    required Duration pauseDuration,
    String? reason,
  }) async {
    try {
      final session = await getFocusSession(sessionId);

      // Add interruption to the list
      final interruptions = List<Map<String, dynamic>>.from(
        session.interruptions.map((i) => {
              'timestamp': i.timestamp.toIso8601String(),
              'duration': i.duration.inSeconds,
              'reason': i.reason,
            }),
      );

      interruptions.add({
        'timestamp': DateTime.now().toIso8601String(),
        'duration': pauseDuration.inSeconds,
        'reason': reason,
      });

      final sessionRef = _firestore.collection('focus_sessions').doc(sessionId);

      await sessionRef.update({
        'interruptions': interruptions,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await sessionRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to add interruption',
        );
      }

      return FocusSessionModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to add interruption',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add interruption',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteFocusSession(String id) async {
    try {
      await _firestore.collection('focus_sessions').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete focus session',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<Duration> getTotalFocusTime({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        status: 'completed',
      );

      var totalSeconds = 0;
      for (final session in sessions) {
        if (session.actualDuration != null) {
          totalSeconds += session.actualDuration!.inSeconds;
        }
      }

      return Duration(seconds: totalSeconds);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get total focus time',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get total focus time',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getFocusSessionCount({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return sessions.length;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus session count',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus session count',
        originalException: e,
      );
    }
  }

  @override
  Future<Duration> getAverageFocusDuration({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        status: 'completed',
      );

      if (sessions.isEmpty) {
        return Duration.zero;
      }

      var totalSeconds = 0;
      for (final session in sessions) {
        if (session.actualDuration != null) {
          totalSeconds += session.actualDuration!.inSeconds;
        }
      }

      final avgSeconds = totalSeconds ~/ sessions.length;
      return Duration(seconds: avgSeconds);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get average focus duration',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get average focus duration',
        originalException: e,
      );
    }
  }

  @override
  Future<double> getAverageFocusQuality({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        status: 'completed',
      );

      if (sessions.isEmpty) {
        return 0.0;
      }

      var totalQuality = 0.0;
      var count = 0;

      for (final session in sessions) {
        if (session.focusQualityScore != null) {
          totalQuality += session.focusQualityScore!;
          count++;
        }
      }

      return count > 0 ? totalQuality / count : 0.0;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get average focus quality',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get average focus quality',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, Duration>> getFocusTimeByTask({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        status: 'completed',
      );

      final focusTimeByTask = <String, int>{};

      for (final session in sessions) {
        if (session.taskId != null && session.actualDuration != null) {
          focusTimeByTask[session.taskId!] =
              (focusTimeByTask[session.taskId!] ?? 0) + session.actualDuration!.inSeconds;
        }
      }

      return focusTimeByTask.map((key, value) => MapEntry(key, Duration(seconds: value)));
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus time by task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus time by task',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, Duration>> getFocusTimeByList({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        status: 'completed',
      );

      final focusTimeByList = <String, int>{};

      for (final session in sessions) {
        if (session.listId != null && session.actualDuration != null) {
          focusTimeByList[session.listId!] =
              (focusTimeByList[session.listId!] ?? 0) + session.actualDuration!.inSeconds;
        }
      }

      return focusTimeByList.map((key, value) => MapEntry(key, Duration(seconds: value)));
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus time by list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus time by list',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getLongestFocusStreak(String userId) async {
    try {
      // Get all completed sessions
      final sessions = await getFocusSessions(
        userId: userId,
        status: 'completed',
      );

      if (sessions.isEmpty) return 0;

      // Group sessions by date
      final sessionsByDate = <String, List<FocusSessionModel>>{};
      for (final session in sessions) {
        final dateKey = _formatDate(session.startTime);
        sessionsByDate.putIfAbsent(dateKey, () => []).add(session);
      }

      // Sort dates
      final sortedDates = sessionsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

      // Calculate longest streak
      var longestStreak = 0;
      var currentStreak = 0;
      DateTime? previousDate;

      for (final dateKey in sortedDates.reversed) {
        final date = DateTime.parse(dateKey);

        if (previousDate == null || date.difference(previousDate).inDays == 1) {
          currentStreak++;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else if (date.difference(previousDate).inDays > 1) {
          currentStreak = 1;
        }

        previousDate = date;
      }

      return longestStreak;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get longest focus streak',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get longest focus streak',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getCurrentFocusStreak(String userId) async {
    try {
      // Get all completed sessions
      final sessions = await getFocusSessions(
        userId: userId,
        status: 'completed',
      );

      if (sessions.isEmpty) return 0;

      // Group sessions by date
      final sessionsByDate = <String, List<FocusSessionModel>>{};
      for (final session in sessions) {
        final dateKey = _formatDate(session.startTime);
        sessionsByDate.putIfAbsent(dateKey, () => []).add(session);
      }

      // Sort dates
      final sortedDates = sessionsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

      // Calculate current streak from today backwards
      var currentStreak = 0;
      final today = _formatDate(DateTime.now());

      for (var i = 0; i < sortedDates.length; i++) {
        final expectedDate = DateTime.now().subtract(Duration(days: i));
        final expectedDateKey = _formatDate(expectedDate);

        if (sortedDates.contains(expectedDateKey)) {
          currentStreak++;
        } else {
          break;
        }
      }

      return currentStreak;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get current focus streak',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get current focus streak',
        originalException: e,
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<Map<String, dynamic>> getFocusStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final totalTime = await getTotalFocusTime(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final sessionCount = await getFocusSessionCount(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final avgDuration = await getAverageFocusDuration(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final avgQuality = await getAverageFocusQuality(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final currentStreak = await getCurrentFocusStreak(userId);
      final longestStreak = await getLongestFocusStreak(userId);

      return {
        'totalFocusTime': totalTime.inSeconds,
        'sessionCount': sessionCount,
        'averageDuration': avgDuration.inSeconds,
        'averageQuality': avgQuality,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus statistics',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getFocusTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final sessions = await getFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        status: 'completed',
      );

      // Group by date
      final sessionsByDate = <String, List<FocusSessionModel>>{};
      for (final session in sessions) {
        final dateKey = _formatDate(session.startTime);
        sessionsByDate.putIfAbsent(dateKey, () => []).add(session);
      }

      // Calculate daily totals
      final dailyTrends = <String, Map<String, dynamic>>{};
      for (final entry in sessionsByDate.entries) {
        var totalDuration = 0;
        var totalQuality = 0.0;
        var qualityCount = 0;

        for (final session in entry.value) {
          if (session.actualDuration != null) {
            totalDuration += session.actualDuration!.inSeconds;
          }
          if (session.focusQualityScore != null) {
            totalQuality += session.focusQualityScore!;
            qualityCount++;
          }
        }

        dailyTrends[entry.key] = {
          'date': entry.key,
          'sessionCount': entry.value.length,
          'totalDuration': totalDuration,
          'averageQuality': qualityCount > 0 ? totalQuality / qualityCount : 0.0,
        };
      }

      return {
        'dailyTrends': dailyTrends,
        'totalSessions': sessions.length,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get focus trends',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get focus trends',
        originalException: e,
      );
    }
  }

  @override
  Stream<FocusSessionModel?> watchActiveFocusSession(String userId) {
    try {
      return _firestore
          .collection('focus_sessions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }
        return FocusSessionModel.fromJson(snapshot.docs.first.data());
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch active focus session',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<FocusSessionModel>> watchFocusSessions({
    required String userId,
    DateTime? startDate,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('focus_sessions')
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      query = query.orderBy('startTime', descending: true);

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => FocusSessionModel.fromJson(doc.data()))
          .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch focus sessions',
        originalException: e,
      );
    }
  }
}
