/// Timebox Providers
///
/// Exports all timebox-related state management components.
///
/// Usage:
/// ```dart
/// import 'package:dingdong/presentation/providers/timebox/timebox.dart';
///
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final timeboxState = ref.watch(timeboxNotifierProvider);
///     final personalSlots = ref.watch(personalSlotsProvider);
///     final conflicts = ref.watch(timeboxConflictsProvider);
///
///     // Load today's timebox
///     ref.read(timeboxNotifierProvider.notifier).loadTodayTimebox(userId);
///   }
/// }
/// ```

export 'timebox_state.dart';
export 'timebox_notifier.dart';
export 'timebox_providers.dart';
