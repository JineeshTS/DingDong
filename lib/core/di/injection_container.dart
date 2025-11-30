import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isar/isar.dart';

// Data Sources - Remote (Firebase)
import '../../data/datasources/remote/firebase_auth_remote_datasource.dart';
import '../../data/datasources/remote/firebase_task_remote_datasource.dart';
import '../../data/datasources/remote/firebase_list_remote_datasource.dart';
import '../../data/datasources/remote/firebase_user_remote_datasource.dart';
import '../../data/datasources/remote/firebase_tag_remote_datasource.dart';
import '../../data/datasources/remote/firebase_reminder_remote_datasource.dart';
import '../../data/datasources/remote/firebase_comment_remote_datasource.dart';
import '../../data/datasources/remote/firebase_attachment_remote_datasource.dart';
import '../../data/datasources/remote/firebase_habit_remote_datasource.dart';
import '../../data/datasources/remote/firebase_focus_session_remote_datasource.dart';
import '../../data/datasources/remote/firebase_workspace_remote_datasource.dart';
import '../../data/datasources/remote/firebase_timebox_remote_data_source.dart';

// Data Sources - Local (Isar)
import '../../data/datasources/local/isar_user_local_datasource.dart';
import '../../data/datasources/local/isar_task_local_datasource.dart';
import '../../data/datasources/local/isar_list_local_datasource.dart';
import '../../data/datasources/local/isar_tag_local_datasource.dart';
import '../../data/datasources/local/isar_reminder_local_datasource.dart';
import '../../data/datasources/local/isar_comment_local_datasource.dart';
import '../../data/datasources/local/isar_attachment_local_datasource.dart';
import '../../data/datasources/local/isar_habit_local_datasource.dart';
import '../../data/datasources/local/isar_focus_session_local_datasource.dart';
import '../../data/datasources/local/isar_workspace_local_datasource.dart';
import '../../data/datasources/local/isar_activity_log_local_datasource.dart';
import '../../data/datasources/local/isar/isar_timebox_local_data_source.dart';

// Repositories
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/list_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/tag_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../data/repositories/attachment_repository_impl.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/focus_session_repository_impl.dart';
import '../../data/repositories/workspace_repository_impl.dart';
import '../../data/repositories/timebox_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/list_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../domain/repositories/timebox_repository.dart';

// Services
import '../../core/services/timebox_service.dart';

// Use Cases - Authentication
import '../../domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../domain/usecases/auth/sign_up_with_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_microsoft_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/update_password_usecase.dart';
import '../../domain/usecases/auth/delete_account_usecase.dart';
import '../../domain/usecases/auth/send_password_reset_email_usecase.dart';

// Use Cases - Task
import '../../domain/usecases/task/create_task_usecase.dart';
import '../../domain/usecases/task/update_task_usecase.dart';
import '../../domain/usecases/task/delete_task_usecase.dart';
import '../../domain/usecases/task/get_task_usecase.dart';
import '../../domain/usecases/task/complete_task_usecase.dart';
import '../../domain/usecases/task/uncomplete_task_usecase.dart';
import '../../domain/usecases/task/get_tasks_due_today_usecase.dart';
import '../../domain/usecases/task/get_overdue_tasks_usecase.dart';
import '../../domain/usecases/task/get_upcoming_tasks_usecase.dart';
import '../../domain/usecases/task/get_tasks_by_date_range_usecase.dart';
import '../../domain/usecases/task/get_tasks_by_priority_usecase.dart';
import '../../domain/usecases/task/get_tasks_by_tag_usecase.dart';
import '../../domain/usecases/task/get_tasks_by_list_usecase.dart';
import '../../domain/usecases/task/get_assigned_tasks_usecase.dart';
import '../../domain/usecases/task/get_completed_tasks_usecase.dart';
import '../../domain/usecases/task/search_tasks_usecase.dart';
import '../../domain/usecases/task/move_task_usecase.dart';
import '../../domain/usecases/task/duplicate_task_usecase.dart';
import '../../domain/usecases/task/archive_task_usecase.dart';
import '../../domain/usecases/task/unarchive_task_usecase.dart';
import '../../domain/usecases/task/add_subtask_usecase.dart';
import '../../domain/usecases/task/remove_subtask_usecase.dart';
import '../../domain/usecases/task/assign_task_usecase.dart';
import '../../domain/usecases/task/unassign_task_usecase.dart';
import '../../domain/usecases/task/batch_complete_tasks_usecase.dart';
import '../../domain/usecases/task/batch_delete_tasks_usecase.dart';

