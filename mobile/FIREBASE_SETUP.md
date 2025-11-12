# Firebase Configuration for Vision API Logging and Analytics

This document describes the Firebase setup required for the Vision API error handling feature.

## Prerequisites

- Firebase project created and linked to the app
- Firebase SDK initialized in the app (done in main.dart)

## Required Firebase Services

### 1. Cloud Firestore (for Structured Logging)

**Collection Setup:**
- Collection name: `vision_api_logs`
- Documents are auto-generated with structured log data

**Indexes Required:**
Create these composite indexes in Firestore:
1. Collection: `vision_api_logs`
   - Field: `timestamp` (Descending)

2. Collection: `vision_api_logs`
   - Field: `errorType` (Ascending)
   - Field: `timestamp` (Descending)

3. Collection: `vision_api_logs`
   - Field: `hashedUserId` (Ascending)
   - Field: `timestamp` (Descending)

**Security Rules:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /vision_api_logs/{document} {
      // Allow authenticated users to write logs
      allow create: if request.auth != null;

      // Only admins can read logs
      allow read: if false; // Set up admin role if needed

      // No updates or deletes allowed
      allow update, delete: if false;
    }
  }
}
```

**Data Retention:**
Set up a Cloud Function or scheduled job to delete logs older than 30 days for compliance.

### 2. Firebase Analytics

**Custom Events:**
The following custom events are logged:
1. `VisionAPIFailure`
   - Parameters: hashedUserId, timestamp, errorType, errorMessage, retryAttempt

2. `VisionAPIRetry`
   - Parameters: hashedUserId, timestamp, errorType, errorMessage, retryAttempt

3. `VisionAPICancel`
   - Parameters: hashedUserId, timestamp, retryAttempt

**Setup:**
No additional setup required. Events are automatically tracked once Firebase Analytics is enabled.

### 3. Firebase Remote Config

**Parameter Setup:**

1. Go to Firebase Console > Remote Config
2. Add a new parameter:
   - **Key:** `visionErrorBannerEnabled`
   - **Data type:** Boolean
   - **Default value:** `false`
   - **Description:** Controls visibility of vision API error banner

**Canary Rollout (10%):**

1. Create a condition:
   - **Name:** `canary_10_percent`
   - **Rule:** User in random percentile <= 10

2. Apply to parameter:
   - **Parameter:** `visionErrorBannerEnabled`
   - **Condition:** `canary_10_percent`
   - **Value:** `true`
   - **Default value (no conditions):** `false`

**Gradual Rollout Plan:**
- Week 1: 10% rollout (canary)
- Week 2: 25% rollout (if no issues)
- Week 3: 50% rollout
- Week 4: 100% rollout

## Security and Privacy

### PII Protection
- User IDs are hashed using SHA-256 before logging
- No raw user data, images, or file paths are logged
- Error messages are sanitized and truncated
- All data transmission uses TLS (automatic via Firebase)

### Data Minimization
- Only essential fields are logged
- No auth tokens or session data in logs
- Error messages limited to 500 characters (logs) / 100 characters (analytics)

## Testing

### Local Testing
1. Run the app in debug mode
2. Trigger a Vision API error
3. Check console logs for structured logging output
4. Verify no PII is logged

### Remote Config Testing
1. Set `visionErrorBannerEnabled` to `true` in Firebase Console
2. Force fetch remote config (or wait for automatic fetch)
3. Trigger an error - banner should appear
4. Set flag to `false` - banner should not appear

### Analytics Testing
1. Enable debug mode for Firebase Analytics
2. Trigger error, retry, and cancel flows
3. Use Firebase DebugView to verify events are sent
4. Verify event parameters are correct

## Build Runner

After making changes to provider files, run:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates the `.g.dart` files for Riverpod providers.

## Monitoring

### Firestore Logs
Query examples:
```
// Get all errors in the last 24 hours
WHERE timestamp >= (current_time - 24h)
ORDER BY timestamp DESC

// Get all errors for a specific error type
WHERE errorType == 'network'
ORDER BY timestamp DESC

// Get all retries for a user
WHERE hashedUserId == '<hash>' AND eventType == 'retry'
ORDER BY timestamp DESC
```

### Analytics
Use Firebase Analytics dashboard to:
- Track VisionAPIFailure rate over time
- Monitor retry success rate
- Identify most common error types
- Track cancellation rate

## Troubleshooting

### Logs not appearing in Firestore
- Check Firebase initialization in main.dart
- Verify Firestore security rules allow writes
- Check network connectivity
- Look for errors in console logs

### Analytics events not showing
- Wait up to 24 hours for events to appear in console
- Use Firebase DebugView for real-time testing
- Verify Firebase Analytics is enabled in Firebase Console

### Remote config not working
- Check initialization in main.dart
- Verify fetch is completing successfully
- Check for network errors
- Verify parameter name matches exactly: `visionErrorBannerEnabled`
