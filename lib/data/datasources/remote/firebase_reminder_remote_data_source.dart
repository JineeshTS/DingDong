import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/reminder_entity.dart';
import '../../models/reminder_model.dart';

/// Firebase remote data source for reminder operations
abstract class FirebaseReminderRemoteDataSource {
  /// Create a new reminder
  Future<ReminderModel> createReminder(ReminderModel reminder);

  /// Get reminder by ID
  Future<ReminderModel> getReminder(String id);

  /// Get all reminders for task
  Future<List<ReminderModel>> getRemindersForTask(String taskId);

  /// Get all reminders for user
  Future<List<ReminderModel>> getReminders({
    required String userId,
    bool includeDeleted = false,
  });

  /// Get active reminders (enabled and not triggered)
  Future<List<ReminderModel>> getActiveReminders(String userId);

  /// Get reminders due soon (within next X hours)
  Future<List<ReminderModel>> getRemindersDueSoon({
    required String userId,
    required Duration within,
  });

  /// Get overdue reminders
  Future<List<ReminderModel>> getOverdueReminders(String userId);

  /// Get location-based reminders
  Future<List<ReminderModel>> getLocationReminders(String userId);

  /// Update reminder
  Future<ReminderModel> updateReminder(ReminderModel reminder);

  /// Delete reminder
  Future<void> deleteReminder(String id);

  /// Permanently delete reminder
  Future<void> permanentlyDeleteReminder(String id);

  /// Enable/disable reminder
  Future<ReminderModel> setReminderEnabled({
    required String reminderId,
    required bool enabled,
  });

  /// Mark reminder as triggered
  Future<ReminderModel> markAsTriggered(String reminderId);

  /// Snooze reminder (reschedule for later)
  Future<ReminderModel> snoozeReminder({
    required String reminderId,
    required Duration duration,
  });

  /// Batch create reminders
  Future<List<ReminderModel>> batchCreateReminders(List<ReminderModel> reminders);

  /// Batch delete reminders
  Future<void> batchDeleteReminders(List<String> reminderIds);

  /// Delete all reminders for task
  Future<void> deleteRemindersForTask(String taskId);

  /// Watch reminder (stream)
  Stream<ReminderModel> watchReminder(String id);

  /// Watch reminders for task (stream)
  Stream<List<ReminderModel>> watchRemindersForTask(String taskId);

  /// Watch active reminders (stream) - for notification service
  Stream<List<ReminderModel>> watchActiveReminders(String userId);
}

