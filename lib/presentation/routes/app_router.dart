import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../providers/auth/auth.dart';

/// App router configuration using GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for router redirects
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _AuthStateNotifier(ref),
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

      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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
              state.error.toString(),
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

    // Redirect logic based on authentication
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;

      // List of public routes that don't require authentication
      final publicRoutes = ['/', '/login', '/register'];
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Don't redirect while loading
      if (isLoading) {
        return null;
      }

      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // If authenticated and on auth pages, redirect to home
      if (isAuthenticated && (state.matchedLocation == '/login' ||
          state.matchedLocation == '/register')) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
  );
});

/// Helper class to notify router of auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  final Ref ref;

  _AuthStateNotifier(this.ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }
}
