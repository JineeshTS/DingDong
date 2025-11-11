import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for updating user subscription
class UpdateSubscriptionUseCase {
  final UserRepository repository;

  UpdateSubscriptionUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    required String subscriptionTier,
    DateTime? expiresAt,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate subscription tier
    final validTiers = ['free', 'plus', 'premium'];
    if (!validTiers.contains(subscriptionTier.toLowerCase())) {
      return Left(ValidationFailure(
          message: 'Invalid subscription tier. Must be: free, plus, or premium'));
    }

    // Validate expiry date for paid tiers
    if (subscriptionTier != 'free' && expiresAt == null) {
      return Left(ValidationFailure(
          message: 'Expiry date required for paid subscriptions'));
    }

    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      return Left(ValidationFailure(
          message: 'Expiry date cannot be in the past'));
    }

    return await repository.updateSubscription(
      userId: userId,
      subscriptionTier: subscriptionTier,
      expiresAt: expiresAt,
    );
  }
}