// Use Cases - List
import '../../domain/usecases/list/create_list_usecase.dart';
import '../../domain/usecases/list/update_list_usecase.dart';
import '../../domain/usecases/list/delete_list_usecase.dart';
import '../../domain/usecases/list/get_lists_usecase.dart';
import '../../domain/usecases/list/toggle_favorite_list_usecase.dart';
import '../../domain/usecases/list/archive_list_usecase.dart';
import '../../domain/usecases/list/unarchive_list_usecase.dart';
import '../../domain/usecases/list/share_list_usecase.dart';
import '../../domain/usecases/list/get_favorite_lists_usecase.dart';
import '../../domain/usecases/list/get_shared_lists_usecase.dart';

// Use Cases - User
import '../../domain/usecases/user/get_user_usecase.dart';
import '../../domain/usecases/user/update_user_usecase.dart';
import '../../domain/usecases/user/update_user_preferences_usecase.dart';
import '../../domain/usecases/user/update_subscription_usecase.dart';
import '../../domain/usecases/user/toggle_biometric_auth_usecase.dart';
import '../../domain/usecases/user/export_user_data_usecase.dart';
import '../../domain/usecases/user/deactivate_account_usecase.dart';
import '../../domain/usecases/user/reactivate_account_usecase.dart';
import '../../domain/usecases/user/update_theme_mode_usecase.dart';
import '../../domain/usecases/user/update_locale_usecase.dart';

// Use Cases - Reminder
import '../../domain/usecases/reminder/create_reminder_usecase.dart';
import '../../domain/usecases/reminder/update_reminder_usecase.dart';
import '../../domain/usecases/reminder/enable_reminder_usecase.dart';
import '../../domain/usecases/reminder/get_reminders_due_soon_usecase.dart';
import '../../domain/usecases/reminder/delete_reminder_usecase.dart';
import '../../domain/usecases/reminder/snooze_reminder_usecase.dart';
import '../../domain/usecases/reminder/mark_reminder_triggered_usecase.dart';
import '../../domain/usecases/reminder/disable_reminder_usecase.dart';

// Use Cases - Tag
import '../../domain/usecases/tag/create_tag_usecase.dart';
import '../../domain/usecases/tag/update_tag_usecase.dart';
import '../../domain/usecases/tag/delete_tag_usecase.dart';
import '../../domain/usecases/tag/get_tags_usecase.dart';
import '../../domain/usecases/tag/get_popular_tags_usecase.dart';
import '../../domain/usecases/tag/merge_tags_usecase.dart';
import '../../domain/usecases/tag/increment_tag_usage_usecase.dart';
import '../../domain/usecases/tag/restore_tag_usecase.dart';

// Use Cases - Comment
import '../../domain/usecases/comment/create_comment_usecase.dart';
import '../../domain/usecases/comment/update_comment_usecase.dart';
import '../../domain/usecases/comment/delete_comment_usecase.dart';
import '../../domain/usecases/comment/add_reaction_usecase.dart';
import '../../domain/usecases/comment/remove_reaction_usecase.dart';
import '../../domain/usecases/comment/get_comment_count_usecase.dart';
import '../../domain/usecases/comment/search_comments_usecase.dart';
import '../../domain/usecases/comment/get_comments_with_mentions_usecase.dart';

// Use Cases - Attachment
import '../../domain/usecases/attachment/upload_attachment_usecase.dart';
import '../../domain/usecases/attachment/download_attachment_usecase.dart';
import '../../domain/usecases/attachment/delete_attachment_usecase.dart';
import '../../domain/usecases/attachment/get_attachments_by_task_usecase.dart';
import '../../domain/usecases/attachment/get_attachments_by_type_usecase.dart';
import '../../domain/usecases/attachment/get_total_storage_used_usecase.dart';
import '../../domain/usecases/attachment/batch_delete_attachments_usecase.dart';
import '../../domain/usecases/attachment/mark_as_downloaded_usecase.dart';

// Use Cases - Habit
import '../../domain/usecases/habit/create_habit_usecase.dart';
import '../../domain/usecases/habit/update_habit_usecase.dart';
import '../../domain/usecases/habit/delete_habit_usecase.dart';
import '../../domain/usecases/habit/get_habits_usecase.dart';
import '../../domain/usecases/habit/check_in_habit_usecase.dart';
import '../../domain/usecases/habit/undo_check_in_usecase.dart';
import '../../domain/usecases/habit/calculate_streak_usecase.dart';
import '../../domain/usecases/habit/get_habits_due_today_usecase.dart';
import '../../domain/usecases/habit/get_habit_statistics_usecase.dart';
import '../../domain/usecases/habit/archive_habit_usecase.dart';

