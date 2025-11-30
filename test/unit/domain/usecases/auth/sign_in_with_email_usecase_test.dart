import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dingdong/core/errors/failures.dart';
import 'package:dingdong/domain/entities/user_entity.dart';
import 'package:dingdong/domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../../../mocks/mock_repositories.dart';

void main() {
  late SignInWithEmailUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithEmailUseCase(mockAuthRepository);
  });

  tearDown(() {
    mockAuthRepository.reset();
  });

  group('SignInWithEmailUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'Password123!';

    group('Success Cases', () {
      test('should return UserEntity when sign in is successful', () async {
        // Arrange
        mockAuthRepository.setShouldFail(false);

        // Act
        final result = await usecase(SignInWithEmailParams(
          email: testEmail,
          password: testPassword,
        ));

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (user) {
            expect(user, isA<UserEntity>());
            expect(user.email, testEmail);
          },
        );
      });

      test('should set user as current user after successful sign in',
          () async {
        // Arrange
        mockAuthRepository.setShouldFail(false);

        // Act
        await usecase(SignInWithEmailParams(
          email: testEmail,
          password: testPassword,
        ));

        // Assert
        final currentUserResult = await mockAuthRepository.getCurrentUser();
        expect(currentUserResult.isRight(), isTrue);
        currentUserResult.fold(
          (failure) => fail('Expected Right but got Left'),
          (user) {
            expect(user, isNotNull);
            expect(user!.email, testEmail);
          },
        );
      });
    });

    group('Failure Cases', () {
      test('should return AuthenticationFailure when credentials are invalid',
          () async {
        // Arrange
        mockAuthRepository.setShouldFail(
          true,
          failure: AuthenticationFailure('Invalid credentials'),
        );

        // Act
        final result = await usecase(SignInWithEmailParams(
          email: testEmail,
          password: 'wrong_password',
        ));

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AuthenticationFailure>());
            expect(failure.message, 'Invalid credentials');
          },
          (user) => fail('Expected Left but got Right'),
        );
      });

      test('should return NetworkFailure when network is unavailable',
          () async {
        // Arrange
        mockAuthRepository.setShouldFail(
          true,
          failure: NetworkFailure('No internet connection'),
        );

        // Act
        final result = await usecase(SignInWithEmailParams(
          email: testEmail,
          password: testPassword,
        ));

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
          },
          (user) => fail('Expected Left but got Right'),
        );
      });

      test('should return ServerFailure when server error occurs', () async {
        // Arrange
        mockAuthRepository.setShouldFail(
          true,
          failure: ServerFailure('Internal server error'),
        );

        // Act
        final result = await usecase(SignInWithEmailParams(
          email: testEmail,
          password: testPassword,
        ));

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
          },
          (user) => fail('Expected Left but got Right'),
        );
      });
    });

    group('Validation', () {
      test('should accept valid email format', () async {
        // Arrange
        mockAuthRepository.setShouldFail(false);
        const validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@email.com',
        ];

        // Act & Assert
        for (final email in validEmails) {
          final result = await usecase(SignInWithEmailParams(
            email: email,
            password: testPassword,
          ));
          expect(result.isRight(), isTrue, reason: 'Failed for email: $email');
        }
      });
    });

    group('Edge Cases', () {
      test('should handle email with leading/trailing whitespace', () async {
        // Arrange
        mockAuthRepository.setShouldFail(false);

        // Act
        final result = await usecase(SignInWithEmailParams(
          email: '  test@example.com  ',
          password: testPassword,
        ));

        // Assert - Use case should handle trimming
        expect(result.isRight(), isTrue);
      });

      test('should handle empty password', () async {
        // Arrange
        mockAuthRepository.setShouldFail(
          true,
          failure: ValidationFailure('Password cannot be empty'),
        );

        // Act
        final result = await usecase(SignInWithEmailParams(
          email: testEmail,
          password: '',
        ));

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });
  });

  group('SignInWithEmailParams', () {
    test('should create params with email and password', () {
      final params = SignInWithEmailParams(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(params.email, 'test@example.com');
      expect(params.password, 'password123');
    });

    test('should be equal when properties match', () {
      final params1 = SignInWithEmailParams(
        email: 'test@example.com',
        password: 'password123',
      );

      final params2 = SignInWithEmailParams(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(params1, equals(params2));
    });

    test('should not be equal when email differs', () {
      final params1 = SignInWithEmailParams(
        email: 'test1@example.com',
        password: 'password123',
      );

      final params2 = SignInWithEmailParams(
        email: 'test2@example.com',
        password: 'password123',
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}
