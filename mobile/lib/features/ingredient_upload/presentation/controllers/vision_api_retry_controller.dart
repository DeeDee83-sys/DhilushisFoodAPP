import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/detection_result.dart';
import '../../domain/models/vision_api_error.dart';
import '../../data/vision_api_client.dart';
import '../state/vision_api_state.dart';

part 'vision_api_retry_controller.g.dart';

/// Controller that manages Vision API calls with exponential back-off retry logic.
///
/// Implements retry delays: 1s, 2s, 4s, 8s, 16s with maximum 5 attempts per image.
class VisionApiRetryController {
  final Ref _ref;

  /// Maximum number of retry attempts allowed per image
  static const int maxAttempts = 5;

  /// Exponential back-off delays in seconds for each retry attempt
  /// Index 0 = initial attempt (no delay)
  /// Index 1 = 1st retry (1s delay)
  /// Index 2 = 2nd retry (2s delay)
  /// Index 3 = 3rd retry (4s delay)
  /// Index 4 = 4th retry (8s delay)
  /// Index 5 = 5th retry (16s delay)
  static const List<int> retryDelays = [0, 1, 2, 4, 8, 16];

  bool _isProcessing = false;

  VisionApiRetryController(this._ref);

  /// Initiates ingredient detection for the given image (initial attempt).
  ///
  /// This is called when the user first uploads an image or taps
  /// the initial "Detect Ingredients" button.
  Future<void> detectIngredients(File image) async {
    if (_isProcessing) {
      if (kDebugMode) {
        print('Detection already in progress, ignoring request');
      }
      return;
    }

    _isProcessing = true;

    try {
      final stateNotifier = _ref.read(visionApiStateProvider.notifier);
      final client = _ref.read(visionApiClientProvider);

      // Set initial state
      stateNotifier.setImage(image);
      stateNotifier.setLoading(true);
      stateNotifier.clearError();
      stateNotifier.resetRetryAttempt();

      if (kDebugMode) {
        print('Starting ingredient detection');
      }

      // Make API call
      final result = await client.detectIngredients(image);

      // Success - update state
      stateNotifier.setDetectionResult(result);
      stateNotifier.resetRetryAttempt();

      if (kDebugMode) {
        print('Detection successful: ${result.ingredients.length} ingredients');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isProcessing = false;
    }
  }

  /// Retries ingredient detection with exponential back-off.
  ///
  /// Implements delays based on the current retry attempt count:
  /// - 1st retry: 1 second delay
  /// - 2nd retry: 2 second delay
  /// - 3rd retry: 4 second delay
  /// - 4th retry: 8 second delay
  /// - 5th retry: 16 second delay
  ///
  /// Maximum 5 retry attempts per image.
  Future<void> retry(File image) async {
    if (_isProcessing) {
      if (kDebugMode) {
        print('Retry already in progress, ignoring request');
      }
      return;
    }

    final currentState = _ref.read(visionApiStateProvider);
    final currentAttempt = currentState.retryAttempt;

    // Check if max attempts reached
    if (currentAttempt >= maxAttempts) {
      if (kDebugMode) {
        print('Max retry attempts ($maxAttempts) reached');
      }
      final stateNotifier = _ref.read(visionApiStateProvider.notifier);
      stateNotifier.setError(
        VisionApiError.unknown(
          'Maximum retry attempts reached. Please try again later.',
        ),
      );
      return;
    }

    _isProcessing = true;

    try {
      final stateNotifier = _ref.read(visionApiStateProvider.notifier);

      // Increment attempt count before delay
      stateNotifier.incrementRetryAttempt();
      final attemptNumber = currentAttempt + 1;

      // Calculate and apply exponential back-off delay
      final delay = _getDelay(attemptNumber);

      if (kDebugMode) {
        print('Retry attempt $attemptNumber/$maxAttempts after ${delay.inSeconds}s delay');
      }

      // Set loading state before delay
      stateNotifier.setLoading(true);

      // Wait for back-off delay
      await Future.delayed(delay);

      // Make API call
      final client = _ref.read(visionApiClientProvider);
      final result = await client.detectIngredients(image);

      // Success - clear error and reset retry count
      stateNotifier.setDetectionResult(result);
      stateNotifier.resetRetryAttempt();

      if (kDebugMode) {
        print('Retry successful on attempt $attemptNumber');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isProcessing = false;
    }
  }

  /// Checks if retry is allowed based on current attempt count.
  bool canRetry() {
    final currentState = _ref.read(visionApiStateProvider);
    return currentState.retryAttempt < maxAttempts;
  }

  /// Calculates the delay duration for the given retry attempt.
  ///
  /// Uses exponential back-off: 1s, 2s, 4s, 8s, 16s
  Duration _getDelay(int attempt) {
    if (attempt <= 0 || attempt >= retryDelays.length) {
      return Duration(seconds: retryDelays.last);
    }
    return Duration(seconds: retryDelays[attempt]);
  }

  /// Handles errors from Vision API calls.
  void _handleError(Object error) {
    final stateNotifier = _ref.read(visionApiStateProvider.notifier);

    if (error is VisionApiError) {
      stateNotifier.setError(error);
      if (kDebugMode) {
        print('Vision API error: ${error.errorType} - ${error.errorMessage}');
      }
    } else {
      final unknownError = VisionApiError.unknown('Unexpected error: $error');
      stateNotifier.setError(unknownError);
      if (kDebugMode) {
        print('Unexpected error: $error');
      }
    }
  }
}

/// Provider for the VisionApiRetryController.
@riverpod
VisionApiRetryController visionApiRetryController(
  VisionApiRetryControllerRef ref,
) {
  return VisionApiRetryController(ref);
}
