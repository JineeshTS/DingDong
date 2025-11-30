import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme/design_system.dart';

/// Main scaffold with bottom navigation for the app
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNavigation(),
      floatingActionButton: _shouldShowFAB(context)
          ? FloatingActionButton(
              onPressed: () => context.push('/home/create'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  bool _shouldShowFAB(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // Show FAB on home and calendar tabs
    return location.startsWith('/home') || location.startsWith('/calendar');
  }
}

/// Bottom navigation bar
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return NavigationBar(
      selectedIndex: _calculateSelectedIndex(location),
      onDestinationSelected: (index) => _onItemTapped(index, context),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Tasks',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.view_kanban_outlined),
          selectedIcon: Icon(Icons.view_kanban),
          label: 'Kanban',
        ),
        NavigationDestination(
          icon: Icon(Icons.timer_outlined),
          selectedIcon: Icon(Icons.timer),
          label: 'Focus',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/kanban')) return 2;
    if (location.startsWith('/focus')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/kanban');
        break;
      case 3:
        context.go('/focus');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

/// Responsive main scaffold that adapts to different screen sizes
class ResponsiveMainScaffold extends StatelessWidget {
  const ResponsiveMainScaffold({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Use side navigation for tablet and desktop
    if (width >= AppConstants.tabletBreakpoint) {
      return Row(
        children: [
          const _SideNavigation(),
          Expanded(child: child),
        ],
      );
    }

    // Use bottom navigation for mobile
    return MainScaffold(child: child);
  }
}

/// Side navigation for tablet and desktop
class _SideNavigation extends StatelessWidget {
  const _SideNavigation();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return NavigationRail(
      selectedIndex: _calculateSelectedIndex(location),
      onDestinationSelected: (index) => _onItemTapped(index, context),
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: AppSpacing.paddingMD,
        child: Icon(
          Icons.task_alt,
          size: AppSpacing.iconLG,
          color: AppColors.primary,
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Tasks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.view_kanban_outlined),
          selectedIcon: Icon(Icons.view_kanban),
          label: Text('Kanban'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.timer_outlined),
          selectedIcon: Icon(Icons.timer),
          label: Text('Focus'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/kanban')) return 2;
    if (location.startsWith('/focus')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/kanban');
        break;
      case 3:
        context.go('/focus');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
