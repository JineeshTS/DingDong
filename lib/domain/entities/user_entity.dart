import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final UserSubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  final bool isActive;
  final bool biometricEnabled;
  final String? defaultListId;
  final ThemeMode themeMode;
  final String locale;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.emailVerified,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    required this.isActive,
    this.biometricEnabled = false,
    this.defaultListId,
    this.themeMode = ThemeMode.system,
    this.locale = 'en',
  });

  /// Check if user is premium
  bool get isPremium =>
      subscriptionTier == UserSubscriptionTier.premiumIndividual ||
      subscriptionTier == UserSubscriptionTier.premiumFamily ||
      subscriptionTier == UserSubscriptionTier.teams ||
      subscriptionTier == UserSubscriptionTier.enterprise ||
      subscriptionTier == UserSubscriptionTier.lifetime;

  /// Check if subscription is active
  bool get isSubscriptionActive {
    if (subscriptionTier == UserSubscriptionTier.free ||
        subscriptionTier == UserSubscriptionTier.lifetime) {
      return true;
    }
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  /// Copy with method for immutability
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    UserSubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    bool? isActive,
    bool? biometricEnabled,
    String? defaultListId,
    ThemeMode? themeMode,
    String? locale,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      defaultListId: defaultListId ?? this.defaultListId,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        phoneNumber,
        emailVerified,
        subscriptionTier,
        subscriptionExpiresAt,
        createdAt,
        updatedAt,
        preferences,
        isActive,
        biometricEnabled,
        defaultListId,
        themeMode,
        locale,
      ];
}

/// User subscription tiers
enum UserSubscriptionTier {
  free,
  premiumIndividual,
  premiumFamily,
  teams,
  enterprise,
  lifetime,
}

/// Theme mode enum
enum ThemeMode {
  light,
  dark,
  system,
}
