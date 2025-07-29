import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/src/login/login_credentials.dart';
import 'package:kiss_auth/src/login/login_provider.dart';
import 'package:kiss_auth/src/login/login_result.dart';
import 'package:kiss_auth/src/login/user_profile.dart';

/// Simple in-memory login provider for testing and demos
/// 
/// This implementation stores user credentials and generates JWT tokens
/// for testing purposes with realistic delays to simulate network latency.
/// Should NOT be used in production environments.
/// 
/// Simulated delays:
/// - Authentication: 800-1200ms
/// - Token refresh: 300-600ms  
/// - Logout: 200-400ms
/// - Token validation: 50-150ms
/// - User ID extraction: 30-80ms
class InMemoryLoginProvider implements LoginProvider {
  /// Creates an in-memory login provider with optional test users and JWT secret
  InMemoryLoginProvider({
    Map<String, TestUser>? testUsers,
    String? jwtSecret,
  }) : _users = testUsers ?? _defaultTestUsers(),
       _jwtSecret = jwtSecret ?? 'default-test-secret';

  final Map<String, TestUser> _users;
  final String _jwtSecret;
  final Map<String, String> _tokens = {}; // token -> userId  
  final Map<String, String> _refreshTokens = {}; // refreshToken -> userId

  static Map<String, TestUser> _defaultTestUsers() {
    const adminUser = TestUser(
      id: 'user_admin',
      username: 'admin',
      email: 'admin@example.com',
      password: 'admin123',
      roles: ['admin', 'user'],
      permissions: ['read', 'write', 'delete'],
    );
    
    const regularUser = TestUser(
      id: 'user_001',
      username: 'user',
      email: 'user@example.com',
      password: 'user123',
      roles: ['user'],
      permissions: ['read'],
    );
    
    const editorUser = TestUser(
      id: 'user_002',
      username: 'editor',
      email: 'editor@example.com',
      password: 'editor123',
      roles: ['user', 'editor'],
      permissions: ['read', 'write'],
    );
    
    return {
      // Support lookup by username
      'admin': adminUser,
      'user': regularUser,
      'editor': editorUser,
      // Support lookup by email
      'admin@example.com': adminUser,
      'user@example.com': regularUser,
      'editor@example.com': editorUser,
    };
  }

  @override
  Future<LoginResult> authenticate(LoginCredentials credentials) async {
    // Simulate realistic authentication processing time (800ms-1200ms)
    final delay = 800 + (DateTime.now().millisecondsSinceEpoch % 400);
    await Future<void>.delayed(Duration(milliseconds: delay));

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
    final now = DateTime.now();
    
    final jwt = JWT({
      'sub': userId,
      'roles': ['anonymous'],
      'permissions': ['read'],
      'auth_method': 'anonymous',
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(const Duration(minutes: 30)).millisecondsSinceEpoch ~/ 1000,
    });

    final accessToken = jwt.sign(SecretKey(_jwtSecret));
    _tokens[accessToken] = userId;

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
    final user = _users.values.firstWhere((u) => u.id == userId);
    final now = DateTime.now();
    
    final jwt = JWT({
      'sub': userId,
      'email': user.email,
      'username': user.username,
      'roles': user.roles,
      'permissions': user.permissions,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    });

    final token = jwt.sign(SecretKey(_jwtSecret));
    _tokens[token] = userId;
    return token;
  }

  String _generateRefreshToken(String userId) {
    final now = DateTime.now();
    
    final jwt = JWT({
      'sub': userId,
      'type': 'refresh',
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    });

    final refreshToken = jwt.sign(SecretKey(_jwtSecret));
    _refreshTokens[refreshToken] = userId;
    return refreshToken;
  }

  @override
  Future<LoginResult> refreshToken(String refreshToken) async {
    // Simulate token refresh processing (300ms-600ms)
    final delay = 300 + (DateTime.now().millisecondsSinceEpoch % 300);
    await Future<void>.delayed(Duration(milliseconds: delay));

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
    // Simulate logout processing (200ms-400ms)
    final delay = 200 + (DateTime.now().millisecondsSinceEpoch % 200);
    await Future<void>.delayed(Duration(milliseconds: delay));

    // Get userId before removing token
    final userId = await getUserIdFromToken(token);
    final removed = _tokens.remove(token) != null;
    
    // Also remove any refresh tokens for this user
    if (userId != null) {
      _refreshTokens.removeWhere((_, id) => id == userId);
    }

    return removed;
  }

  @override
  Future<bool> isTokenValid(String token) async {
    // Simulate token validation (50ms-150ms)
    final delay = 50 + (DateTime.now().millisecondsSinceEpoch % 100);
    await Future<void>.delayed(Duration(milliseconds: delay));
    
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        if (expiry.isBefore(DateTime.now())) {
          return false;
        }
      }
      return _tokens.containsKey(token);
    } on Exception {
      return false;
    }
  }

  @override
  Future<String?> getUserIdFromToken(String token) async {
    // Simulate user ID extraction (30ms-80ms)
    final delay = 30 + (DateTime.now().millisecondsSinceEpoch % 50);
    await Future<void>.delayed(Duration(milliseconds: delay));
    
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      return jwt.subject;
    } on Exception {
      return null;
    }
  }

  @override
  Future<LoginResult> createUser(LoginCredentials credentials) async {
    // Simulate user creation processing time (600ms-1000ms)
    final delay = 600 + (DateTime.now().millisecondsSinceEpoch % 400);
    await Future<void>.delayed(Duration(milliseconds: delay));

    if (credentials.type != 'user_creation') {
      return LoginResult.failure(
        error: 'Invalid credential type for user creation',
        errorCode: 'invalid_credential_type',
      );
    }

    final creds = credentials as UserCreationCredentials;
    
    // Check if user already exists
    if (_users.containsKey(creds.email)) {
      return LoginResult.failure(
        error: 'User already exists',
        errorCode: 'user_already_exists',
      );
    }

    // Generate new user ID
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    
    // Create new user with default roles and permissions
    final newUser = TestUser(
      id: userId,
      username: creds.displayName,
      email: creds.email,
      password: creds.password,
      roles: const ['user'],
      permissions: const ['read'],
    );

    // Store user (by email for lookup)
    _users[creds.email] = newUser;

    // Generate initial tokens
    final accessToken = _generateToken(userId);
    final refreshToken = _generateRefreshToken(userId);

    return LoginResult.success(
      user: UserProfile(
        userId: userId,
        email: creds.email,
        username: creds.displayName,
        roles: const ['user'],
        permissions: const ['read'],
        claims: {
          'email': creds.email,
          'username': creds.displayName,
          'roles': const ['user'],
          'permissions': const ['read'],
          'created_at': DateTime.now().toIso8601String(),
        },
      ),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: 3600,
    );
  }

  @override
  Map<String, dynamic> getProviderInfo() {
    return {
      'name': 'InMemoryLoginProvider',
      'version': '1.0.0',
      'type': 'testing',
      'capabilities': ['username_password', 'email_password', 'api_key', 'anonymous', 'user_creation'],
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
