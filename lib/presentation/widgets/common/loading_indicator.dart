import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3.0,
    this.message,
  });

  /// Small loading indicator
  factory LoadingIndicator.small({Color? color}) => LoadingIndicator(
        size: 20,
        strokeWidth: 2,
        color: color,
      );

  /// Medium loading indicator
  factory LoadingIndicator.medium({Color? color, String? message}) =>
      LoadingIndicator(
        size: 36,
        strokeWidth: 3,
        color: color,
        message: message,
      );

  /// Large loading indicator
  factory LoadingIndicator.large({Color? color, String? message}) =>
      LoadingIndicator(
        size: 48,
        strokeWidth: 4,
        color: color,
        message: message,
      );

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 36;
    final effectiveColor = color ?? AppColors.primary;

    if (message == null) {
      return SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          message!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black54
                    : Colors.white70),
            child: Center(
              child: LoadingIndicator.large(message: message),
            ),
          ),
      ],
    );
  }
}

/// Full page loading screen
class LoadingPage extends StatelessWidget {
  final String? message;

  const LoadingPage({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingIndicator.large(message: message ?? 'Loading...'),
      ),
    );
  }
}

/// Shimmer loading placeholder
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor =
        isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer placeholder box
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// Line placeholder
  factory ShimmerBox.line({
    double width = double.infinity,
    double height = 16,
  }) =>
      ShimmerBox(
        width: width,
        height: height,
        borderRadius: AppSpacing.borderRadiusXs,
      );

  /// Circle placeholder
  factory ShimmerBox.circle({double size = 40}) => ShimmerBox(
        width: size,
        height: size,
        borderRadius: AppSpacing.borderRadiusFull,
      );

  /// Card placeholder
  factory ShimmerBox.card({
    double width = double.infinity,
    double height = 100,
  }) =>
      ShimmerBox(
        width: width,
        height: height,
        borderRadius: AppSpacing.borderRadiusMd,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusSm,
        ),
      ),
    );
  }
}

/// Task item shimmer placeholder
class TaskItemShimmer extends StatelessWidget {
  const TaskItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: AppSpacing.listItemPadding,
        child: Row(
          children: [
            ShimmerBox.circle(size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.line(width: double.infinity, height: 16),
                  const SizedBox(height: AppSpacing.xs),
                  ShimmerBox.line(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List shimmer placeholder
class ListShimmer extends StatelessWidget {
  final int itemCount;

  const ListShimmer({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const TaskItemShimmer(),
    );
  }
}
