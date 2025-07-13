import 'package:kiss_auth/src/login/user_profile.dart';
import 'package:meta/meta.dart';

/// Result of a login attempt
@immutable
class LoginResult {
  /// Creates a login result
  const LoginResult({
    required this.isSuccess,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.expiresAt,
    this.error,
    this.errorCode,
    this.metadata = const {},
  });

  /// Create a successful login result
  factory LoginResult.success({
    required UserProfile user,
    required String accessToken,
    String? refreshToken,
    String tokenType = 'Bearer',
    int? expiresIn,
    DateTime? expiresAt,
    Map<String, dynamic> metadata = const {},
  }) {
    return LoginResult(
      isSuccess: true,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      expiresAt: expiresAt,
      metadata: metadata,
    );
  }

  /// Create a failed login result
  factory LoginResult.failure({
    required String error,
    String? errorCode,
    Map<String, dynamic> metadata = const {},
  }) {
    return LoginResult(
      isSuccess: false,
      error: error,
      errorCode: errorCode,
      metadata: metadata,
    );
  }

  /// Create from map
  factory LoginResult.fromMap(Map<String, dynamic> map) {
    return LoginResult(
      isSuccess: map['is_success'] as bool,
      user: map['user'] != null
          ? UserProfile.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      accessToken: map['access_token'] as String?,
      refreshToken: map['refresh_token'] as String?,
      tokenType: map['token_type'] as String? ?? 'Bearer',
      expiresIn: map['expires_in'] as int?,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      error: map['error'] as String?,
      errorCode: map['error_code'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  /// Whether the login was successful
  final bool isSuccess;

  /// User profile information (if successful)
  final UserProfile? user;

  /// Access token for API calls (if successful)
  final String? accessToken;

  /// Refresh token for token renewal (if applicable)
  final String? refreshToken;

  /// Type of token (usually 'Bearer')
  final String tokenType;

  /// Token expiration in seconds from now
  final int? expiresIn;

  /// Exact expiration timestamp
  final DateTime? expiresAt;

  /// Error message (if failed)
  final String? error;

  /// Error code for programmatic handling (if failed)
  final String? errorCode;

  /// Additional metadata
  final Map<String, dynamic> metadata;

  /// Check if the token is expired
  bool get isExpired {
    if (expiresAt != null) {
      return DateTime.now().isAfter(expiresAt!);
    }
    return false;
  }

  /// Check if the token will expire soon (within the given duration)
  bool willExpireSoon([Duration buffer = const Duration(minutes: 5)]) {
    if (expiresAt != null) {
      return DateTime.now().add(buffer).isAfter(expiresAt!);
    }
    return false;
  }

  /// Get a metadata value by key
  T? getMetadata<T>(String key) => metadata[key] as T?;

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'is_success': isSuccess,
      if (user != null) 'user': user!.toMap(),
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'token_type': tokenType,
      if (expiresIn != null) 'expires_in': expiresIn,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      if (error != null) 'error': error,
      if (errorCode != null) 'error_code': errorCode,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResult &&
          runtimeType == other.runtimeType &&
          isSuccess == other.isSuccess &&
          user == other.user &&
          accessToken == other.accessToken &&
          error == other.error &&
          errorCode == other.errorCode;

  @override
  int get hashCode =>
      isSuccess.hashCode ^
      user.hashCode ^
      accessToken.hashCode ^
      error.hashCode ^
      errorCode.hashCode;

  @override
  String toString() {
    if (isSuccess) {
      return 'LoginResult.success(user: ${user?.userId}, hasToken: ${accessToken != null})';
    } else {
      return 'LoginResult.failure(error: $error, code: $errorCode)';
    }
  }
}
