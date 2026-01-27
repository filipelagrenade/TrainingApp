/// LiftIQ - API Configuration
///
/// Centralizes all API-related configuration settings.
/// This file allows easy switching between development and production environments.
///
/// To use production (Railway deployed backend):
/// 1. Deploy backend to Railway
/// 2. Update [productionBaseUrl] with your Railway URL
/// 3. Set [useProduction] to true
library;

/// API configuration constants.
///
/// Contains base URLs and timeout settings for the API client.
/// Modify this file when deploying to production or changing API settings.
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Whether to use production API (Railway) or local development server.
  ///
  /// Set to `true` when deploying to production.
  /// Set to `false` during local development.
  static const bool useProduction = true;

  /// Local development API base URL.
  ///
  /// Points to the locally running backend server.
  /// Make sure the backend is running with `npm run dev`.
  static const String developmentBaseUrl = 'http://10.0.2.2:3000/api/v1';

  /// Production API base URL (Railway).
  ///
  /// Replace with your actual Railway deployment URL.
  /// Example: 'https://liftiq-backend.up.railway.app/api/v1'
  static const String productionBaseUrl =
      'https://liftiq-production.up.railway.app/api/v1';

  /// The active base URL based on environment.
  ///
  /// Automatically selects between development and production URLs.
  static String get baseUrl =>
      useProduction ? productionBaseUrl : developmentBaseUrl;

  /// Connection timeout in milliseconds.
  ///
  /// How long to wait for initial connection to be established.
  /// Set to 10 seconds to handle slow networks.
  static const int connectTimeout = 10000;

  /// Receive timeout in milliseconds.
  ///
  /// How long to wait for response data.
  /// Most endpoints should respond within 30 seconds.
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds.
  ///
  /// How long to wait for request data to be sent.
  /// Uploads may take longer, but most requests are quick.
  static const int sendTimeout = 15000;

  /// Maximum retries for failed requests.
  ///
  /// Network requests will retry this many times on failure
  /// before throwing an error.
  static const int maxRetries = 3;

  /// Delay between retries in milliseconds.
  ///
  /// Uses exponential backoff: delay * 2^attempt.
  static const int retryDelayMs = 1000;
}
