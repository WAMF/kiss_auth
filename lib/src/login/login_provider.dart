import 'package:kiss_auth/src/login/login_credentials.dart';
import 'package:kiss_auth/src/login/login_result.dart';

/// Abstract interface for login providers
/// 
/// This interface should be implemented by external packages such as:
/// - kiss_auth_firebase
/// - kiss_auth_pocketbase
/// - kiss_auth_auth0
/// - kiss_auth_supabase
/// etc.
/// 
/// Focus: Authentication and token management only
abstract class LoginProvider {
  /// Authenticate a user with the provided credentials
  /// 
  /// Returns a [LoginResult] with user identity and tokens on success,
  /// or error information on failure.
  Future<LoginResult> authenticate(LoginCredentials credentials);

  /// Refresh an access token using a refresh token
  /// 
  /// Returns a new [LoginResult] with fresh tokens, or an error
  /// if the refresh token is invalid or expired.
  Future<LoginResult> refreshToken(String refreshToken);

  /// Revoke/logout a user session
  /// 
  /// This invalidates the provided token and any associated refresh tokens.
  /// Returns true if the logout was successful.
  Future<bool> logout(String token);

  /// Check if a token is valid and not expired
  /// 
  /// Returns true if the token is valid and can be used for authentication.
  Future<bool> isTokenValid(String token);

  /// Get user ID from a token without full validation
  /// 
  /// This is a lightweight method to extract the user ID from a token.
  /// For full validation, use the AuthValidator from the authentication module.
  Future<String?> getUserIdFromToken(String token);

  /// Get provider-specific configuration information
  /// 
  /// Returns metadata about the provider (name, version, capabilities, etc.)
  Map<String, dynamic> getProviderInfo();
}
