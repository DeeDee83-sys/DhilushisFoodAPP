class ApiConfig {
  // TODO: Replace with actual environment-based configuration
  static const String aiServiceBaseUrl =
      String.fromEnvironment('AI_SERVICE_URL', defaultValue: 'http://localhost:8000');

  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
}
