/// LiftIQ - API Client Service
///
/// Provides a configured Dio HTTP client for making API requests.
/// Handles authentication, error handling, and request/response logging.
///
/// Features:
/// - Automatic token injection for authenticated requests
/// - Standardized error handling
/// - Request/response logging in debug mode
/// - Retry logic for failed requests
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

/// Custom exception for API errors.
///
/// Wraps Dio errors with additional context and user-friendly messages.
class ApiException implements Exception {
  /// HTTP status code, or -1 for network errors.
  final int statusCode;

  /// Error code from the API (e.g., 'VALIDATION_ERROR').
  final String code;

  /// Human-readable error message.
  final String message;

  /// Additional error details from the API.
  final Map<String, dynamic>? details;

  /// The original Dio exception, if any.
  final DioException? originalException;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
    this.originalException,
  });

  @override
  String toString() => 'ApiException: [$code] $message';

  /// Whether this is a network/connection error.
  bool get isNetworkError =>
      statusCode == -1 ||
      originalException?.type == DioExceptionType.connectionTimeout ||
      originalException?.type == DioExceptionType.connectionError;

  /// Whether this is an authentication error.
  bool get isAuthError => statusCode == 401;

  /// Whether this is a validation error.
  bool get isValidationError => statusCode == 400;

  /// Whether this is a not found error.
  bool get isNotFoundError => statusCode == 404;

  /// Whether this is a server error.
  bool get isServerError => statusCode >= 500;
}

/// API client for making HTTP requests to the LiftIQ backend.
///
/// This client handles:
/// - Base URL configuration
/// - Authentication token injection
/// - Error standardization
/// - Logging (in debug mode)
///
/// Usage:
/// ```dart
/// final apiClient = ref.read(apiClientProvider);
///
/// // GET request
/// final response = await apiClient.get('/exercises');
/// final exercises = response.data['data'];
///
/// // POST request
/// final response = await apiClient.post('/workouts', data: {'notes': 'Leg day'});
/// ```
class ApiClient {
  /// The underlying Dio HTTP client.
  final Dio _dio;

  /// Auth service for getting tokens.
  final AuthService _authService;

  /// Creates an ApiClient with the given Dio instance and AuthService.
  ApiClient({
    required Dio dio,
    required AuthService authService,
  })  : _dio = dio,
        _authService = authService;

  /// Creates a fully configured ApiClient.
  ///
  /// Sets up:
  /// - Base URL from ApiConfig
  /// - Timeouts
  /// - Auth interceptor
  /// - Error interceptor
  /// - Logging interceptor (debug only)
  factory ApiClient.configured(AuthService authService) {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    final client = ApiClient(dio: dio, authService: authService);
    client._setupInterceptors();
    return client;
  }

  /// Sets up all Dio interceptors.
  void _setupInterceptors() {
    // Auth interceptor - adds Bearer token to requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth for public endpoints
        if (_isPublicEndpoint(options.path)) {
          return handler.next(options);
        }

        // Get token and add to header
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 - try to refresh token and retry
        if (error.response?.statusCode == 401) {
          try {
            final token = await _authService.getToken(forceRefresh: true);
            if (token != null) {
              // Retry the request with new token
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            // Token refresh failed, let the error propagate
          }
        }
        return handler.next(error);
      },
    ));

    // Error interceptor - standardizes error responses
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        final apiException = _parseError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: apiException,
          type: error.type,
          response: error.response,
        ));
      },
    ));

    // Logging interceptor (debug mode only)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('API: $o'),
      ));
    }
  }

  /// Checks if the endpoint is public (no auth required).
  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/login',
      '/auth/signup',
      '/auth/forgot-password',
      '/exercises', // Public listing
      '/exercises/muscles',
      '/exercises/equipment',
      '/health',
    ];

    return publicEndpoints.any((endpoint) => path.startsWith(endpoint));
  }

  /// Parses a DioException into an ApiException.
  ApiException _parseError(DioException error) {
    // Network/connection errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        statusCode: -1,
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to server. Please check your internet connection.',
        originalException: error,
      );
    }

    // Parse API error response
    final response = error.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        final errorData = data['error'] as Map<String, dynamic>;
        return ApiException(
          statusCode: response.statusCode ?? 500,
          code: errorData['code'] as String? ?? 'UNKNOWN_ERROR',
          message: errorData['message'] as String? ?? 'An unexpected error occurred',
          details: errorData['details'] as Map<String, dynamic>?,
          originalException: error,
        );
      }

      // Non-standard error response
      return ApiException(
        statusCode: response.statusCode ?? 500,
        code: 'SERVER_ERROR',
        message: _getDefaultMessage(response.statusCode ?? 500),
        originalException: error,
      );
    }

    // Unknown error
    return ApiException(
      statusCode: -1,
      code: 'UNKNOWN_ERROR',
      message: error.message ?? 'An unexpected error occurred',
      originalException: error,
    );
  }

  /// Gets default error message for status code.
  String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Please sign in to continue.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  /// Extracts ApiException from DioException.
  ///
  /// Use this to get the parsed error from a catch block:
  /// ```dart
  /// try {
  ///   await apiClient.get('/something');
  /// } on DioException catch (e) {
  ///   final apiError = ApiClient.getApiException(e);
  ///   showError(apiError.message);
  /// }
  /// ```
  static ApiException getApiException(DioException error) {
    if (error.error is ApiException) {
      return error.error as ApiException;
    }
    return ApiException(
      statusCode: error.response?.statusCode ?? -1,
      code: 'UNKNOWN_ERROR',
      message: error.message ?? 'An unexpected error occurred',
      originalException: error,
    );
  }

  // =========================================================================
  // HTTP Methods
  // =========================================================================

  /// Makes a GET request.
  ///
  /// [path] - API endpoint path (e.g., '/exercises')
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Makes a POST request.
  ///
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Makes a PUT request.
  ///
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Makes a PATCH request.
  ///
  /// [path] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Makes a DELETE request.
  ///
  /// [path] - API endpoint path
  /// [data] - Optional request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Provider for the API client.
///
/// The client is configured with authentication and error handling.
///
/// Usage:
/// ```dart
/// final api = ref.read(apiClientProvider);
/// final response = await api.get('/exercises');
/// ```
final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiClient.configured(authService);
});
