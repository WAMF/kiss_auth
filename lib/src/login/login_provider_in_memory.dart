import 'package:kiss_auth/src/login/login_credentials.dart';
import 'package:kiss_auth/src/login/login_provider.dart';
import 'package:kiss_auth/src/login/login_result.dart';
import 'package:kiss_auth/src/login/user_profile.dart';

/// Simple in-memory login provider for testing and demos
/// 
/// This implementation stores user credentials and tokens in memory
/// and should NOT be used in production environments.
class InMemoryLoginProvider implements LoginProvider {
  /// Creates an in-memory login provider with optional test users
  InMemoryLoginProvider({Map<String, TestUser>? testUsers})
      : _users = testUsers ?? _defaultTestUsers();

  final Map<String, TestUser> _users;
  final Map<String, String> _tokens = {}; // token -> userId
  final Map<String, String> _refreshTokens = {}; // refreshToken -> userId

  static Map<String, TestUser> _defaultTestUsers() {
    return {
      'admin': const TestUser(
        id: 'user_admin',
        username: 'admin',
        email: 'admin@example.com',
        password: 'admin123',
        roles: ['admin', 'user'],
        permissions: ['read', 'write', 'delete'],
      ),
      'user': const TestUser(
        id: 'user_001',
        username: 'user',
        email: 'user@example.com',
        password: 'user123',
        roles: ['user'],
        permissions: ['read'],
      ),
      'test@example.com': const TestUser(
        id: 'user_002',
        username: null,
        email: 'test@example.com',
        password: 'test123',
        roles: ['user'],
        permissions: ['read', 'write'],
      ),
    };
  }

  @override
  Future<LoginResult> authenticate(LoginCredentials credentials) async {
    await Future<void>.delayed(const Duration(milliseconds: 100)); // Simulate network

    switch (credentials.type) {
      case 'username_password':
        final creds = credentials as UsernamePasswordCredentials;
        return _authenticateWithPassword(creds.username, creds.password);
      
      case 'email_password':
        final creds = credentials as EmailPasswordCredentials;
        return _authenticateWithPassword(creds.email, creds.password);
      
      case 'api_key':
        final creds = credentials as ApiKeyCredentials;
        return _authenticateWithApiKey(creds.apiKey);
      
      case 'anonymous':
        return _authenticateAnonymously();
      
      default:
        return LoginResult.failure(
          error: 'Unsupported credential type: ${credentials.type}',
          errorCode: 'unsupported_credential_type',
        );
    }
  }

  LoginResult _authenticateWithPassword(String identifier, String password) {
    final user = _users[identifier];
    if (user == null || user.password != password) {
      return LoginResult.failure(
        error: 'Invalid credentials',
        errorCode: 'invalid_credentials',
      );
    }

    final accessToken = _generateToken(user.id);
    final refreshToken = _generateRefreshToken(user.id);

    return LoginResult.success(
      user: UserProfile(
        userId: user.id,
        email: user.email,
        username: user.username,
        roles: user.roles,
        permissions: user.permissions,
        claims: {
          'email': user.email,
          'username': user.username,
          'roles': user.roles,
          'permissions': user.permissions,
        },
      ),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: 3600, // 1 hour
    );
  }

  LoginResult _authenticateWithApiKey(String apiKey) {
    // Simple API key format: "api_key_<userId>"
    if (!apiKey.startsWith('api_key_')) {
      return LoginResult.failure(
        error: 'Invalid API key format',
        errorCode: 'invalid_api_key',
      );
    }

    final userId = apiKey.substring(8); // Remove "api_key_" prefix
    final user = _users.values.firstWhere(
      (u) => u.id == userId,
      orElse: () => const TestUser(
        id: '',
        username: null,
        email: null,
        password: '',
        roles: [],
        permissions: [],
      ),
    );

    if (user.id.isEmpty) {
      return LoginResult.failure(
        error: 'Invalid API key',
        errorCode: 'invalid_api_key',
      );
    }

    final accessToken = _generateToken(user.id);

    return LoginResult.success(
      user: UserProfile(
        userId: user.id,
        email: user.email,
        username: user.username,
        roles: user.roles,
        permissions: user.permissions,
        claims: {
          'email': user.email,
          'username': user.username,
          'roles': user.roles,
          'permissions': user.permissions,
          'auth_method': 'api_key',
        },
      ),
      accessToken: accessToken,
      expiresIn: 86400, // 24 hours for API keys
    );
  }

  LoginResult _authenticateAnonymously() {
    const userId = 'anonymous_user';
    final accessToken = _generateToken(userId);

    return LoginResult.success(
      user: const UserProfile(
        userId: userId,
        roles: ['anonymous'],
        permissions: ['read'],
        claims: {
          'auth_method': 'anonymous',
          'roles': ['anonymous'],
          'permissions': ['read'],
        },
      ),
      accessToken: accessToken,
      expiresIn: 1800, // 30 minutes for anonymous
    );
  }

  String _generateToken(String userId) {
    final token = 'token_${DateTime.now().millisecondsSinceEpoch}_$userId';
    _tokens[token] = userId;
    return token;
  }

  String _generateRefreshToken(String userId) {
    final refreshToken = 'refresh_${DateTime.now().millisecondsSinceEpoch}_$userId';
    _refreshTokens[refreshToken] = userId;
    return refreshToken;
  }

  @override
  Future<LoginResult> refreshToken(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final userId = _refreshTokens[refreshToken];
    if (userId == null) {
      return LoginResult.failure(
        error: 'Invalid refresh token',
        errorCode: 'invalid_refresh_token',
      );
    }

    final user = _users.values.firstWhere(
      (u) => u.id == userId,
      orElse: () => const TestUser(
        id: '',
        username: null,
        email: null,
        password: '',
        roles: [],
        permissions: [],
      ),
    );

    if (user.id.isEmpty) {
      return LoginResult.failure(
        error: 'User not found',
        errorCode: 'user_not_found',
      );
    }

    final newAccessToken = _generateToken(userId);
    final newRefreshToken = _generateRefreshToken(userId);

    // Remove old refresh token
    _refreshTokens.remove(refreshToken);

    return LoginResult.success(
      user: UserProfile(
        userId: user.id,
        email: user.email,
        username: user.username,
        roles: user.roles,
        permissions: user.permissions,
      ),
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      expiresIn: 3600,
    );
  }

  @override
  Future<bool> logout(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final removed = _tokens.remove(token) != null;
    
    // Also remove any refresh tokens for this user
    final userId = _tokens[token];
    if (userId != null) {
      _refreshTokens.removeWhere((_, id) => id == userId);
    }

    return removed;
  }

  @override
  Future<bool> isTokenValid(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _tokens.containsKey(token);
  }

  @override
  Future<String?> getUserIdFromToken(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _tokens[token];
  }

  @override
  Map<String, dynamic> getProviderInfo() {
    return {
      'name': 'InMemoryLoginProvider',
      'version': '1.0.0',
      'type': 'testing',
      'capabilities': ['username_password', 'email_password', 'api_key', 'anonymous'],
      'user_count': _users.length,
    };
  }
}

/// Test user data structure for in-memory provider
class TestUser {
  /// Creates a test user
  const TestUser({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.roles,
    required this.permissions,
  });

  /// User ID
  final String id;

  /// Username (optional)
  final String? username;

  /// Email address (optional)
  final String? email;

  /// Password for authentication
  final String password;

  /// User's roles
  final List<String> roles;

  /// User's permissions
  final List<String> permissions;
}
