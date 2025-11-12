import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/detection_result.dart';
import '../../domain/models/vision_api_error.dart';
import '../state/vision_api_state.dart';

class UploadScreen extends ConsumerWidget {
  final File image;

  const UploadScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visionApiStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Detection'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Error banner placeholder - will be added in step 2
            if (state.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade100,
                child: Text(
                  'Error: ${state.error!.errorMessage}',
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),

            // Image display
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display the captured photo
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),
                      child: Image.file(
                        image,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Loading indicator
                    if (state.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Detecting ingredients...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Detection results
                    if (!state.isLoading && state.detectionResult != null)
                      _buildDetectionResults(state.detectionResult!),

                    // Empty state when no detection yet
                    if (!state.isLoading &&
                        state.detectionResult == null &&
                        state.error == null)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'Tap the button below to detect ingredients',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Action button
            if (!state.isLoading && state.detectionResult == null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _detectIngredients(ref),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Detect Ingredients'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionResults(DetectionResult detectionResult) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detected Ingredients:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (detectionResult.ingredients.isEmpty)
            const Text('No ingredients detected')
          else
            ...detectionResult.ingredients.map((ingredient) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(ingredient.name),
                  subtitle: Text(
                    'Confidence: ${(ingredient.confidence * 100).toStringAsFixed(1)}%',
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: ingredient.confidence > 0.8
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Future<void> _detectIngredients(WidgetRef ref) async {
    final notifier = ref.read(visionApiStateProvider.notifier);
    final client = ref.read(visionApiClientProvider);

    notifier.setLoading(true);
    notifier.clearError();

    try {
      final result = await client.detectIngredients(image);
      notifier.setDetectionResult(result);
    } catch (e) {
      if (e is VisionApiError) {
        notifier.setError(e);
      } else {
        notifier.setError(VisionApiError.unknown('Unexpected error: $e'));
      }
    }
  }
}
