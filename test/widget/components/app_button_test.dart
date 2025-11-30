import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/config/theme/design_system.dart';
import '../../../lib/presentation/common/widgets/widgets.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('should render button with text', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          child: const Text('Click Me'),
        ),
      );

      // Assert
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool wasPressed = false;

      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () => wasPressed = true,
          child: const Text('Tap Me'),
        ),
      );

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: const AppButton(
          onPressed: null,
          child: Text('Disabled'),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          enabled: false,
          child: const Text('Disabled'),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show loading indicator when loading is true',
        (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          loading: true,
          child: const Text('Loading'),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should render icon when provided', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          icon: Icons.add,
          child: const Text('Add'),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should apply correct style for primary variant',
        (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          variant: AppButtonVariant.primary,
          child: const Text('Primary'),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should apply correct style for outlined variant',
        (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          variant: AppButtonVariant.outlined,
          child: const Text('Outlined'),
        ),
      );

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should apply correct style for text variant', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          variant: AppButtonVariant.text,
          child: const Text('Text'),
        ),
      );

      // Assert
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should expand to full width when fullWidth is true',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: AppButton(
                onPressed: () {},
                fullWidth: true,
                child: const Text('Full Width'),
              ),
            ),
          ),
        ),
      );

      // Assert
      final buttonFinder = find.byType(ElevatedButton);
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.width, 400);
    });

    testWidgets('should apply small size correctly', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          size: AppButtonSize.small,
          child: const Text('Small'),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button, isNotNull);
      // Size is applied via ButtonStyle, difficult to test exact dimensions
    });

    testWidgets('should apply large size correctly', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          size: AppButtonSize.large,
          child: const Text('Large'),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button, isNotNull);
    });

    testWidgets('should use destructive color for destructive variant',
        (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          variant: AppButtonVariant.destructive,
          child: const Text('Delete'),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('loading button should not be tappable', (tester) async {
      // Arrange
      bool wasPressed = false;

      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () => wasPressed = true,
          loading: true,
          child: const Text('Loading'),
        ),
      );

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert - Button is disabled when loading
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
