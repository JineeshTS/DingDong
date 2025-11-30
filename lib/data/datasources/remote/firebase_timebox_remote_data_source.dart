import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/timebox_model.dart';

/// Firebase remote data source for timebox operations
///
/// Handles remote storage and synchronization of daily timebox data
/// including task slots, conflicts, and settings.
abstract class FirebaseTimeboxRemoteDataSource {
  /// Create a new timebox
  Future<TimeboxModel> createTimebox(TimeboxModel timebox);

  /// Get timebox by ID
  Future<TimeboxModel> getTimebox(String id);

  /// Get timebox for specific date
  Future<TimeboxModel> getTimeboxForDate({
    required String userId,
    required DateTime date,
  });

  /// Get timeboxes for date range
  Future<List<TimeboxModel>> getTimeboxesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update timebox
  Future<TimeboxModel> updateTimebox(TimeboxModel timebox);

  /// Delete timebox
  Future<void> deleteTimebox(String id);

  /// Add slot to timebox
  Future<TimeboxModel> addSlot({
    required String timeboxId,
    required TimeboxSlotModel slot,
  });

  /// Update slot
  Future<TimeboxModel> updateSlot({
    required String timeboxId,
    required TimeboxSlotModel slot,
  });

  /// Delete slot
  Future<TimeboxModel> deleteSlot({
    required String timeboxId,
    required String slotId,
  });

  /// Complete slot
  Future<TimeboxModel> completeSlot({
    required String timeboxId,
    required String slotId,
  });

  /// Skip slot
  Future<TimeboxModel> skipSlot({
    required String timeboxId,
    required String slotId,
  });

  /// Reschedule slot
  Future<TimeboxModel> rescheduleSlot({
    required String timeboxId,
    required String slotId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  });

  /// Batch update slots
  Future<TimeboxModel> batchUpdateSlots({
    required String timeboxId,
    required List<TimeboxSlotModel> slots,
  });

  /// Update conflicts
  Future<TimeboxModel> updateConflicts({
    required String timeboxId,
    required List<TimeConflictModel> conflicts,
  });

  /// Update summary
  Future<TimeboxModel> updateSummary({
    required String timeboxId,
    required TimeboxSummaryModel summary,
  });

  /// Update settings
  Future<TimeboxModel> updateSettings({
    required String timeboxId,
    required TimeboxSettingsModel settings,
  });

  /// Watch timebox (stream)
  Stream<TimeboxModel> watchTimebox(String id);

  /// Watch timebox for date (stream)
  Stream<TimeboxModel?> watchTimeboxForDate({
    required String userId,
    required DateTime date,
  });

  /// Get timebox statistics
  Future<Map<String, dynamic>> getTimeboxStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Firebase implementation of timebox remote data source
class FirebaseTimeboxRemoteDataSourceImpl
    implements FirebaseTimeboxRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseTimeboxRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _timeboxCollection =>
      _firestore.collection('timeboxes');

