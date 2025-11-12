import 'dart:io';

import 'package:dio/dio.dart';
import '../domain/models/detection_result.dart';
import '../domain/models/vision_api_error.dart';

class VisionApiClient {
  final Dio _dio;

  VisionApiClient(this._dio);

  /// Detects ingredients from an image using the Vision API
  ///
  /// Throws [VisionApiError] on failure
  Future<DetectionResult> detectIngredients(
    File image, {
    CancelToken? cancelToken,
  }) async {
    try {
      // Prepare multipart form data
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      // Make API request
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/vision/detect-ingredients',
        data: formData,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Parse response
      if (response.data == null) {
        throw VisionApiError.malformed('Empty response from server');
      }

      try {
        return DetectionResult.fromJson(response.data!);
      } catch (e) {
        throw VisionApiError.malformed('Failed to parse response: $e');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw VisionApiError.unknown('Unexpected error: $e');
    }
  }

  VisionApiError _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return VisionApiError.timeout(
          'Request timed out. Please check your connection.',
        );

      case DioExceptionType.cancel:
        return VisionApiError.cancelled();

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final traceId = exception.response?.headers.value('x-trace-id');

        if (statusCode == null) {
          return VisionApiError.http(
            0,
            'Bad response from server',
            traceId: traceId,
          );
        }

        String message = 'Server error occurred';

        // Try to extract error message from response
        if (exception.response?.data is Map) {
          final data = exception.response?.data as Map<String, dynamic>?;
          message = data?['message'] ?? data?['error'] ?? message;
        }

        return VisionApiError.http(
          statusCode,
          message,
          traceId: traceId,
        );

      case DioExceptionType.connectionError:
        return VisionApiError.network(
          'Network connection failed. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return VisionApiError.network('SSL certificate verification failed');

      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return VisionApiError.network(
            'Network error: ${exception.error}',
          );
        }
        return VisionApiError.unknown(
          'Unknown error occurred: ${exception.message}',
        );
    }
  }
}
