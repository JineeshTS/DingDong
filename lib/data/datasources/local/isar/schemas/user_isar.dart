import 'package:isar/isar.dart';

part 'user_isar.g.dart';

/// Isar collection for User entity (local storage)
@collection
class UserIsar {
  /// Unique identifier (Isar auto-generates if not set)
  Id id = Isar.autoIncrement;

  /// Firebase user ID (indexed for quick lookup)
  @Index(unique: true)
  late String userId;

  /// User email
  @Index()
  late String email;

  /// Display name
  String? displayName;

  /// Profile photo URL
  String? photoUrl;

  /// Phone number
  String? phoneNumber;

  /// Subscription tier (free, premium, business)
  @Index()
  @Enumerated(EnumType.name)
  late UserSubscriptionTierIsar subscriptionTier;

  /// Subscription expiration date
  DateTime? subscriptionExpiresAt;

  /// Whether subscription is active
  bool isSubscriptionActive = true;

  /// Theme mode (system, light, dark)
  @Enumerated(EnumType.name)
  late ThemeModeIsar themeMode;

  /// Locale/language code
  String locale = 'en';

  /// Biometric authentication enabled
  bool biometricEnabled = false;

  /// Default list ID
  String? defaultListId;

  /// User preferences (stored as JSON string)
  String? preferencesJson;

  /// Account active status
  bool isActive = true;

  /// Email verified status
  bool emailVerified = false;

  /// Account creation timestamp
  late DateTime createdAt;

  /// Last update timestamp
  late DateTime updatedAt;

  /// Last login timestamp
  DateTime? lastLoginAt;

  /// Account deactivation timestamp
  DateTime? deactivatedAt;

  /// Last sync timestamp with server
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync to server)
  bool isDirty = false;

  /// Deleted flag (soft delete)
  bool isDeleted = false;
}

/// Subscription tier enum for Isar
enum UserSubscriptionTierIsar {
  free,
  premium,
  business,
}

/// Theme mode enum for Isar
enum ThemeModeIsar {
  system,
  light,
  dark,
}
