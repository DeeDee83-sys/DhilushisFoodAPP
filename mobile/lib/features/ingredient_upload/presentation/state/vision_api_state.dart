import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/detection_result.dart';
import '../../domain/models/vision_api_error.dart';
import '../../data/vision_api_client.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_config.dart';

part 'vision_api_state.g.dart';

class VisionApiStateData {
  final File? image;
  final DetectionResult? detectionResult;
  final VisionApiError? error;
  final int retryAttempt;
  final bool isLoading;

  const VisionApiStateData({
    this.image,
    this.detectionResult,
    this.error,
    this.retryAttempt = 0,
    this.isLoading = false,
  });

  VisionApiStateData copyWith({
    File? image,
    DetectionResult? detectionResult,
    VisionApiError? error,
    int? retryAttempt,
    bool? isLoading,
  }) {
    return VisionApiStateData(
      image: image ?? this.image,
      detectionResult: detectionResult ?? this.detectionResult,
      error: error ?? this.error,
      retryAttempt: retryAttempt ?? this.retryAttempt,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  VisionApiStateData clearError() {
    return VisionApiStateData(
      image: image,
      detectionResult: detectionResult,
      error: null,
      retryAttempt: retryAttempt,
      isLoading: isLoading,
    );
  }

  VisionApiStateData clearDetectionResult() {
    return VisionApiStateData(
      image: image,
      detectionResult: null,
      error: error,
      retryAttempt: retryAttempt,
      isLoading: isLoading,
    );
  }
}

@riverpod
class VisionApiState extends _$VisionApiState {
  @override
  VisionApiStateData build() {
    return const VisionApiStateData();
  }

  void setImage(File image) {
    state = VisionApiStateData(
      image: image,
      detectionResult: null,
      error: null,
      retryAttempt: 0,
      isLoading: false,
    );
  }

  void setDetectionResult(DetectionResult result) {
    state = state.copyWith(
      detectionResult: result,
      error: null,
      isLoading: false,
    );
  }

  void setError(VisionApiError error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
    );
  }

  void incrementRetryAttempt() {
    state = state.copyWith(
      retryAttempt: state.retryAttempt + 1,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(
      isLoading: loading,
    );
  }

  void clearError() {
    state = state.clearError();
  }

  void reset() {
    state = const VisionApiStateData();
  }

  void resetRetryAttempt() {
    state = state.copyWith(retryAttempt: 0);
  }
}

@riverpod
VisionApiClient visionApiClient(VisionApiClientRef ref) {
  final dio = DioClient.createDio(
    baseUrl: ApiConfig.aiServiceBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  );

  return VisionApiClient(dio);
}