/// Firebase implementation of reminder remote data source
class FirebaseReminderRemoteDataSourceImpl
    implements FirebaseReminderRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseReminderRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    try {
      final reminderRef = _firestore.collection('reminders').doc(reminder.id);
      final reminderData = reminder.toJson();
      reminderData['createdAt'] = FieldValue.serverTimestamp();
      reminderData['updatedAt'] = FieldValue.serverTimestamp();

      await reminderRef.set(reminderData);

      // Get the created reminder with server timestamps
      final snapshot = await reminderRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create reminder',
        );
      }

      return ReminderModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create reminder',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<ReminderModel> getReminder(String id) async {
    try {
      final snapshot = await _firestore.collection('reminders').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Reminder not found',
        );
      }

      return ReminderModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get reminder',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderModel>> getRemindersForTask(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('reminders')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('reminderTime')
          .get();

      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get reminders for task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get reminders for task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderModel>> getReminders({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId);

      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      query = query.orderBy('reminderTime');

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get reminders',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderModel>> getActiveReminders(String userId) async {
    try {
      final now = DateTime.now();

      final snapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .where('isEnabled', isEqualTo: true)
          .where('isTriggered', isEqualTo: false)
          .where('isDeleted', isEqualTo: false)
          .orderBy('reminderTime')
          .get();

      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get active reminders',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get active reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderModel>> getRemindersDueSoon({
    required String userId,
    required Duration within,
  }) async {
    try {
      final now = DateTime.now();
      final futureTime = now.add(within);

      final snapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .where('isEnabled', isEqualTo: true)
          .where('isTriggered', isEqualTo: false)
          .where('isDeleted', isEqualTo: false)
          .where('reminderTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('reminderTime',
              isLessThanOrEqualTo: Timestamp.fromDate(futureTime))
          .orderBy('reminderTime')
          .get();

      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get reminders due soon',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get reminders due soon',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderModel>> getOverdueReminders(String userId) async {
    try {
      final now = DateTime.now();

      final snapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .where('isEnabled', isEqualTo: true)
          .where('isTriggered', isEqualTo: false)
          .where('isDeleted', isEqualTo: false)
          .where('reminderTime', isLessThan: Timestamp.fromDate(now))
          .orderBy('reminderTime')
          .get();

      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get overdue reminders',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get overdue reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderModel>> getLocationReminders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .where('isEnabled', isEqualTo: true)
          .where('isTriggered', isEqualTo: false)
          .where('isDeleted', isEqualTo: false)
          .where('type', isEqualTo: 'location')
          .get();

      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get location reminders',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get location reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<ReminderModel> updateReminder(ReminderModel reminder) async {
    try {
      final reminderRef = _firestore.collection('reminders').doc(reminder.id);
      final reminderData = reminder.toJson();
      reminderData['updatedAt'] = FieldValue.serverTimestamp();

      await reminderRef.update(reminderData);

      // Get the updated reminder with server timestamps
      final snapshot = await reminderRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update reminder',
        );
      }

      return ReminderModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update reminder',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await _firestore.collection('reminders').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete reminder',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteReminder(String id) async {
    try {
      await _firestore.collection('reminders').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete reminder',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<ReminderModel> setReminderEnabled({
    required String reminderId,
    required bool enabled,
  }) async {
    try {
      final reminderRef = _firestore.collection('reminders').doc(reminderId);

      await reminderRef.update({
        'isEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await reminderRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to set reminder enabled',
        );
      }

      return ReminderModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to set reminder enabled',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to set reminder enabled',
        originalException: e,
      );
    }
  }

  @override
  Future<ReminderModel> markAsTriggered(String reminderId) async {
    try {
      final reminderRef = _firestore.collection('reminders').doc(reminderId);

      await reminderRef.update({
        'isTriggered': true,
        'triggeredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await reminderRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to mark reminder as triggered',
        );
      }

      return ReminderModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to mark reminder as triggered',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to mark reminder as triggered',
        originalException: e,
      );
    }
  }

  @override
  Future<ReminderModel> snoozeReminder({
    required String reminderId,
    required Duration duration,
  }) async {
    try {
      final reminder = await getReminder(reminderId);

      if (reminder.reminderTime == null) {
        throw const ValidationException(
          message: 'Cannot snooze reminder without reminder time',
        );
      }

      final newReminderTime = DateTime.now().add(duration);

      final reminderRef = _firestore.collection('reminders').doc(reminderId);

      await reminderRef.update({
        'reminderTime': Timestamp.fromDate(newReminderTime),
        'isTriggered': false,
        'triggeredAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await reminderRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to snooze reminder',
        );
      }

      return ReminderModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to snooze reminder',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to snooze reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderModel>> batchCreateReminders(
      List<ReminderModel> reminders) async {
    try {
      final batch = _firestore.batch();

      for (final reminder in reminders) {
        final reminderRef = _firestore.collection('reminders').doc(reminder.id);
        final reminderData = reminder.toJson();
        reminderData['createdAt'] = FieldValue.serverTimestamp();
        reminderData['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(reminderRef, reminderData);
      }

      await batch.commit();

      // Fetch created reminders
      final createdReminders = <ReminderModel>[];
      for (final reminder in reminders) {
        final snapshot =
            await _firestore.collection('reminders').doc(reminder.id).get();
        if (snapshot.exists) {
          createdReminders.add(ReminderModel.fromJson(snapshot.data()!));
        }
      }

      return createdReminders;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch create reminders',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch create reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchDeleteReminders(List<String> reminderIds) async {
    try {
      final batch = _firestore.batch();

      for (final reminderId in reminderIds) {
        final reminderRef = _firestore.collection('reminders').doc(reminderId);
        batch.update(reminderRef, {
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch delete reminders',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch delete reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteRemindersForTask(String taskId) async {
    try {
      final reminders = await getRemindersForTask(taskId);
      final reminderIds = reminders.map((r) => r.id).toList();

      if (reminderIds.isNotEmpty) {
        await batchDeleteReminders(reminderIds);
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete reminders for task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete reminders for task',
        originalException: e,
      );
    }
  }

  @override
  Stream<ReminderModel> watchReminder(String id) {
    try {
      return _firestore
          .collection('reminders')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'Reminder not found',
          );
        }
        return ReminderModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch reminder',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ReminderModel>> watchRemindersForTask(String taskId) {
    try {
      return _firestore
          .collection('reminders')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('reminderTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ReminderModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch reminders for task',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ReminderModel>> watchActiveReminders(String userId) {
    try {
      return _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .where('isEnabled', isEqualTo: true)
          .where('isTriggered', isEqualTo: false)
          .where('isDeleted', isEqualTo: false)
          .orderBy('reminderTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ReminderModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch active reminders',
        originalException: e,
      );
    }
  }
}
