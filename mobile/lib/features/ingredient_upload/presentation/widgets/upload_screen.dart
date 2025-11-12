import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/models/detection_result.dart';
import '../../domain/models/vision_api_error.dart';
import '../state/vision_api_state.dart';
import '../controllers/vision_api_retry_controller.dart';
import '../../../../core/ui/widgets/error_toast.dart';

class UploadScreen extends ConsumerStatefulWidget {
  final File image;

  const UploadScreen({
    super.key,
    required this.image,
  });

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  OverlayEntry? _errorOverlayEntry;
  VisionApiError? _currentError;

  @override
  void dispose() {
    _removeErrorOverlay();
    super.dispose();
  }

  void _showErrorOverlay(BuildContext context, VisionApiError error) {
    // Remove existing overlay if present
    _removeErrorOverlay();

    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(visionApiStateProvider);

    _errorOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: ErrorToast(
              title: l10n.detectionErrorTitle,
              message: l10n.detectionErrorMessage,
              retryLabel: l10n.retryLabel,
              cancelLabel: l10n.cancelLabel,
              isLoading: state.isLoading,
              onRetry: () => _handleRetry(),
              onCancel: () => _handleCancel(),
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_errorOverlayEntry!);
    _currentError = error;
  }

  void _removeErrorOverlay() {
    _errorOverlayEntry?.remove();
    _errorOverlayEntry = null;
    _currentError = null;
  }

  void _updateErrorOverlay(BuildContext context) {
    if (_errorOverlayEntry != null) {
      // Force rebuild of overlay
      _errorOverlayEntry!.markNeedsBuild();
    }
  }

  Future<void> _handleRetry() async {
    // Update overlay to show loading state immediately
    if (mounted) {
      _updateErrorOverlay(context);
    }

    // Use retry controller with exponential back-off
    final controller = ref.read(visionApiRetryControllerProvider);
    await controller.retry(widget.image);

    // Overlay updates are handled automatically via state watching
    // Success removes overlay, failure updates it with new error
  }

  void _handleCancel() {
    final notifier = ref.read(visionApiStateProvider.notifier);
    notifier.clearError();
    notifier.resetRetryAttempt();
    _removeErrorOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visionApiStateProvider);

    // Manage error overlay based on state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (state.error != null && _currentError != state.error) {
          _showErrorOverlay(context, state.error!);
        } else if (state.error == null && _errorOverlayEntry != null) {
          _removeErrorOverlay();
        } else if (state.error != null && _errorOverlayEntry != null) {
          // Update existing overlay if loading state changed
          _updateErrorOverlay(context);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Detection'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                        widget.image,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Loading indicator
                    if (state.isLoading && state.error == null)
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
                  onPressed: () => _detectIngredients(),
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

  Future<void> _detectIngredients() async {
    // Use retry controller for initial detection
    final controller = ref.read(visionApiRetryControllerProvider);
    await controller.detectIngredients(widget.image);
  }
}
