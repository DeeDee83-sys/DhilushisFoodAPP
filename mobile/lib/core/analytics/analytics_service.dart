import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// Analytics service for tracking Vision API events.
///
/// Emits structured analytics events to Firebase Analytics.
/// All events are sent over TLS (automatic via Firebase) and exclude PII.
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  static const int _maxErrorMessageLength = 100;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Logs a VisionAPIFailure event when initial detection or retry fails.
  ///
  /// Parameters:
  /// - [hashedUserId]: SHA-256 hashed user ID
  /// - [errorType]: Type of error (network, http, timeout, etc.)
  /// - [errorMessage]: Sanitized error message (truncated to 100 chars)
  /// - [retryAttempt]: Current retry attempt number
  Future<void> logVisionAPIFailure({
    required String hashedUserId,
    required String errorType,
    required String errorMessage,
    required int retryAttempt,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'VisionAPIFailure',
        parameters: {
          'hashedUserId': hashedUserId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'errorType': errorType,
          'errorMessage': _truncateMessage(errorMessage),
          'retryAttempt': retryAttempt,
        },
      );

      if (kDebugMode) {
        print(
          '[Analytics] VisionAPIFailure: '
          'errorType=$errorType, attempt=$retryAttempt',
        );
      }
    } catch (e) {
      // Never throw - analytics failures should not break the app
      if (kDebugMode) {
        print('Failed to log VisionAPIFailure analytics: $e');
      }
    }
  }

  /// Logs a VisionAPIRetry event when user retries after a failure.
  ///
  /// Parameters:
  /// - [hashedUserId]: SHA-256 hashed user ID
  /// - [errorType]: Type of error that triggered the retry
  /// - [errorMessage]: Sanitized error message
  /// - [retryAttempt]: Current retry attempt number
  Future<void> logVisionAPIRetry({
    required String hashedUserId,
    required String errorType,
    required String errorMessage,
    required int retryAttempt,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'VisionAPIRetry',
        parameters: {
          'hashedUserId': hashedUserId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'errorType': errorType,
          'errorMessage': _truncateMessage(errorMessage),
          'retryAttempt': retryAttempt,
        },
      );

      if (kDebugMode) {
        print(
          '[Analytics] VisionAPIRetry: '
          'errorType=$errorType, attempt=$retryAttempt',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log VisionAPIRetry analytics: $e');
      }
    }
  }

  /// Logs a VisionAPICancel event when user cancels an in-flight request.
  ///
  /// Parameters:
  /// - [hashedUserId]: SHA-256 hashed user ID
  /// - [retryAttempt]: Current retry attempt number when cancelled
  Future<void> logVisionAPICancel({
    required String hashedUserId,
    required int retryAttempt,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'VisionAPICancel',
        parameters: {
          'hashedUserId': hashedUserId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'retryAttempt': retryAttempt,
        },
      );

      if (kDebugMode) {
        print('[Analytics] VisionAPICancel: attempt=$retryAttempt');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log VisionAPICancel analytics: $e');
      }
    }
  }

  /// Truncates error message to max length for analytics
  String _truncateMessage(String message) {
    if (message.length > _maxErrorMessageLength) {
      return message.substring(0, _maxErrorMessageLength);
    }
    return message;
  }
}

/// Provider for AnalyticsService singleton
@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return AnalyticsService();
}