// Use Cases - Focus Session
import '../../domain/usecases/focus_session/start_focus_session_usecase.dart';
import '../../domain/usecases/focus_session/pause_focus_session_usecase.dart';
import '../../domain/usecases/focus_session/resume_focus_session_usecase.dart';
import '../../domain/usecases/focus_session/complete_focus_session_usecase.dart';
import '../../domain/usecases/focus_session/cancel_focus_session_usecase.dart';
import '../../domain/usecases/focus_session/get_active_focus_session_usecase.dart';
import '../../domain/usecases/focus_session/get_focus_statistics_usecase.dart';
import '../../domain/usecases/focus_session/get_focus_trends_usecase.dart';
import '../../domain/usecases/focus_session/add_interruption_usecase.dart';
import '../../domain/usecases/focus_session/get_focus_time_by_task_usecase.dart';

// Use Cases - Workspace
import '../../domain/usecases/workspace/create_workspace_usecase.dart';
import '../../domain/usecases/workspace/update_workspace_usecase.dart';
import '../../domain/usecases/workspace/delete_workspace_usecase.dart';
import '../../domain/usecases/workspace/add_member_usecase.dart';
import '../../domain/usecases/workspace/remove_member_usecase.dart';
import '../../domain/usecases/workspace/update_member_role_usecase.dart';
import '../../domain/usecases/workspace/accept_invitation_usecase.dart';
import '../../domain/usecases/workspace/leave_workspace_usecase.dart';
import '../../domain/usecases/workspace/transfer_ownership_usecase.dart';
import '../../domain/usecases/workspace/get_workspace_statistics_usecase.dart';

// Use Cases - Timebox
import '../../domain/usecases/timebox/get_daily_timebox_usecase.dart';
import '../../domain/usecases/timebox/create_timebox_slot_usecase.dart';
import '../../domain/usecases/timebox/update_timebox_slot_usecase.dart';
import '../../domain/usecases/timebox/delete_timebox_slot_usecase.dart';
import '../../domain/usecases/timebox/detect_time_conflicts_usecase.dart';
import '../../domain/usecases/timebox/auto_schedule_tasks_usecase.dart';
import '../../domain/usecases/timebox/reschedule_slot_usecase.dart';
import '../../domain/usecases/timebox/complete_timebox_slot_usecase.dart';

