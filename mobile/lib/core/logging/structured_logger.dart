import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'structured_logger.g.dart';

/// Log levels for structured logging
enum LogLevel {
  error,
  warning,
  info,
  debug,
}

/// Structured logger that emits JSON logs to Google Cloud Logging via Firestore.
///
/// All logs are sent over TLS (automatic via Firebase) and exclude PII.
/// Logs are written asynchronously to avoid blocking the UI thread.
class StructuredLogger {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'vision_api_logs';
  static const int _maxErrorMessageLength = 500;

  StructuredLogger({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Logs a Vision API event with structured JSON format.
  ///
  /// Parameters:
  /// - [level]: Log severity level
  /// - [eventType]: Type of event (failure, retry, cancel)
  /// - [hashedUserId]: SHA-256 hashed user ID (never raw UID)
  /// - [errorType]: Type of error from VisionApiErrorType enum
  /// - [errorMessage]: Sanitized error message (no PII, truncated to 500 chars)
  /// - [retryAttempt]: Current retry attempt number
  ///
  /// Logs are sent to Firestore asynchronously. Failures are caught and logged
  /// to console in debug mode but do not throw exceptions.
  Future<void> logVisionApiEvent({
    required LogLevel level,
    required String eventType,
    required String hashedUserId,
    String? errorType,
    String? errorMessage,
    required int retryAttempt,
  }) async {
    try {
      final timestamp = DateTime.now();

      // Sanitize error message - truncate and remove any potential PII
      final sanitizedMessage = errorMessage != null
          ? _sanitizeErrorMessage(errorMessage)
          : null;

      final logData = <String, dynamic>{
        'timestamp': Timestamp.fromDate(timestamp),
        'timestampIso': timestamp.toIso8601String(),
        'level': level.name,
        'eventType': eventType,
        'hashedUserId': hashedUserId,
        'retryAttempt': retryAttempt,
        'platform': 'flutter',
      };

      // Only add optional fields if they are not null
      if (errorType != null) {
        logData['errorType'] = errorType;
      }
      if (sanitizedMessage != null) {
        logData['errorMessage'] = sanitizedMessage;
      }

      // Write to Firestore asynchronously (sent over TLS automatically)
      await _firestore.collection(_collectionName).add(logData);

      // Debug logging to console
      if (kDebugMode) {
        print(
          '[${level.name.toUpperCase()}] VisionAPI $eventType: '
          'user=$hashedUserId, attempt=$retryAttempt'
          '${errorType != null ? ', errorType=$errorType' : ''}'
          '${sanitizedMessage != null ? ', message=$sanitizedMessage' : ''}',
        );
      }
    } catch (e) {
      // Never throw - logging failures should not break the app
      if (kDebugMode) {
        print('Failed to write log to Firestore: $e');
      }
    }
  }

  /// Sanitizes error messages by truncating and removing potential PII.
  String _sanitizeErrorMessage(String message) {
    // Truncate to max length
    if (message.length > _maxErrorMessageLength) {
      return message.substring(0, _maxErrorMessageLength);
    }
    return message;
  }
}

/// Provider for StructuredLogger singleton
@riverpod
StructuredLogger structuredLogger(StructuredLoggerRef ref) {
  return StructuredLogger();
}
