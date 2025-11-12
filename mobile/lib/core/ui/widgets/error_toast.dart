import 'package:flutter/material.dart';

class ErrorToast extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final String cancelLabel;
  final VoidCallback onRetry;
  final VoidCallback onCancel;
  final bool isLoading;

  const ErrorToast({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.cancelLabel,
    required this.onRetry,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // WCAG AA compliant colors
    const backgroundColor = Color(0xFFFEEBEE); // Red 50 equivalent
    const titleColor = Color(0xFFB71C1C); // Red 900
    const messageColor = Color(0xFF424242); // Grey 800
    const buttonColor = Color(0xFFD32F2F); // Red 700

    return Material(
      elevation: 4,
      color: backgroundColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with semantic header
            Semantics(
              header: true,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: messageColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                Semantics(
                  button: true,
                  label: cancelLabel,
                  enabled: !isLoading,
                  child: SizedBox(
                    height: 44,
                    child: TextButton(
                      onPressed: isLoading ? null : onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(cancelLabel),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Retry button
                Semantics(
                  button: true,
                  label: retryLabel,
                  enabled: !isLoading,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        minimumSize: const Size(44, 44),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(retryLabel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
