import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Utility class for hashing user IDs to protect PII in logs and analytics.
///
/// Uses SHA-256 one-way hashing to ensure user privacy while maintaining
/// the ability to correlate events by user.
class UserIdHasher {
  /// Hashes a user ID using SHA-256.
  ///
  /// Returns 'anonymous' if the userId is null or empty.
  static String hashUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      return 'anonymous';
    }

    final bytes = utf8.encode(userId);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Gets the hashed user ID for the currently authenticated user.
  ///
  /// Returns 'anonymous' if no user is currently authenticated.
  static String getCurrentUserIdHash() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'anonymous';
    }
    return hashUserId(user.uid);
  }
}