/// Service Locator for Dependency Injection
///
/// This class manages all dependencies for the application using get_it.
/// It follows the Clean Architecture pattern with clear separation of:
/// - External dependencies (Firebase, Isar)
/// - Data sources (Remote and Local)
/// - Repositories
/// - Use Cases
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// This should be called once at app startup before runApp()
///
/// Order of registration:
/// 1. External dependencies (Firebase, Isar)
/// 2. Data sources (Remote and Local)
/// 3. Repositories
/// 4. Use Cases
Future<void> initializeDependencies() async {
  // ===========================
  // External Dependencies
  // ===========================

  // Firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance;

  sl.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);
  sl.registerLazySingleton<FirebaseFirestore>(() => firestore);
  sl.registerLazySingleton<FirebaseStorage>(() => firebaseStorage);

  // Isar database (will be initialized separately)
  // Note: Isar instance must be opened before calling this function
  // The instance should be passed or registered externally

  // ===========================
  // Data Sources - Remote (Firebase)
  // ===========================

  sl.registerLazySingleton<FirebaseAuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<FirebaseTaskRemoteDataSource>(
    () => FirebaseTaskRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseListRemoteDataSource>(
    () => FirebaseListRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseUserRemoteDataSource>(
    () => FirebaseUserRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseTagRemoteDataSource>(
    () => FirebaseTagRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseReminderRemoteDataSource>(
    () => FirebaseReminderRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseCommentRemoteDataSource>(
    () => FirebaseCommentRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseAttachmentRemoteDataSource>(
    () => FirebaseAttachmentRemoteDataSource(
      firestore: sl(),
      storage: sl(),
    ),
  );

  sl.registerLazySingleton<FirebaseHabitRemoteDataSource>(
    () => FirebaseHabitRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseFocusSessionRemoteDataSource>(
    () => FirebaseFocusSessionRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseWorkspaceRemoteDataSource>(
    () => FirebaseWorkspaceRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseTimeboxRemoteDataSource>(
    () => FirebaseTimeboxRemoteDataSourceImpl(firestore: sl()),
  );

  // ===========================
  // Data Sources - Local (Isar)
  // ===========================
  // Note: Isar instance must be registered before these

  sl.registerLazySingleton<IsarUserLocalDataSource>(
    () => IsarUserLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarTaskLocalDataSource>(
    () => IsarTaskLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarListLocalDataSource>(
    () => IsarListLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarTagLocalDataSource>(
    () => IsarTagLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarReminderLocalDataSource>(
    () => IsarReminderLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarCommentLocalDataSource>(
    () => IsarCommentLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarAttachmentLocalDataSource>(
    () => IsarAttachmentLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarHabitLocalDataSource>(
    () => IsarHabitLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarFocusSessionLocalDataSource>(
    () => IsarFocusSessionLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarWorkspaceLocalDataSource>(
    () => IsarWorkspaceLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarActivityLogLocalDataSource>(
    () => IsarActivityLogLocalDataSource(sl<Isar>()),
  );

  sl.registerLazySingleton<IsarTimeboxLocalDataSource>(
    () => IsarTimeboxLocalDataSourceImpl(),
  );

  // ===========================
  // Services
  // ===========================

  sl.registerLazySingleton<TimeboxService>(
    () => TimeboxService(),
  );

  // ===========================
  // Repositories
  // ===========================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ListRepository>(
    () => ListRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<AttachmentRepository>(
    () => AttachmentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<FocusSessionRepository>(
    () => FocusSessionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<TimeboxRepository>(
    () => TimeboxRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      timeboxService: sl(),
    ),
  );

  // ===========================
  // Use Cases - Authentication
  // ===========================

  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithAppleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithMicrosoftUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmailUseCase(sl()));

  // ===========================
  // Use Cases - Task (25 use cases)
  // ===========================

  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetTaskUseCase(sl()));
  sl.registerLazySingleton(() => CompleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => UncompleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksDueTodayUseCase(sl()));
  sl.registerLazySingleton(() => GetOverdueTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetUpcomingTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksByDateRangeUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksByPriorityUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksByTagUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksByListUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignedTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedTasksUseCase(sl()));
  sl.registerLazySingleton(() => SearchTasksUseCase(sl()));
  sl.registerLazySingleton(() => MoveTaskUseCase(sl()));
  sl.registerLazySingleton(() => DuplicateTaskUseCase(sl()));
  sl.registerLazySingleton(() => ArchiveTaskUseCase(sl()));
  sl.registerLazySingleton(() => UnarchiveTaskUseCase(sl()));
  sl.registerLazySingleton(() => AddSubtaskUseCase(sl()));
  sl.registerLazySingleton(() => RemoveSubtaskUseCase(sl()));
  sl.registerLazySingleton(() => AssignTaskUseCase(sl()));
  sl.registerLazySingleton(() => UnassignTaskUseCase(sl()));
  sl.registerLazySingleton(() => BatchCompleteTasksUseCase(sl()));
  sl.registerLazySingleton(() => BatchDeleteTasksUseCase(sl()));

  // ===========================
  // Use Cases - List (10 use cases)
  // ===========================

  sl.registerLazySingleton(() => CreateListUseCase(sl()));
  sl.registerLazySingleton(() => UpdateListUseCase(sl()));
  sl.registerLazySingleton(() => DeleteListUseCase(sl()));
  sl.registerLazySingleton(() => GetListsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteListUseCase(sl()));
  sl.registerLazySingleton(() => ArchiveListUseCase(sl()));
  sl.registerLazySingleton(() => UnarchiveListUseCase(sl()));
  sl.registerLazySingleton(() => ShareListUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteListsUseCase(sl()));
  sl.registerLazySingleton(() => GetSharedListsUseCase(sl()));

  // ===========================
  // Use Cases - User (10 use cases)
  // ===========================

  sl.registerLazySingleton(() => GetUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserPreferencesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => ToggleBiometricAuthUseCase(sl()));
  sl.registerLazySingleton(() => ExportUserDataUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateAccountUseCase(sl()));
  sl.registerLazySingleton(() => ReactivateAccountUseCase(sl()));
  sl.registerLazySingleton(() => UpdateThemeModeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLocaleUseCase(sl()));

  // ===========================
  // Use Cases - Reminder (8 use cases)
  // ===========================

  sl.registerLazySingleton(() => CreateReminderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReminderUseCase(sl()));
  sl.registerLazySingleton(() => EnableReminderUseCase(sl()));
  sl.registerLazySingleton(() => GetRemindersDueSoonUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReminderUseCase(sl()));
  sl.registerLazySingleton(() => SnoozeReminderUseCase(sl()));
  sl.registerLazySingleton(() => MarkReminderTriggeredUseCase(sl()));
  sl.registerLazySingleton(() => DisableReminderUseCase(sl()));

  // ===========================
  // Use Cases - Tag (8 use cases)
  // ===========================

  sl.registerLazySingleton(() => CreateTagUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTagUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTagUseCase(sl()));
  sl.registerLazySingleton(() => GetTagsUseCase(sl()));
  sl.registerLazySingleton(() => GetPopularTagsUseCase(sl()));
  sl.registerLazySingleton(() => MergeTagsUseCase(sl()));
  sl.registerLazySingleton(() => IncrementTagUsageUseCase(sl()));
  sl.registerLazySingleton(() => RestoreTagUseCase(sl()));

  // ===========================
  // Use Cases - Comment (8 use cases)
  // ===========================

  sl.registerLazySingleton(() => CreateCommentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));
  sl.registerLazySingleton(() => AddReactionUseCase(sl()));
  sl.registerLazySingleton(() => RemoveReactionUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentCountUseCase(sl()));
  sl.registerLazySingleton(() => SearchCommentsUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentsWithMentionsUseCase(sl()));

  // ===========================
  // Use Cases - Attachment (8 use cases)
  // ===========================

  sl.registerLazySingleton(() => UploadAttachmentUseCase(sl()));
  sl.registerLazySingleton(() => DownloadAttachmentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAttachmentUseCase(sl()));
  sl.registerLazySingleton(() => GetAttachmentsByTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetAttachmentsByTypeUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalStorageUsedUseCase(sl()));
  sl.registerLazySingleton(() => BatchDeleteAttachmentsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsDownloadedUseCase(sl()));

  // ===========================
  // Use Cases - Habit (10 use cases)
  // ===========================

  sl.registerLazySingleton(() => CreateHabitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHabitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitsUseCase(sl()));
  sl.registerLazySingleton(() => CheckInHabitUseCase(sl()));
  sl.registerLazySingleton(() => UndoCheckInUseCase(sl()));
  sl.registerLazySingleton(() => CalculateStreakUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitsDueTodayUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => ArchiveHabitUseCase(sl()));

  // ===========================
  // Use Cases - Focus Session (10 use cases)
  // ===========================

  sl.registerLazySingleton(() => StartFocusSessionUseCase(sl()));
  sl.registerLazySingleton(() => PauseFocusSessionUseCase(sl()));
  sl.registerLazySingleton(() => ResumeFocusSessionUseCase(sl()));
  sl.registerLazySingleton(() => CompleteFocusSessionUseCase(sl()));
  sl.registerLazySingleton(() => CancelFocusSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveFocusSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetFocusStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetFocusTrendsUseCase(sl()));
  sl.registerLazySingleton(() => AddInterruptionUseCase(sl()));
  sl.registerLazySingleton(() => GetFocusTimeByTaskUseCase(sl()));

  // ===========================
  // Use Cases - Workspace (10 use cases)
  // ===========================

  sl.registerLazySingleton(() => CreateWorkspaceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWorkspaceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWorkspaceUseCase(sl()));
  sl.registerLazySingleton(() => AddMemberUseCase(sl()));
  sl.registerLazySingleton(() => RemoveMemberUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMemberRoleUseCase(sl()));
  sl.registerLazySingleton(() => AcceptInvitationUseCase(sl()));
  sl.registerLazySingleton(() => LeaveWorkspaceUseCase(sl()));
  sl.registerLazySingleton(() => TransferOwnershipUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkspaceStatisticsUseCase(sl()));

  // ===========================
  // Use Cases - Timebox (8 use cases)
  // ===========================

  sl.registerLazySingleton(() => GetDailyTimeboxUseCase(sl()));
  sl.registerLazySingleton(() => CreateTimeboxSlotUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTimeboxSlotUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTimeboxSlotUseCase(sl()));
  sl.registerLazySingleton(() => DetectTimeConflictsUseCase(sl()));
  sl.registerLazySingleton(() => AutoScheduleTasksUseCase(sl()));
  sl.registerLazySingleton(() => RescheduleSlotUseCase(sl()));
  sl.registerLazySingleton(() => CompleteTimeboxSlotUseCase(sl()));
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
