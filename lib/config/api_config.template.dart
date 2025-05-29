class ApiConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );

  static const String nutritionixAppId = String.fromEnvironment(
    'NUTRITIONIX_APP_ID',
    defaultValue: 'YOUR_NUTRITIONIX_APP_ID',
  );

  static const String nutritionixApiKey = String.fromEnvironment(
    'NUTRITIONIX_API_KEY',
    defaultValue: 'YOUR_NUTRITIONIX_API_KEY',
  );
} 