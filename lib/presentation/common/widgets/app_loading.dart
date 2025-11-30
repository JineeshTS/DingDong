import 'package:flutter/material.dart';
import '../../../config/theme/design_system.dart';

/// Loading indicator variants
enum AppLoadingSize {
  small,
  medium,
  large,
}

/// Loading indicator component
class AppLoading extends StatelessWidget {
  const AppLoading({
    Key? key,
    this.size = AppLoadingSize.medium,
    this.color,
    this.strokeWidth,
  }) : super(key: key);

  final AppLoadingSize size;
  final Color? color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    double dimension;
    double effectiveStrokeWidth;

    switch (size) {
      case AppLoadingSize.small:
        dimension = AppSpacing.iconSM;
        effectiveStrokeWidth = strokeWidth ?? 2.0;
        break;
      case AppLoadingSize.medium:
        dimension = AppSpacing.iconMD;
        effectiveStrokeWidth = strokeWidth ?? 3.0;
        break;
      case AppLoadingSize.large:
        dimension = AppSpacing.iconLG;
        effectiveStrokeWidth = strokeWidth ?? 4.0;
        break;
    }

    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: effectiveStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Full screen loading overlay
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    Key? key,
    this.message,
    this.backgroundColor,
  }) : super(key: key);

  final String? message;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.scrim,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoading(size: AppLoadingSize.large),
            if (message != null) ...[
              AppSpacing.verticalSpaceMD,
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator for lists (centered with padding)
class AppListLoading extends StatelessWidget {
  const AppListLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoading(),
            if (message != null) ...[
              AppSpacing.verticalSpaceMD,
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading effect for skeleton screens
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  final Widget child;
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationSlow * 3,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                AppColors.gray300,
                AppColors.gray200,
                AppColors.gray300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
