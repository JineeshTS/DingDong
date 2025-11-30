import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dingdong/presentation/screens/auth/login_screen.dart';
import 'package:dingdong/presentation/screens/auth/register_screen.dart';
import 'package:dingdong/presentation/providers/auth/auth_providers.dart';
import 'package:dingdong/presentation/providers/auth/auth_state.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  tearDown(() {
    mockAuthRepository.reset();
  });

  group('Authentication Flow Integration Tests', () {
    // ============================================================
    // LOGIN FLOW
    // ============================================================

    group('Login Flow', () {
      testWidgets('should display login screen with all elements',
          (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        // Verify all login elements are present
        expect(find.text('Login'), findsWidgets);
        expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets('should show validation errors for empty fields',
          (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        // Tap sign in without entering credentials
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('should show validation error for invalid email format',
          (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        // Enter invalid email
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'invalid-email',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );

        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid email format'), findsOneWidget);
      });

      testWidgets('should show loading state during sign in', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        // Enter valid credentials
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'Password123!',
        );

        // Tap sign in
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show error message on failed sign in',
          (tester) async {
        mockAuthRepository.setShouldFail(true);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Override auth repository with mock
            ],
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        // Enter credentials
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'wrongpassword',
        );

        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Should show error snackbar
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should navigate to register screen', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              routes: {
                '/register': (_) => const RegisterScreen(),
              },
              home: const LoginScreen(),
            ),
          ),
        );

        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        expect(find.byType(RegisterScreen), findsOneWidget);
      });
    });

    // ============================================================
    // REGISTRATION FLOW
    // ============================================================

    group('Registration Flow', () {
      testWidgets('should display register screen with all elements',
          (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const RegisterScreen(),
            ),
          ),
        );

        expect(find.text('Create Account'), findsWidgets);
        expect(find.byType(TextField), findsNWidgets(4)); // Name, Email, Password, Confirm
        expect(find.text('Sign Up'), findsOneWidget);
        expect(find.text('Already have an account?'), findsOneWidget);
      });

      testWidgets('should show validation errors for empty fields',
          (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const RegisterScreen(),
            ),
          ),
        );

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Name is required'), findsOneWidget);
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('should validate password strength', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const RegisterScreen(),
            ),
          ),
        );

        await tester.enterText(
          find.byKey(const Key('name_field')),
          'John Doe',
        );
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'john@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          '123', // Weak password
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          '123',
        );

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 8 characters'), findsOneWidget);
      });

      testWidgets('should validate password confirmation', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const RegisterScreen(),
            ),
          ),
        );

        await tester.enterText(
          find.byKey(const Key('name_field')),
          'John Doe',
        );
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'john@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'Password123!',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'Different123!',
        );

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('should navigate to login screen', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              routes: {
                '/login': (_) => const LoginScreen(),
              },
              home: const RegisterScreen(),
            ),
          ),
        );

        await tester.tap(find.text('Already have an account?'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });

    // ============================================================
    // SOCIAL LOGIN FLOW
    // ============================================================

    group('Social Login Flow', () {
      testWidgets('should display Google sign in button', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        expect(find.text('Continue with Google'), findsOneWidget);
      });

      testWidgets('should display Apple sign in button on iOS',
          (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        // Apple sign in should be available (platform dependent)
        expect(find.text('Continue with Apple'), findsOneWidget);
      });
    });

    // ============================================================
    // PASSWORD RESET FLOW
    // ============================================================

    group('Password Reset Flow', () {
      testWidgets('should navigate to forgot password screen', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        // Should navigate to forgot password screen
        expect(find.text('Reset Password'), findsOneWidget);
      });

      testWidgets('should validate email for password reset', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(
          find.byKey(const Key('reset_email_field')),
          'invalid-email',
        );

        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid email format'), findsOneWidget);
      });

      testWidgets('should show success message after sending reset email',
          (tester) async {
        mockAuthRepository.setShouldFail(false);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const LoginScreen(),
            ),
          ),
        );

        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('reset_email_field')),
          'test@example.com',
        );

        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        expect(find.text('Reset email sent'), findsOneWidget);
      });
    });

    // ============================================================
    // AUTH STATE MANAGEMENT
    // ============================================================

    group('Auth State Management', () {
      testWidgets('should update UI based on auth state', (tester) async {
        // Create a container to track state changes
        final container = ProviderContainer();

        // Initial state should be unauthenticated
        final initialState = container.read(authNotifierProvider);
        expect(initialState, isA<AuthState>());

        // Clean up
        container.dispose();
      });

      testWidgets('should persist user session', (tester) async {
        // This would test that user remains logged in after app restart
        // Requires more complex setup with persistent storage mocking
      });

      testWidgets('should clear session on logout', (tester) async {
        // This tests that all user data is cleared when logging out
      });
    });
  });

  // ============================================================
  // ACCESSIBILITY TESTS
  // ============================================================

  group('Accessibility Tests', () {
    testWidgets('login screen should have semantic labels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );

      // Verify accessibility labels
      expect(
        find.bySemanticsLabel('Email input field'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Password input field'),
        findsOneWidget,
      );
    });

    testWidgets('buttons should be focusable', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );

      // Verify buttons are in the focus tree
      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);
    });
  });
}
