/// Configuration for authorization services
class AuthorizationServiceConfig {

  /// Creates configuration for authorization services
  const AuthorizationServiceConfig({
    required this.baseUrl,
    required this.apiKey,
    this.timeout = const Duration(seconds: 5),
    this.headers = const {},
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });
  
  /// Base URL for the authorization service
  final String baseUrl;
  
  /// API key for authentication
  final String apiKey;
  
  /// Timeout duration for requests
  final Duration timeout;
  
  /// Additional headers to include in requests
  final Map<String, String> headers;
  
  /// Maximum number of retries for failed requests
  final int maxRetries;
  
  /// Delay between retry attempts
  final Duration retryDelay;

  /// Create a copy with updated values
  AuthorizationServiceConfig copyWith({
    String? baseUrl,
    String? apiKey,
    Duration? timeout,
    Map<String, String>? headers,
    int? maxRetries,
    Duration? retryDelay,
  }) {
    return AuthorizationServiceConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      timeout: timeout ?? this.timeout,
      headers: headers ?? this.headers,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
    );
  }

  @override
  String toString() {
    return 'AuthorizationServiceConfig(baseUrl: $baseUrl, timeout: $timeout, maxRetries: $maxRetries)';
  }

}
