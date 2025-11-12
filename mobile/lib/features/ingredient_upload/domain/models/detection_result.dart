import 'package:freezed_annotation/freezed_annotation.dart';

part 'detection_result.freezed.dart';
part 'detection_result.g.dart';

@freezed
class DetectionResult with _$DetectionResult {
  const factory DetectionResult({
    required List<DetectedIngredient> ingredients,
    required String requestId,
    required DateTime timestamp,
  }) = _DetectionResult;

  factory DetectionResult.fromJson(Map<String, dynamic> json) =>
      _$DetectionResultFromJson(json);
}

@freezed
class DetectedIngredient with _$DetectedIngredient {
  const factory DetectedIngredient({
    required String name,
    required double confidence,
    String? category,
    Map<String, dynamic>? metadata,
  }) = _DetectedIngredient;

  factory DetectedIngredient.fromJson(Map<String, dynamic> json) =>
      _$DetectedIngredientFromJson(json);
}
