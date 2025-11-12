import 'package:flutter_test/flutter_test.dart';
import 'package:deedees_food_app/features/ingredient_upload/presentation/controllers/vision_api_retry_controller.dart';

void main() {
  group('VisionApiRetryController', () {
    test('maxAttempts should be 5', () {
      expect(VisionApiRetryController.maxAttempts, 5);
    });

    test('retryDelays should have correct exponential back-off values', () {
      expect(VisionApiRetryController.retryDelays, [0, 1, 2, 4, 8, 16]);
    });

    test('retryDelays should start with 0 for initial attempt', () {
      expect(VisionApiRetryController.retryDelays[0], 0);
    });

    test('retryDelays should have exponential progression', () {
      final delays = VisionApiRetryController.retryDelays;

      // Skip first element (0) and check exponential pattern
      for (var i = 2; i < delays.length; i++) {
        expect(delays[i], delays[i - 1] * 2);
      }
    });

    test('retryDelays length should support maxAttempts', () {
      // Need delays for: initial (0) + maxAttempts retries (5)
      expect(
        VisionApiRetryController.retryDelays.length,
        greaterThanOrEqualTo(VisionApiRetryController.maxAttempts + 1),
      );
    });
  });

  group('VisionApiRetryController constants', () {
    test('delay progression follows 2^n pattern', () {
      final delays = VisionApiRetryController.retryDelays;

      // Verify: 1, 2, 4, 8, 16 follows 2^0, 2^1, 2^2, 2^3, 2^4
      expect(delays[1], 1); // 2^0
      expect(delays[2], 2); // 2^1
      expect(delays[3], 4); // 2^2
      expect(delays[4], 8); // 2^3
      expect(delays[5], 16); // 2^4
    });
  });
}