  @override
  Future<TimeboxModel> createTimebox(TimeboxModel timebox) async {
    try {
      final timeboxRef = _timeboxCollection.doc(timebox.id);
      final timeboxData = timebox.toJson();
      timeboxData['createdAt'] = FieldValue.serverTimestamp();
      timeboxData['updatedAt'] = FieldValue.serverTimestamp();

      await timeboxRef.set(timeboxData);

      // Get the created timebox with server timestamps
      final snapshot = await timeboxRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create timebox',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create timebox',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create timebox',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> getTimebox(String id) async {
    try {
      final snapshot = await _timeboxCollection.doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Timebox not found',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get timebox',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get timebox',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> getTimeboxForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      // Normalize date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);

      final snapshot = await _timeboxCollection
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const CacheException(
          message: 'Timebox not found for date',
        );
      }

      return TimeboxModel.fromJson(snapshot.docs.first.data());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get timebox for date',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get timebox for date',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TimeboxModel>> getTimeboxesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Normalize dates to midnight
      final normalizedStart =
          DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

      final snapshot = await _timeboxCollection
          .where('userId', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(normalizedEnd))
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => TimeboxModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get timeboxes for date range',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get timeboxes for date range',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> updateTimebox(TimeboxModel timebox) async {
    try {
      final timeboxRef = _timeboxCollection.doc(timebox.id);
      final timeboxData = timebox.toJson();
      timeboxData['updatedAt'] = FieldValue.serverTimestamp();

      await timeboxRef.update(timeboxData);

      // Get the updated timebox with server timestamp
      final snapshot = await timeboxRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update timebox',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update timebox',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update timebox',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteTimebox(String id) async {
    try {
      await _timeboxCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete timebox',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete timebox',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> addSlot({
    required String timeboxId,
    required TimeboxSlotModel slot,
  }) async {
    try {
      final timeboxRef = _timeboxCollection.doc(timeboxId);

      await timeboxRef.update({
        'slots': FieldValue.arrayUnion([slot.toJson()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await timeboxRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to add slot',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to add slot',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add slot',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> updateSlot({
    required String timeboxId,
    required TimeboxSlotModel slot,
  }) async {
    try {
      // Get current timebox
      final currentTimebox = await getTimebox(timeboxId);

      // Update the specific slot
      final updatedSlots = currentTimebox.slots.map((s) {
        return s.id == slot.id ? slot : s;
      }).toList();

      // Update timebox with new slots
      final updatedTimebox = currentTimebox.copyWith(
        slots: updatedSlots,
      );

      return await updateTimebox(updatedTimebox);
    } catch (e) {
      throw ServerException(
        message: 'Failed to update slot',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> deleteSlot({
    required String timeboxId,
    required String slotId,
  }) async {
    try {
      // Get current timebox
      final currentTimebox = await getTimebox(timeboxId);

      // Remove the specific slot
      final updatedSlots =
          currentTimebox.slots.where((s) => s.id != slotId).toList();

      // Update timebox with new slots
      final updatedTimebox = currentTimebox.copyWith(
        slots: updatedSlots,
      );

      return await updateTimebox(updatedTimebox);
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete slot',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> completeSlot({
    required String timeboxId,
    required String slotId,
  }) async {
    try {
      // Get current timebox
      final currentTimebox = await getTimebox(timeboxId);

      // Update the specific slot to completed status
      final updatedSlots = currentTimebox.slots.map((s) {
        if (s.id == slotId) {
          return s.copyWith(status: 'completed');
        }
        return s;
      }).toList();

      // Update timebox with new slots
      final updatedTimebox = currentTimebox.copyWith(
        slots: updatedSlots,
      );

      return await updateTimebox(updatedTimebox);
    } catch (e) {
      throw ServerException(
        message: 'Failed to complete slot',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> skipSlot({
    required String timeboxId,
    required String slotId,
  }) async {
    try {
      // Get current timebox
      final currentTimebox = await getTimebox(timeboxId);

      // Update the specific slot to skipped status
      final updatedSlots = currentTimebox.slots.map((s) {
        if (s.id == slotId) {
          return s.copyWith(status: 'skipped');
        }
        return s;
      }).toList();

      // Update timebox with new slots
      final updatedTimebox = currentTimebox.copyWith(
        slots: updatedSlots,
      );

      return await updateTimebox(updatedTimebox);
    } catch (e) {
      throw ServerException(
        message: 'Failed to skip slot',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> rescheduleSlot({
    required String timeboxId,
    required String slotId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  }) async {
    try {
      // Get current timebox
      final currentTimebox = await getTimebox(timeboxId);

      // Update the specific slot with new times
      final updatedSlots = currentTimebox.slots.map((s) {
        if (s.id == slotId) {
          return s.copyWith(
            startTime: newStartTime,
            endTime: newEndTime,
          );
        }
        return s;
      }).toList();

      // Update timebox with new slots
      final updatedTimebox = currentTimebox.copyWith(
        slots: updatedSlots,
      );

      return await updateTimebox(updatedTimebox);
    } catch (e) {
      throw ServerException(
        message: 'Failed to reschedule slot',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> batchUpdateSlots({
    required String timeboxId,
    required List<TimeboxSlotModel> slots,
  }) async {
    try {
      final timeboxRef = _timeboxCollection.doc(timeboxId);

      await timeboxRef.update({
        'slots': slots.map((s) => s.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await timeboxRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to batch update slots',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch update slots',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch update slots',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> updateConflicts({
    required String timeboxId,
    required List<TimeConflictModel> conflicts,
  }) async {
    try {
      final timeboxRef = _timeboxCollection.doc(timeboxId);

      await timeboxRef.update({
        'conflicts': conflicts.map((c) => c.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await timeboxRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update conflicts',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update conflicts',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update conflicts',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> updateSummary({
    required String timeboxId,
    required TimeboxSummaryModel summary,
  }) async {
    try {
      final timeboxRef = _timeboxCollection.doc(timeboxId);

      await timeboxRef.update({
        'summary': summary.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await timeboxRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update summary',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update summary',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update summary',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxModel> updateSettings({
    required String timeboxId,
    required TimeboxSettingsModel settings,
  }) async {
    try {
      final timeboxRef = _timeboxCollection.doc(timeboxId);

      await timeboxRef.update({
        'settings': settings.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await timeboxRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update settings',
        );
      }

      return TimeboxModel.fromJson(snapshot.data()!);
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
  Stream<TimeboxModel> watchTimebox(String id) {
    try {
      return _timeboxCollection.doc(id).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'Timebox not found',
          );
        }
        return TimeboxModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch timebox',
        originalException: e,
      );
    }
  }

  @override
  Stream<TimeboxModel?> watchTimeboxForDate({
    required String userId,
    required DateTime date,
  }) {
    try {
      // Normalize date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);

      return _timeboxCollection
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }
        return TimeboxModel.fromJson(snapshot.docs.first.data());
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch timebox for date',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getTimeboxStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final timeboxes = await getTimeboxesForDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      int totalSlots = 0;
      int completedSlots = 0;
      int skippedSlots = 0;
      int totalConflicts = 0;
      double totalScheduledMinutes = 0;
      Map<String, int> categoryBreakdown = {};
      Map<String, int> priorityBreakdown = {};

      for (final timebox in timeboxes) {
        totalSlots += timebox.slots.length;
        totalConflicts += timebox.conflicts.length;

        for (final slot in timebox.slots) {
          // Count statuses
          if (slot.status == 'completed') completedSlots++;
          if (slot.status == 'skipped') skippedSlots++;

          // Calculate duration
          final duration =
              slot.endTime.difference(slot.startTime).inMinutes.toDouble();
          totalScheduledMinutes += duration;

          // Category breakdown
          categoryBreakdown[slot.category] =
              (categoryBreakdown[slot.category] ?? 0) + 1;

          // Priority breakdown
          priorityBreakdown[slot.priority] =
              (priorityBreakdown[slot.priority] ?? 0) + 1;
        }
      }

      return {
        'totalTimeboxes': timeboxes.length,
        'totalSlots': totalSlots,
        'completedSlots': completedSlots,
        'skippedSlots': skippedSlots,
        'pendingSlots': totalSlots - completedSlots - skippedSlots,
        'completionRate':
            totalSlots > 0 ? (completedSlots / totalSlots) * 100 : 0.0,
        'totalConflicts': totalConflicts,
        'totalScheduledHours': totalScheduledMinutes / 60,
        'averageHoursPerDay': timeboxes.isNotEmpty
            ? (totalScheduledMinutes / 60) / timeboxes.length
            : 0.0,
        'categoryBreakdown': categoryBreakdown,
        'priorityBreakdown': priorityBreakdown,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get timebox statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get timebox statistics',
        originalException: e,
      );
    }
  }
}
