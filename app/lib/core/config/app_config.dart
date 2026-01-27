/// LiftIQ - App Configuration
///
/// Centralized configuration for the app including API keys and endpoints.
library;

/// App-wide configuration settings.
///
/// In a production app, these would be loaded from environment variables
/// or a secure configuration service. For now, the Groq API key can be
/// set directly here or via environment variables.
class AppConfig {
  AppConfig._();

  /// Groq API key for AI coach features.
  ///
  /// Get your free API key from https://console.groq.com/keys
  /// Set this value or use the GROQ_API_KEY environment variable.
  static String? _groqApiKey;

  /// Sets the Groq API key.
  static void setGroqApiKey(String key) {
    _groqApiKey = key;
  }

  /// Gets the Groq API key.
  ///
  /// Returns null if not set, which will cause the app to use mock responses.
  static String? get groqApiKey => _groqApiKey ?? const String.fromEnvironment('GROQ_API_KEY');

  /// Whether a valid Groq API key is configured.
  static bool get hasGroqApiKey {
    final key = groqApiKey;
    return key != null && key.isNotEmpty && key != 'YOUR_GROQ_API_KEY_HERE';
  }

  /// Groq API base URL.
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  /// Default Groq model to use.
  ///
  /// Options:
  /// - llama-3.1-70b-versatile (best quality, slower)
  /// - llama-3.1-8b-instant (faster, good quality)
  /// - mixtral-8x7b-32768 (good balance)
  static const String groqModel = 'llama-3.1-8b-instant';

  /// Maximum tokens for AI responses.
  static const int maxTokens = 1024;

  /// Temperature for AI responses (0.0 = deterministic, 1.0 = creative).
  static const double temperature = 0.7;
}
