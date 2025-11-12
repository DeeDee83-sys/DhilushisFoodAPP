import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_config_service.g.dart';

/// Service for managing Firebase Remote Config flags.
///
/// Handles initialization, fetching, and reading of remote configuration values.
/// Falls back to safe defaults if fetch fails or config is not initialized.
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  /// Initializes Remote Config with default values and fetches latest config.
  ///
  /// Sets up defaults and attempts to fetch the latest configuration from Firebase.
  /// If fetch fails, the service continues with default values.
  /// This method is safe to call multiple times - it will only initialize once.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      // Set default values - these are used if fetch fails or until first fetch completes
      await _remoteConfig.setDefaults({
        'visionErrorBannerEnabled': false,
      });

      // Configure settings - fetch timeout and minimum fetch interval
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Fetch and activate the latest config
      await _remoteConfig.fetchAndActivate();

      _initialized = true;

      if (kDebugMode) {
        print('[RemoteConfig] Initialized successfully');
        print(
          '[RemoteConfig] visionErrorBannerEnabled: '
          '${_remoteConfig.getBool('visionErrorBannerEnabled')}',
        );
      }
    } catch (e) {
      // If initialization fails, we continue with defaults
      // This ensures the app doesn't break due to remote config issues
      _initialized = true; // Mark as initialized to prevent retry loops

      if (kDebugMode) {
        print('[RemoteConfig] Failed to fetch config, using defaults: $e');
      }
    }
  }

  /// Checks if the vision error banner should be displayed.
  ///
  /// Returns the value of the 'visionErrorBannerEnabled' flag.
  /// If remote config is not initialized or fetch failed, returns false (safe default).
  ///
  /// This method reads from a cached value, so it's fast and synchronous.
  bool isVisionErrorBannerEnabled() {
    if (!_initialized) {
      // Return safe default if not initialized
      return false;
    }

    return _remoteConfig.getBool('visionErrorBannerEnabled');
  }

  /// Gets the current initialization status
  bool get isInitialized => _initialized;
}

/// Provider for RemoteConfigService singleton
@riverpod
RemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) {
  return RemoteConfigService();
}
