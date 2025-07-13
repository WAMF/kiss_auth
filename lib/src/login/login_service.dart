import 'package:kiss_auth/src/login/login_credentials.dart';
import 'package:kiss_auth/src/login/login_provider.dart';
import 'package:kiss_auth/src/login/login_result.dart';

/// Service class that coordinates login operations
/// 
/// This class provides a high-level interface for authentication operations
/// and delegates the actual implementation to a [LoginProvider].
class LoginService {
  /// Creates a login service with the given provider
  const LoginService(this._provider);

  final LoginProvider _provider;

  /// Authenticate a user with credentials
  /// 
  /// Returns a [LoginResult] with user identity and tokens on success.
  Future<LoginResult> login(LoginCredentials credentials) async {
    try {
      return await _provider.authenticate(credentials);
    } on Exception catch (e) {
      return LoginResult.failure(
        error: 'Login failed: $e',
        errorCode: 'authentication_error',
      );
    }
  }

  /// Quick login with username and password
  /// 
  /// Convenience method for username/password authentication.
  Future<LoginResult> loginWithPassword(
    String username,
    String password,
  ) async {
    final credentials = UsernamePasswordCredentials(
      username: username,
      password: password,
    );
    return login(credentials);
  }

  /// Quick login with email and password
  /// 
  /// Convenience method for email/password authentication.
  Future<LoginResult> loginWithEmail(String email, String password) async {
    final credentials = EmailPasswordCredentials(
      email: email,
      password: password,
    );
    return login(credentials);
  }

  /// Login with API key
  /// 
  /// Convenience method for API key authentication.
  Future<LoginResult> loginWithApiKey(String apiKey, [String? keyId]) async {
    final credentials = ApiKeyCredentials(apiKey: apiKey, keyId: keyId);
    return login(credentials);
  }

  /// Login with OAuth credentials
  /// 
  /// Convenience method for OAuth authentication.
  Future<LoginResult> loginWithOAuth({
    required String accessToken,
    required String provider,
    String? refreshToken,
    String? idToken,
  }) async {
    final credentials = OAuthCredentials(
      accessToken: accessToken,
      provider: provider,
      refreshToken: refreshToken,
      idToken: idToken,
    );
    return login(credentials);
  }

  /// Anonymous login
  /// 
  /// Convenience method for anonymous authentication.
  Future<LoginResult> loginAnonymously() async {
    const credentials = AnonymousCredentials();
    return login(credentials);
  }

  /// Refresh an access token
  /// 
  /// Returns a new [LoginResult] with fresh tokens.
  Future<LoginResult> refreshToken(String refreshToken) async {
    try {
      return await _provider.refreshToken(refreshToken);
    } on Exception catch (e) {
      return LoginResult.failure(
        error: 'Token refresh failed: $e',
        errorCode: 'refresh_error',
      );
    }
  }

  /// Logout a user session
  /// 
  /// Invalidates the token and associated refresh tokens.
  Future<bool> logout(String token) async {
    try {
      return await _provider.logout(token);
    } on Exception {
      return false;
    }
  }

  /// Check if a token is valid
  /// 
  /// Returns true if the token is valid and not expired.
  Future<bool> isTokenValid(String token) async {
    try {
      return await _provider.isTokenValid(token);
    } on Exception {
      return false;
    }
  }

  /// Extract user ID from token
  /// 
  /// Returns the user ID or null if extraction fails.
  Future<String?> getUserIdFromToken(String token) async {
    try {
      return await _provider.getUserIdFromToken(token);
    } on Exception {
      return null;
    }
  }

  /// Get provider information
  /// 
  /// Returns metadata about the configured login provider.
  Map<String, dynamic> getProviderInfo() {
    return _provider.getProviderInfo();
  }
}
