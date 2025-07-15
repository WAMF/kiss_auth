import 'package:meta/meta.dart';

/// Abstract base class for login credentials
abstract class LoginCredentials {
  /// Creates a new LoginCredentials instance
  const LoginCredentials();

  /// The type of credentials (e.g., 'username_password', 'api_key', 'oauth')
  String get type;

  /// Convert credentials to a map for serialization
  Map<String, dynamic> toMap();
}

/// Username and password credentials
@immutable
class UsernamePasswordCredentials extends LoginCredentials {
  /// Creates username and password credentials
  const UsernamePasswordCredentials({
    required this.username,
    required this.password,
  });

  /// The username for authentication
  final String username;

  /// The password for authentication
  final String password;

  @override
  String get type => 'username_password';

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'username': username,
        'password': password,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsernamePasswordCredentials &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode;

  @override
  String toString() => 'UsernamePasswordCredentials(username: $username)';
}

/// Email and password credentials
@immutable
class EmailPasswordCredentials extends LoginCredentials {
  /// Creates email and password credentials
  const EmailPasswordCredentials({
    required this.email,
    required this.password,
  });

  /// The email for authentication
  final String email;

  /// The password for authentication
  final String password;

  @override
  String get type => 'email_password';

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'email': email,
        'password': password,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailPasswordCredentials &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  @override
  String toString() => 'EmailPasswordCredentials(email: $email)';
}

/// API key credentials
@immutable
class ApiKeyCredentials extends LoginCredentials {
  /// Creates API key credentials
  const ApiKeyCredentials({
    required this.apiKey,
    this.keyId,
  });

  /// The API key for authentication
  final String apiKey;

  /// Optional key identifier
  final String? keyId;

  @override
  String get type => 'api_key';

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'api_key': apiKey,
        if (keyId != null) 'key_id': keyId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiKeyCredentials &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey &&
          keyId == other.keyId;

  @override
  int get hashCode => apiKey.hashCode ^ keyId.hashCode;

  @override
  String toString() => 'ApiKeyCredentials(keyId: $keyId)';
}

/// OAuth token credentials
@immutable
class OAuthCredentials extends LoginCredentials {
  /// Creates OAuth credentials
  const OAuthCredentials({
    required this.accessToken,
    required this.provider,
    this.refreshToken,
    this.idToken,
  });

  /// The OAuth access token
  final String accessToken;

  /// The OAuth provider name (e.g., 'google', 'facebook')
  final String provider;

  /// Optional refresh token
  final String? refreshToken;

  /// Optional ID token
  final String? idToken;

  @override
  String get type => 'oauth';

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'access_token': accessToken,
        'provider': provider,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (idToken != null) 'id_token': idToken,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthCredentials &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          provider == other.provider &&
          refreshToken == other.refreshToken &&
          idToken == other.idToken;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      provider.hashCode ^
      refreshToken.hashCode ^
      idToken.hashCode;

  @override
  String toString() => 'OAuthCredentials(provider: $provider)';
}

/// User creation credentials for email/password registration
@immutable
class UserCreationCredentials extends LoginCredentials {
  /// Creates user creation credentials
  const UserCreationCredentials({
    required this.email,
    required this.password,
    this.displayName,
    this.additionalData,
  });

  /// The email for the new user
  final String email;

  /// The password for the new user
  final String password;

  /// Optional display name for the new user
  final String? displayName;

  /// Optional additional data for user creation
  final Map<String, dynamic>? additionalData;

  @override
  String get type => 'user_creation';

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'email': email,
        'password': password,
        if (displayName != null) 'display_name': displayName,
        if (additionalData != null) 'additional_data': additionalData,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCreationCredentials &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          displayName == other.displayName &&
          additionalData == other.additionalData;

  @override
  int get hashCode =>
      email.hashCode ^
      password.hashCode ^
      displayName.hashCode ^
      additionalData.hashCode;

  @override
  String toString() => 'UserCreationCredentials(email: $email, displayName: $displayName)';
}

/// Anonymous credentials (for guest/anonymous login)
@immutable
class AnonymousCredentials extends LoginCredentials {
  /// Creates anonymous credentials
  const AnonymousCredentials();

  @override
  String get type => 'anonymous';

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnonymousCredentials && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AnonymousCredentials()';
}
