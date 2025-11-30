import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../common/widgets/widgets.dart';

/// Onboarding screen to welcome new users
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.task_alt,
      title: 'Welcome to DingDong',
      description:
          'The next-generation task management app designed to boost your productivity and keep you organized.',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.calendar_today,
      title: 'Stay Organized',
      description:
          'Organize your tasks with lists, tags, priorities, and smart views. Never miss a deadline again.',
      color: AppColors.secondary,
    ),
    OnboardingPage(
      icon: Icons.people,
      title: 'Collaborate Seamlessly',
      description:
          'Share tasks and lists with your team. Work together efficiently with real-time updates.',
      color: AppColors.accent,
    ),
    OnboardingPage(
      icon: Icons.bolt,
      title: 'Boost Productivity',
      description:
          'Track habits, use focus sessions, and leverage AI-powered features to get more done.',
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _handleNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationNormal,
        curve: AppConstants.emphasizedCurve,
      );
    } else {
      _handleGetStarted();
    }
  }

  void _handleSkip() {
    _handleGetStarted();
  }

  void _handleGetStarted() {
    // Navigate to home
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: AppButton(
                    onPressed: _handleSkip,
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                    child: const Text('Skip'),
                  ),
                ),
              )
            else
              SizedBox(height: AppConstants.appBarHeight),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageView(page: _pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: AppSpacing.verticalSpaceMD,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _PageIndicator(
                    isActive: index == _currentPage,
                    color: _pages[index].color,
                  ),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: AppSpacing.paddingMD.copyWith(
                top: AppSpacing.xs,
                bottom: AppSpacing.xl,
              ),
              child: AppButton(
                onPressed: _handleNext,
                fullWidth: true,
                child: Text(
                  _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual onboarding page view
class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: AppSpacing.paddingXXL,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: AppSpacing.iconXXL + 32,
              color: page.color,
            ),
          ),
          AppSpacing.verticalSpaceXXL,

          // Title
          Text(
            page.title,
            style: AppTypography.displaySmall.copyWith(
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceMD,

          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.gray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Page indicator dot
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.isActive,
    required this.color,
  });

  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animationFast,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      height: isActive ? AppSpacing.xs : AppSpacing.xxs + 2,
      width: isActive ? AppSpacing.xl : AppSpacing.xs,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.gray300,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
      ),
    );
  }
}

/// Onboarding page data model
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
