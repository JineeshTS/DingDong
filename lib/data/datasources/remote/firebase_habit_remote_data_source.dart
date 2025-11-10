import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/habit_entity.dart';
import '../../models/habit_model.dart';

/// Firebase remote data source for habit operations
abstract class FirebaseHabitRemoteDataSource {
  /// Create a new habit
  Future<HabitModel> createHabit(HabitModel habit);

  /// Get habit by ID
  Future<HabitModel> getHabit(String id);

  /// Get all habits for user
  Future<List<HabitModel>> getHabits({
    required String userId,
    String? category,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get habits by category
  Future<List<HabitModel>> getHabitsByCategory({
    required String userId,
    required String category,
  });

  /// Get active habits (not archived)
  Future<List<HabitModel>> getActiveHabits(String userId);

  /// Update habit
  Future<HabitModel> updateHabit(HabitModel habit);

  /// Delete habit (soft delete)
  Future<void> deleteHabit(String id);

  /// Permanently delete habit
  Future<void> permanentlyDeleteHabit(String id);

  /// Restore habit
  Future<HabitModel> restoreHabit(String id);

  /// Archive habit
  Future<HabitModel> archiveHabit(String id);

  /// Unarchive habit
  Future<HabitModel> unarchiveHabit(String id);

  /// Check in habit (mark as completed for date)
  Future<HabitModel> checkInHabit({
    required String habitId,
    DateTime? date,
    String? note,
    int count = 1,
  });

  /// Undo check-in
  Future<HabitModel> undoCheckIn({
    required String habitId,
    required String checkInId,
  });

  /// Get habits due today
  Future<List<HabitModel>> getHabitsDueToday(String userId);

  /// Get habit check-in history
  Future<List<Map<String, dynamic>>> getCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Calculate streak
  Future<int> calculateStreak(String habitId);

  /// Get habit statistics
  Future<Map<String, dynamic>> getHabitStatistics({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get all habits statistics for user
  Future<Map<String, dynamic>> getUserHabitStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get completion rate
  Future<double> getCompletionRate({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get best streak
  Future<int> getBestStreak(String habitId);

  /// Watch habit (stream)
  Stream<HabitModel> watchHabit(String id);

  /// Watch habits (stream)
  Stream<List<HabitModel>> watchHabits({
    required String userId,
    String? category,
  });

  /// Watch habits due today (stream)
  Stream<List<HabitModel>> watchHabitsDueToday(String userId);
}

/// Firebase implementation of habit remote data source
class FirebaseHabitRemoteDataSourceImpl
    implements FirebaseHabitRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  FirebaseHabitRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final habitRef = _firestore.collection('habits').doc(habit.id);
      final habitData = habit.toJson();
      habitData['createdAt'] = FieldValue.serverTimestamp();
      habitData['updatedAt'] = FieldValue.serverTimestamp();

      await habitRef.set(habitData);

      // Get the created habit with server timestamps
      final snapshot = await habitRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create habit',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create habit',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitModel> getHabit(String id) async {
    try {
      final snapshot = await _firestore.collection('habits').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Habit not found',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get habit',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitModel>> getHabits({
    required String userId,
    String? category,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (!includeArchived) {
        query = query.where('isArchived', isEqualTo: false);
      }

      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => HabitModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get habits',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get habits',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitModel>> getHabitsByCategory({
    required String userId,
    required String category,
  }) async {
    return getHabits(userId: userId, category: category);
  }

  @override
  Future<List<HabitModel>> getActiveHabits(String userId) async {
    return getHabits(userId: userId, includeArchived: false);
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      final habitRef = _firestore.collection('habits').doc(habit.id);
      final habitData = habit.toJson();
      habitData['updatedAt'] = FieldValue.serverTimestamp();

      await habitRef.update(habitData);

      // Get the updated habit with server timestamps
      final snapshot = await habitRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update habit',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update habit',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await _firestore.collection('habits').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete habit',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteHabit(String id) async {
    try {
      await _firestore.collection('habits').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete habit',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitModel> restoreHabit(String id) async {
    try {
      final habitRef = _firestore.collection('habits').doc(id);

      await habitRef.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await habitRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to restore habit',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to restore habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to restore habit',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitModel> archiveHabit(String id) async {
    try {
      final habitRef = _firestore.collection('habits').doc(id);

      await habitRef.update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await habitRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to archive habit',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to archive habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to archive habit',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitModel> unarchiveHabit(String id) async {
    try {
      final habitRef = _firestore.collection('habits').doc(id);

      await habitRef.update({
        'isArchived': false,
        'archivedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await habitRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to unarchive habit',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to unarchive habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to unarchive habit',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitModel> checkInHabit({
    required String habitId,
    DateTime? date,
    String? note,
    int count = 1,
  }) async {
    try {
      final habit = await getHabit(habitId);
      final checkInDate = date ?? DateTime.now();
      final dateKey = _formatDate(checkInDate);

      // Create check-in object
      final checkIn = {
        'id': _uuid.v4(),
        'date': Timestamp.fromDate(checkInDate),
        'dateKey': dateKey,
        'count': count,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add check-in to habit
      final checkIns = List<Map<String, dynamic>>.from(
        habit.checkIns.map((c) => {
              'id': c.id,
              'date': c.date.toIso8601String(),
              'dateKey': _formatDate(c.date),
              'count': c.count,
              'note': c.note,
            }),
      );

      // Remove existing check-in for the same date if exists
      checkIns.removeWhere((c) => c['dateKey'] == dateKey);

      // Add new check-in
      checkIns.add(checkIn);

      // Calculate new streak
      final currentStreak = _calculateStreakFromCheckIns(checkIns);

      final habitRef = _firestore.collection('habits').doc(habitId);
      await habitRef.update({
        'checkIns': checkIns,
        'currentStreak': currentStreak,
        'bestStreak': currentStreak > habit.bestStreak ? currentStreak : habit.bestStreak,
        'lastCheckIn': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await habitRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to check in habit',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to check in habit',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to check in habit',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitModel> undoCheckIn({
    required String habitId,
    required String checkInId,
  }) async {
    try {
      final habit = await getHabit(habitId);

      // Remove check-in
      final checkIns = List<Map<String, dynamic>>.from(
        habit.checkIns
            .where((c) => c.id != checkInId)
            .map((c) => {
                  'id': c.id,
                  'date': c.date.toIso8601String(),
                  'dateKey': _formatDate(c.date),
                  'count': c.count,
                  'note': c.note,
                }),
      );

      // Recalculate streak
      final currentStreak = _calculateStreakFromCheckIns(checkIns);

      final habitRef = _firestore.collection('habits').doc(habitId);
      await habitRef.update({
        'checkIns': checkIns,
        'currentStreak': currentStreak,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await habitRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to undo check-in',
        );
      }

      return HabitModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to undo check-in',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to undo check-in',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitModel>> getHabitsDueToday(String userId) async {
    try {
      final habits = await getActiveHabits(userId);
      final today = DateTime.now().weekday;

      // Filter habits that are due today based on frequency
      final habitsDueToday = habits.where((habit) {
        final frequency = habit.frequency;

        if (frequency.type == HabitFrequencyType.daily) {
          return true;
        } else if (frequency.type == HabitFrequencyType.weekly) {
          return frequency.daysOfWeek?.contains(today) ?? false;
        } else if (frequency.type == HabitFrequencyType.monthly) {
          final dayOfMonth = DateTime.now().day;
          return frequency.daysOfMonth?.contains(dayOfMonth) ?? false;
        }

        return false;
      }).toList();

      return habitsDueToday;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get habits due today',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get habits due today',
        originalException: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final habit = await getHabit(habitId);

      var checkIns = habit.checkIns.map((c) => {
            'id': c.id,
            'date': c.date,
            'count': c.count,
            'note': c.note,
          }).toList();

      if (startDate != null) {
        checkIns = checkIns.where((c) {
          final date = c['date'] as DateTime;
          return date.isAfter(startDate) || date.isAtSameMomentAs(startDate);
        }).toList();
      }

      if (endDate != null) {
        checkIns = checkIns.where((c) {
          final date = c['date'] as DateTime;
          return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        }).toList();
      }

      // Sort by date descending
      checkIns.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      return checkIns;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get check-in history',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get check-in history',
        originalException: e,
      );
    }
  }

  @override
  Future<int> calculateStreak(String habitId) async {
    try {
      final habit = await getHabit(habitId);
      final checkIns = habit.checkIns.map((c) => {
            'dateKey': _formatDate(c.date),
          }).toList();

      return _calculateStreakFromCheckIns(checkIns);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to calculate streak',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to calculate streak',
        originalException: e,
      );
    }
  }

  int _calculateStreakFromCheckIns(List<Map<String, dynamic>> checkIns) {
    if (checkIns.isEmpty) return 0;

    // Sort by date
    final sortedCheckIns = checkIns.toList()
      ..sort((a, b) => (b['dateKey'] as String).compareTo(a['dateKey'] as String));

    var streak = 0;
    var currentDate = DateTime.now();

    for (var i = 0; i < sortedCheckIns.length; i++) {
      final checkInDateKey = sortedCheckIns[i]['dateKey'] as String;
      final expectedDateKey = _formatDate(currentDate.subtract(Duration(days: i)));

      if (checkInDateKey == expectedDateKey) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<Map<String, dynamic>> getHabitStatistics({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final habit = await getHabit(habitId);
      final checkIns = await getCheckInHistory(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      final totalCheckIns = checkIns.length;
      final currentStreak = habit.currentStreak;
      final bestStreak = habit.bestStreak;

      // Calculate expected check-ins based on frequency
      final daysSinceStart = startDate != null
          ? DateTime.now().difference(startDate).inDays
          : DateTime.now().difference(habit.createdAt).inDays;

      var expectedCheckIns = 0;
      if (habit.frequency.type == HabitFrequencyType.daily) {
        expectedCheckIns = daysSinceStart;
      } else if (habit.frequency.type == HabitFrequencyType.weekly) {
        final weeksCount = (daysSinceStart / 7).ceil();
        expectedCheckIns = weeksCount * (habit.frequency.daysOfWeek?.length ?? 1);
      }

      final completionRate = expectedCheckIns > 0
          ? (totalCheckIns / expectedCheckIns) * 100
          : 0.0;

      return {
        'habitId': habitId,
        'habitName': habit.name,
        'totalCheckIns': totalCheckIns,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'completionRate': completionRate,
        'expectedCheckIns': expectedCheckIns,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get habit statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get habit statistics',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserHabitStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final habits = await getHabits(userId: userId);

      var totalHabits = habits.length;
      var activeHabits = habits.where((h) => !h.isArchived).length;
      var totalCheckIns = 0;
      var totalCurrentStreak = 0;
      var maxStreak = 0;

      for (final habit in habits) {
        totalCheckIns += habit.checkIns.length;
        totalCurrentStreak += habit.currentStreak;
        if (habit.bestStreak > maxStreak) {
          maxStreak = habit.bestStreak;
        }
      }

      final avgCurrentStreak = activeHabits > 0 ? totalCurrentStreak / activeHabits : 0.0;

      return {
        'totalHabits': totalHabits,
        'activeHabits': activeHabits,
        'archivedHabits': totalHabits - activeHabits,
        'totalCheckIns': totalCheckIns,
        'averageCurrentStreak': avgCurrentStreak,
        'longestStreak': maxStreak,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get user habit statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get user habit statistics',
        originalException: e,
      );
    }
  }

  @override
  Future<double> getCompletionRate({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await getHabitStatistics(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      return stats['completionRate'] as double;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get completion rate',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get completion rate',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getBestStreak(String habitId) async {
    try {
      final habit = await getHabit(habitId);
      return habit.bestStreak;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get best streak',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get best streak',
        originalException: e,
      );
    }
  }

  @override
  Stream<HabitModel> watchHabit(String id) {
    try {
      return _firestore
          .collection('habits')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'Habit not found',
          );
        }
        return HabitModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch habit',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<HabitModel>> watchHabits({
    required String userId,
    String? category,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => HabitModel.fromJson(doc.data())).toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch habits',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<HabitModel>> watchHabitsDueToday(String userId) {
    try {
      // Note: This needs client-side filtering since Firestore can't handle complex queries
      return watchHabits(userId: userId).asyncMap((habits) async {
        final today = DateTime.now().weekday;

        return habits.where((habit) {
          if (habit.isArchived) return false;

          final frequency = habit.frequency;

          if (frequency.type == HabitFrequencyType.daily) {
            return true;
          } else if (frequency.type == HabitFrequencyType.weekly) {
            return frequency.daysOfWeek?.contains(today) ?? false;
          } else if (frequency.type == HabitFrequencyType.monthly) {
            final dayOfMonth = DateTime.now().day;
            return frequency.daysOfMonth?.contains(dayOfMonth) ?? false;
          }

          return false;
        }).toList();
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch habits due today',
        originalException: e,
      );
    }
  }
}
