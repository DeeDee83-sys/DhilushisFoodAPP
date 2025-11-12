# DeeDee's Food App - Mobile

Flutter mobile application for DeeDee's Food App.

## Overview

This is the mobile frontend for DeeDee's Food App, built with Flutter 3.x and Dart 3.x. The app helps users simplify meal planning and grocery shopping by detecting ingredients from photos and generating recipe suggestions.

## Architecture

The project follows a feature-based architecture with clean architecture principles:

```
lib/
  features/
    <feature>/
      data/         # API clients, data sources
      domain/       # Models, use cases
      presentation/ # Widgets, pages, state
  core/
    network/        # HTTP clients, API configuration
    ui/             # Shared UI components, theme
    utils/          # Utilities and helpers
```

## Tech Stack

- **Flutter**: 3.x
- **Dart**: 3.x
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Navigation**: go_router
- **Code Generation**: freezed, json_serializable, riverpod_generator
- **Linting**: flutter_lints

## Setup

1. Install Flutter 3.x or later
2. Install dependencies:
   ```
   flutter pub get
   ```

3. Generate localization files:
   ```
   flutter gen-l10n
   ```

4. Generate code:
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```
   flutter run
   ```

## Code Generation

This project uses code generation for:
- Riverpod providers
- Freezed models
- JSON serialization
- Localization (i18n)

To generate localization files:
```
flutter gen-l10n
```

To generate code after making changes:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

To watch for changes:
```
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Localization

The app supports internationalization using Flutter's built-in localization system.

To add a new language:
1. Create a new ARB file in `lib/l10n/` (e.g., `app_es.arb` for Spanish)
2. Copy the structure from `app_en.arb` and translate the values
3. Run `flutter gen-l10n` to generate the localization classes
4. The app will automatically support the new locale

## Environment Configuration

The app uses environment variables for configuration:
- `AI_SERVICE_URL`: Base URL for the AI service (default: http://localhost:8000)
- `API_BASE_URL`: Base URL for the backend API (default: http://localhost:3000)

## Features

### Ingredient Upload
- Capture or upload fridge/pantry photos
- AI-powered ingredient detection using Google Cloud Vision API
- Error handling with retry logic
- Real-time detection results

## Development Guidelines

Follow the code guidelines in `/home/claude/files/code-guidelines.md`:
- Use `dart format` for formatting
- Follow `flutter_lints` rules
- Use camelCase for variables and functions
- Use PascalCase for classes and types
- Minimum 70% test coverage for critical paths
- Accessibility: 44x44px tap targets, semantic labels

## Testing

Run tests:
```
flutter test
```

Run tests with coverage:
```
flutter test --coverage
```

## License

Proprietary - DeeDee's Food App
