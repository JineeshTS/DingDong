import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User data model for Firestore serialization
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    required bool emailVerified,
    required String subscriptionTier,
    DateTime? subscriptionExpiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? preferences,
    required bool isActive,
    @Default(false) bool biometricEnabled,
    String? defaultListId,
    @Default('system') String themeMode,
    @Default('en') String locale,
  }) = _UserModel;

  const UserModel._();

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// To entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      emailVerified: emailVerified,
      subscriptionTier: _subscriptionTierFromString(subscriptionTier),
      subscriptionExpiresAt: subscriptionExpiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      preferences: preferences,
      isActive: isActive,
      biometricEnabled: biometricEnabled,
      defaultListId: defaultListId,
      themeMode: _themeModeFromString(themeMode),
      locale: locale,
    );
  }

  /// From entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      emailVerified: entity.emailVerified,
      subscriptionTier: _subscriptionTierToString(entity.subscriptionTier),
      subscriptionExpiresAt: entity.subscriptionExpiresAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      preferences: entity.preferences,
      isActive: entity.isActive,
      biometricEnabled: entity.biometricEnabled,
      defaultListId: entity.defaultListId,
      themeMode: _themeModeToString(entity.themeMode),
      locale: entity.locale,
    );
  }

  /// Helper: Subscription tier to string
  static String _subscriptionTierToString(UserSubscriptionTier tier) {
    switch (tier) {
      case UserSubscriptionTier.free:
        return 'free';
      case UserSubscriptionTier.premiumIndividual:
        return 'premium_individual';
      case UserSubscriptionTier.premiumFamily:
        return 'premium_family';
      case UserSubscriptionTier.teams:
        return 'teams';
      case UserSubscriptionTier.enterprise:
        return 'enterprise';
      case UserSubscriptionTier.lifetime:
        return 'lifetime';
    }
  }

  /// Helper: Subscription tier from string
  static UserSubscriptionTier _subscriptionTierFromString(String tier) {
    switch (tier) {
      case 'free':
        return UserSubscriptionTier.free;
      case 'premium_individual':
        return UserSubscriptionTier.premiumIndividual;
      case 'premium_family':
        return UserSubscriptionTier.premiumFamily;
      case 'teams':
        return UserSubscriptionTier.teams;
      case 'enterprise':
        return UserSubscriptionTier.enterprise;
      case 'lifetime':
        return UserSubscriptionTier.lifetime;
      default:
        return UserSubscriptionTier.free;
    }
  }

  /// Helper: Theme mode to string
  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Helper: Theme mode from string
  static ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
