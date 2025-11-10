import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

/// Firebase authentication remote data source
///
/// Handles all Firebase Authentication operations
abstract class FirebaseAuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Sign in with Microsoft
  Future<UserModel> signInWithMicrosoft();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Get current user ID
  Future<String?> getCurrentUserId();

  /// Listen to auth state changes
  Stream<UserModel?> get authStateChanges;

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email});

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Update password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Update email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  });

  /// Update profile
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Delete account
  Future<void> deleteAccount({required String password});

  /// Re-authenticate user
  Future<void> reauthenticate({required String password});

  /// Check if email is available
  Future<bool> isEmailAvailable({required String email});
}

/// Firebase authentication remote data source implementation
class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthenticationException(
          message: 'Sign in failed. User is null.',
        );
      }

      return await _getUserModel(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during sign in.',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthenticationException(
          message: 'Sign up failed. User is null.',
        );
      }

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final now = DateTime.now();
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        emailVerified: false,
        subscriptionTier: 'free',
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during sign up.',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthenticationException(
          message: 'Google sign in was cancelled.',
        );
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthenticationException(
          message: 'Google sign in failed. User is null.',
        );
      }

      // Check if user document exists, create if not
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final now = DateTime.now();
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          emailVerified: userCredential.user!.emailVerified,
          subscriptionTier: 'free',
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      }

      return await _getUserModel(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during Google sign in.',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw const AuthenticationException(
          message: 'Apple sign in failed. User is null.',
        );
      }

      // Check if user document exists, create if not
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final now = DateTime.now();
        final displayName = appleCredential.givenName != null &&
                appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : userCredential.user!.displayName;

        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? appleCredential.email ?? '',
          displayName: displayName,
          emailVerified: userCredential.user!.emailVerified,
          subscriptionTier: 'free',
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      }

      return await _getUserModel(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during Apple sign in.',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> signInWithMicrosoft() async {
    try {
      // Create Microsoft provider
      final microsoftProvider = OAuthProvider('microsoft.com');

      // Sign in with popup/redirect
      final userCredential =
          await _firebaseAuth.signInWithProvider(microsoftProvider);

      if (userCredential.user == null) {
        throw const AuthenticationException(
          message: 'Microsoft sign in failed. User is null.',
        );
      }

      // Check if user document exists, create if not
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final now = DateTime.now();
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          emailVerified: userCredential.user!.emailVerified,
          subscriptionTier: 'free',
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      }

      return await _getUserModel(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during Microsoft sign in.',
        originalException: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to sign out.',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await _getUserModel(user);
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to get current user.',
        originalException: e,
      );
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserModel(user);
    });
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }

      // Re-authenticate
      await reauthenticate(password: currentPassword);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }

      // Re-authenticate
      await reauthenticate(password: password);

      // Update email
      await user.verifyBeforeUpdateEmail(newEmail);

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await _getUserModel(user);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }

      // Re-authenticate
      await reauthenticate(password: password);

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user from Firebase Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthenticationException(
          message: 'No user is currently signed in.',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<bool> isEmailAvailable({required String email}) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isEmpty;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalException: e,
      );
    }
  }

  /// Get user model from Firebase user and Firestore
  Future<UserModel> _getUserModel(User user) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        final now = DateTime.now();
        final userModel = UserModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
          emailVerified: user.emailVerified,
          subscriptionTier: 'free',
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      }

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get user data from Firestore.',
        originalException: e,
      );
    }
  }

  /// Get user-friendly error message from Firebase error code
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
