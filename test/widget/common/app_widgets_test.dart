import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dingdong/presentation/common/widgets/widgets.dart';
import 'package:dingdong/config/theme/design_system.dart';
import '../../helpers/test_helpers.dart';

void main() {
  // ============================================================
  // APP BUTTON TESTS
  // ============================================================

  group('AppButton Widget', () {
    testWidgets('should render with text', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          child: const Text('Click Me'),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () => wasPressed = true,
          child: const Text('Tap Me'),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppButton(
          onPressed: null,
          child: Text('Disabled'),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          isLoading: true,
          child: const Text('Loading'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not be tappable when loading', (tester) async {
      bool wasPressed = false;

      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () => wasPressed = true,
          isLoading: true,
          child: const Text('Loading'),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('should render with icon', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          icon: Icons.add,
          child: const Text('Add'),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should respect button variants', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton.outlined(
          onPressed: () {},
          child: const Text('Outlined'),
        ),
      );

      expect(find.text('Outlined'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render text button variant', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton.text(
          onPressed: () {},
          child: const Text('Text Button'),
        ),
      );

      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  // ============================================================
  // APP TEXT FIELD TESTS
  // ============================================================

  group('AppTextField Widget', () {
    testWidgets('should render with label', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          label: 'Email',
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should render with hint', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          hint: 'Enter your email',
        ),
      );

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      final controller = TextEditingController();

      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppTextField(
          controller: controller,
          label: 'Name',
        ),
      );

      await tester.enterText(find.byType(TextField), 'John Doe');
      expect(controller.text, 'John Doe');
    });

    testWidgets('should call onChanged when text changes', (tester) async {
      String? changedValue;

      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppTextField(
          label: 'Name',
          onChanged: (value) => changedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextField), 'Jane');
      expect(changedValue, 'Jane');
    });

    testWidgets('should show error text', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          label: 'Email',
          errorText: 'Invalid email format',
        ),
      );

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('should show prefix icon', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          label: 'Email',
          prefixIcon: Icons.email,
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should show suffix icon', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          label: 'Search',
          suffixIcon: Icons.search,
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          label: 'Disabled Field',
          enabled: false,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should handle maxLines', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          label: 'Description',
          maxLines: 5,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 5);
    });

    testWidgets('should obscure text when obscureText is true', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppTextField(
          label: 'Password',
          obscureText: true,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });
  });

  // ============================================================
  // APP PASSWORD FIELD TESTS
  // ============================================================

  group('AppPasswordField Widget', () {
    testWidgets('should render with label', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppPasswordField(
          label: 'Password',
        ),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should toggle visibility when icon is tapped', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppPasswordField(
          label: 'Password',
        ),
      );

      // Initially obscured
      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      // Tap visibility icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visible
      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });

    testWidgets('should show error text', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppPasswordField(
          label: 'Password',
          errorText: 'Password too short',
        ),
      );

      expect(find.text('Password too short'), findsOneWidget);
    });
  });

  // ============================================================
  // APP CARD TESTS
  // ============================================================

  group('AppCard Widget', () {
    testWidgets('should render child content', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppCard(
          child: Text('Card Content'),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('should be tappable when onTap is provided', (tester) async {
      bool wasTapped = false;

      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppCard(
          onTap: () => wasTapped = true,
          child: const Text('Tap Card'),
        ),
      );

      await tester.tap(find.text('Tap Card'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should apply custom padding', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppCard(
          padding: EdgeInsets.all(24),
          child: Text('Padded Content'),
        ),
      );

      final paddingWidget = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Padded Content'),
          matching: find.byType(Padding),
        ).first,
      );

      expect(paddingWidget.padding, const EdgeInsets.all(24));
    });
  });

  // ============================================================
  // APP LOADING TESTS
  // ============================================================

  group('AppLoading Widget', () {
    testWidgets('should render circular progress indicator', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppLoading(),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render with message', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppLoading(
          message: 'Loading tasks...',
        ),
      );

      expect(find.text('Loading tasks...'), findsOneWidget);
    });

    testWidgets('should center content', (tester) async {
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppLoading(),
      );

      expect(find.byType(Center), findsWidgets);
    });
  });

  // ============================================================
  // QUICK ADD TASK DIALOG TESTS
  // ============================================================

  group('QuickAddTaskDialog Widget', () {
    testWidgets('should render task title field', (tester) async {
      await TestHelpers.pumpProviderScope(
        tester,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const QuickAddTaskDialog(),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should have add button', (tester) async {
      await TestHelpers.pumpProviderScope(
        tester,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const QuickAddTaskDialog(),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should have cancel button', (tester) async {
      await TestHelpers.pumpProviderScope(
        tester,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const QuickAddTaskDialog(),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should close when cancel is tapped', (tester) async {
      await TestHelpers.pumpProviderScope(
        tester,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const QuickAddTaskDialog(),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(QuickAddTaskDialog), findsNothing);
    });
  });

  // ============================================================
  // DESIGN SYSTEM TESTS
  // ============================================================

  group('Design System', () {
    group('AppColors', () {
      test('should have primary color defined', () {
        expect(AppColors.primary, isNotNull);
      });

      test('should have error color defined', () {
        expect(AppColors.error, isNotNull);
      });

      test('should have background color defined', () {
        expect(AppColors.background, isNotNull);
      });
    });

    group('AppTypography', () {
      test('should have headline styles defined', () {
        expect(AppTypography.headlineLarge, isNotNull);
        expect(AppTypography.headlineMedium, isNotNull);
        expect(AppTypography.headlineSmall, isNotNull);
      });

      test('should have body styles defined', () {
        expect(AppTypography.bodyLarge, isNotNull);
        expect(AppTypography.bodyMedium, isNotNull);
        expect(AppTypography.bodySmall, isNotNull);
      });
    });

    group('AppSpacing', () {
      test('should have spacing constants defined', () {
        expect(AppSpacing.xs, isNotNull);
        expect(AppSpacing.sm, isNotNull);
        expect(AppSpacing.md, isNotNull);
        expect(AppSpacing.lg, isNotNull);
        expect(AppSpacing.xl, isNotNull);
      });

      test('should have page padding defined', () {
        expect(AppSpacing.pagePadding, isNotNull);
      });
    });
  });
}
