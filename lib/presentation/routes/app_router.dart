import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme/design_system.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/tasks/task_list_screen.dart';
import 'main_scaffold.dart';

/// App router configuration using GoRouter with authentication
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authState.stream),

    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // Home/Tasks tab
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const TaskListScreen(),
            ),
            routes: [
              // Task detail
              GoRoute(
                path: 'task/:id',
                name: 'task-detail',
                builder: (context, state) {
                  final taskId = state.pathParameters['id']!;
                  return _TaskDetailPlaceholder(taskId: taskId);
                },
              ),
              // Create task
              GoRoute(
                path: 'create',
                name: 'create-task',
                builder: (context, state) => const _CreateTaskPlaceholder(),
              ),
            ],
          ),

          // Calendar tab
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const _CalendarPlaceholder(),
            ),
          ),

          // Kanban tab
          GoRoute(
            path: '/kanban',
            name: 'kanban',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const _KanbanPlaceholder(),
            ),
          ),

          // Focus tab
          GoRoute(
            path: '/focus',
            name: 'focus',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const _FocusPlaceholder(),
            ),
          ),

          // Profile/Settings tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const _ProfilePlaceholder(),
            ),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppSpacing.iconXXL,
                color: AppColors.error,
              ),
              AppSpacing.verticalSpaceMD,
              Text(
                'Page not found',
                style: AppTypography.headlineMedium,
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                state.uri.toString(),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceXL,
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),

    // Redirect logic for authentication
    redirect: (context, state) {
      final isAuthenticated = authState.value?.when(
            data: (user) => user != null,
            loading: () => false,
            error: (_, __) => false,
          ) ??
          false;

      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      final isOnSplash = state.matchedLocation == '/';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // Allow splash screen always
      if (isOnSplash) {
        return null;
      }

      // If not authenticated and not on auth pages, redirect to login
      if (!isAuthenticated && !isOnAuthPage && !isOnOnboarding) {
        return '/login';
      }

      // If authenticated and on auth pages, redirect to home
      if (isAuthenticated && isOnAuthPage) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
  );
});

/// Helper to make GoRouter refresh on auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Placeholder screens for tabs (to be implemented)
class _CalendarPlaceholder extends StatelessWidget {
  const _CalendarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: AppSpacing.iconXXL,
            color: AppColors.gray400,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Calendar View',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanPlaceholder extends StatelessWidget {
  const _KanbanPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_kanban,
            size: AppSpacing.iconXXL,
            color: AppColors.gray400,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Kanban Board',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusPlaceholder extends StatelessWidget {
  const _FocusPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: AppSpacing.iconXXL,
            color: AppColors.gray400,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Focus Mode',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: AppSpacing.iconXXL,
            color: AppColors.gray400,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Profile & Settings',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskDetailPlaceholder extends StatelessWidget {
  const _TaskDetailPlaceholder({required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task,
              size: AppSpacing.iconXXL,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'Task: $taskId',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              'Detail view coming soon',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTaskPlaceholder extends StatelessWidget {
  const _CreateTaskPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_task,
              size: AppSpacing.iconXXL,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'Create Task',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              'Form coming soon',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
