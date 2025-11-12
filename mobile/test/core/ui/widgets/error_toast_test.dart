import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deedees_food_app/core/ui/widgets/error_toast.dart';

void main() {
  group('ErrorToast', () {
    testWidgets('should display title and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorToast(
              title: 'Test Title',
              message: 'Test Message',
              retryLabel: 'Retry',
              cancelLabel: 'Cancel',
              onRetry: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('should display retry and cancel buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorToast(
              title: 'Test Title',
              message: 'Test Message',
              retryLabel: 'Retry',
              cancelLabel: 'Cancel',
              onRetry: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button tapped', (WidgetTester tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorToast(
              title: 'Test Title',
              message: 'Test Message',
              retryLabel: 'Retry',
              cancelLabel: 'Cancel',
              onRetry: () => retryTapped = true,
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });

    testWidgets('should call onCancel when cancel button tapped', (WidgetTester tester) async {
      var cancelTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorToast(
              title: 'Test Title',
              message: 'Test Message',
              retryLabel: 'Retry',
              cancelLabel: 'Cancel',
              onRetry: () {},
              onCancel: () => cancelTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelTapped, isTrue);
    });

    testWidgets('should disable buttons when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorToast(
              title: 'Test Title',
              message: 'Test Message',
              retryLabel: 'Retry',
              cancelLabel: 'Cancel',
              onRetry: () {},
              onCancel: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      final retryButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Retry').first,
      );
      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Cancel'),
      );

      expect(retryButton.onPressed, isNull);
      expect(cancelButton.onPressed, isNull);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorToast(
              title: 'Test Title',
              message: 'Test Message',
              retryLabel: 'Retry',
              cancelLabel: 'Cancel',
              onRetry: () {},
              onCancel: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('buttons should meet minimum tap target size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorToast(
              title: 'Test Title',
              message: 'Test Message',
              retryLabel: 'Retry',
              cancelLabel: 'Cancel',
              onRetry: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      final retryButtonSize = tester.getSize(find.text('Retry'));
      final cancelButtonSize = tester.getSize(find.text('Cancel'));

      // Check minimum 44x44 tap target (allowing for padding)
      expect(retryButtonSize.height, greaterThanOrEqualTo(44));
      expect(cancelButtonSize.height, greaterThanOrEqualTo(44));
    });
  });
}
