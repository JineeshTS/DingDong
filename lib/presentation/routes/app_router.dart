import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth/auth_providers.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/tasks/task_list_screen.dart';

/// App router configuration using GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(ref),
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

      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const TaskListScreen(),
      ),

      // Task routes
      // TODO: Add task detail, create, edit routes

      // Calendar routes
      // TODO: Add calendar routes

      // Kanban routes
      // TODO: Add kanban routes

      // Focus routes
      // TODO: Add focus/pomodoro routes

      // Habits routes
      // TODO: Add habit tracker routes

      // Analytics routes
      // TODO: Add analytics routes

      // Settings routes
      // TODO: Add settings routes
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The page "${state.uri.path}" doesn\'t exist.',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),

    // Redirect logic
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      final isSplash = state.matchedLocation == '/';

      // Allow splash screen to handle initial navigation
      if (isSplash) return null;

      // If not authenticated and not on auth pages, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // If authenticated and on auth pages, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
  );
});

/// GoRouter refresh stream that listens to auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(this.ref) {
    ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
}
