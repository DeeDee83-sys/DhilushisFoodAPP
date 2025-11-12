import 'package:freezed_annotation/freezed_annotation.dart';

part 'vision_api_error.freezed.dart';

enum VisionApiErrorType {
  network,
  http,
  malformed,
  throttling,
  timeout,
  cancelled,
  unknown,
}

@freezed
class VisionApiError with _$VisionApiError {
  const factory VisionApiError({
    required VisionApiErrorType errorType,
    required String errorMessage,
    int? statusCode,
    String? traceId,
  }) = _VisionApiError;

  const VisionApiError._();

  factory VisionApiError.network(String message) => VisionApiError(
        errorType: VisionApiErrorType.network,
        errorMessage: message,
      );

  factory VisionApiError.http(int statusCode, String message, {String? traceId}) =>
      VisionApiError(
        errorType: statusCode == 429
            ? VisionApiErrorType.throttling
            : VisionApiErrorType.http,
        errorMessage: message,
        statusCode: statusCode,
        traceId: traceId,
      );

  factory VisionApiError.malformed(String message) => VisionApiError(
        errorType: VisionApiErrorType.malformed,
        errorMessage: message,
      );

  factory VisionApiError.timeout(String message) => VisionApiError(
        errorType: VisionApiErrorType.timeout,
        errorMessage: message,
      );

  factory VisionApiError.cancelled() => const VisionApiError(
        errorType: VisionApiErrorType.cancelled,
        errorMessage: 'Request cancelled by user',
      );

  factory VisionApiError.unknown(String message) => VisionApiError(
        errorType: VisionApiErrorType.unknown,
        errorMessage: message,
      );
}
