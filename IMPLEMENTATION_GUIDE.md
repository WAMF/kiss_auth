# Kiss Auth Implementation Guide

This guide explains how to create new provider packages for Kiss Auth. Each provider package should implement one or more of the core interfaces to integrate with external services.

## Overview

Kiss Auth has three main interfaces that can be implemented, each with different typical deployment patterns:

1. **LoginProvider** - For credential-based authentication (getting tokens) - **Typically Client-Side**
2. **AuthValidator** - For token validation (validating tokens) - **Typically Server-Side**
3. **AuthorizationProvider** - For role/permission checking (authorization) - **Typically Server-Side**

## Client-Side vs Server-Side Usage

### Client-Side Components (Mobile Apps, Web Frontends)

**Primary Use Cases:**
- User authentication flows (login screens, signup forms)
- Token acquisition and local storage
- Basic user session management

**Key Classes:**
- `LoginProvider` implementations (Firebase, Auth0, PocketBase, etc.)
- `LoginService` - High-level authentication service
- `LoginCredentials` types (username/password, email/password, OAuth)
- `AuthService` (reference example) - Complete client-side authentication manager

### Server-Side Components (API Servers, Backend Services)

**Primary Use Cases:**
- API endpoint protection and middleware
- Request authorization and permission checking
- Server-side token validation

**Key Classes:**
- `AuthValidator` implementations (JWT validation)
- `AuthorizationProvider` implementations (permission/role checking)
- `AuthorizationService` - Combined authentication + authorization service

## Package Naming Convention

Follow this naming pattern for consistency:
- `kiss_auth_firebase` - Firebase implementation
- `kiss_auth_pocketbase` - PocketBase implementation
- `kiss_auth_auth0` - Auth0 implementation
- `kiss_auth_supabase` - Supabase implementation

## Core Interfaces

### 1. LoginProvider Interface

**Purpose**: Handle credential-based authentication and token generation.  
**Typical Usage**: **Client-Side** (mobile apps, web frontends)  
**Deployment**: User-facing applications where users enter credentials

```dart
abstract class LoginProvider {
  /// Authenticate a user with credentials and return tokens
  Future<LoginResult> authenticate(LoginCredentials credentials);
  
  /// Refresh an access token using a refresh token
  Future<LoginResult> refreshToken(String refreshToken);
  
  /// Revoke/logout a user session
  Future<bool> logout(String token);
  
  /// Check if a token is valid and not expired
  Future<bool> isTokenValid(String token);
  
  /// Get user ID from a token without full validation
  Future<String?> getUserIdFromToken(String token);
  
  /// Get provider information
  Map<String, dynamic> getProviderInfo();
}
```

**Supported Credential Types**:
- `UsernamePasswordCredentials`
- `EmailPasswordCredentials`
- `ApiKeyCredentials`
- `OAuthCredentials`
- `AnonymousCredentials`

### 2. AuthValidator Interface

**Purpose**: Validate JWT tokens and extract identity information.  
**Typical Usage**: **Server-Side** (API servers, backend services)  
**Deployment**: API middleware, request validation, server-side token verification

```dart
abstract class AuthValidator {
  /// Validates a token and returns authentication data
  Future<AuthenticationData> validateToken(String token);
}
```

### 3. AuthorizationProvider Interface

**Purpose**: Provide role-based and permission-based access control.  
**Typical Usage**: **Server-Side** (API servers, backend services)  
**Deployment**: API endpoint protection, business logic authorization, resource access control

```dart
abstract class AuthorizationProvider {
  /// Get user's current authorization data
  Future<AuthorizationData> getAuthorization(String userId, {
    String? resource,
    String? action, 
    Map<String, dynamic>? context,
  });
  
  /// Check if user has specific permission
  Future<bool> hasPermission(String userId, String permission, {
    String? resource,
    Map<String, dynamic>? context,
  });
  
  /// Check if user has specific role
  Future<bool> hasRole(String userId, String role, {
    String? resource,
    Map<String, dynamic>? context,
  });
  
  /// Batch check multiple permissions
  Future<Map<String, bool>> checkPermissions(String userId, List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  });
  
  /// Batch check multiple roles  
  Future<Map<String, bool>> checkRoles(String userId, List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  });
  
  /// Get user's effective permissions for a resource
  Future<List<String>> getEffectivePermissions(String userId, String resource);
  
  /// Get user's effective roles for a resource
  Future<List<String>> getEffectiveRoles(String userId, String resource);
  
  /// Check if user has any of the specified permissions
  Future<bool> hasAnyPermission(String userId, List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  });
  
  /// Check if user has all of the specified permissions
  Future<bool> hasAllPermissions(String userId, List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  });
  
  /// Check if user has any of the specified roles
  Future<bool> hasAnyRole(String userId, List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  });
  
  /// Check if user has all of the specified roles
  Future<bool> hasAllRoles(String userId, List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  });
}
```

## Deployment Patterns & Examples

### Client-Side Deployment Pattern

**Typical Architecture:**
```
Mobile App / Web Frontend
├── Login Screen (UI)
├── AuthService (token management)
├── LoginProvider (external auth)
└── Local Storage (secure token storage)
```

**Example Client-Side Flow:**
```dart
// Client-side authentication service
class ClientAuthService {
  final LoginProvider _loginProvider;
  final SecureStorage _storage;
  
  ClientAuthService(this._loginProvider, this._storage);
  
  Future<User?> login(String email, String password) async {
    final credentials = EmailPasswordCredentials(email, password);
    final result = await _loginProvider.authenticate(credentials);
    
    if (result.isSuccess) {
      // Store tokens securely on device
      await _storage.store('access_token', result.accessToken);
      await _storage.store('refresh_token', result.refreshToken);
      return result.user;
    }
    return null;
  }
}

// Flutter/Web usage
final authService = ClientAuthService(
  FirebaseLoginProvider(config: firebaseConfig),
  SecureStorage(),
);
```

### Server-Side Deployment Pattern

**Typical Architecture:**
```
API Server / Backend Service
├── Authentication Middleware
├── Authorization Middleware  
├── AuthValidator (JWT validation)
├── AuthorizationProvider (permissions)
└── Business Logic (protected endpoints)
```

**Example Server-Side Flow:**
```dart
// Server-side authorization middleware
class AuthMiddleware {
  final AuthValidator _authValidator;
  final AuthorizationProvider _authzProvider;
  
  AuthMiddleware(this._authValidator, this._authzProvider);
  
  Future<bool> authorizeRequest(String token, String permission) async {
    try {
      // Validate the token
      final authData = await _authValidator.validateToken(token);
      
      // Check permission
      return await _authzProvider.hasPermission(
        authData.userId, 
        permission
      );
    } catch (e) {
      return false;
    }
  }
}

// Express.js/Shelf usage
final middleware = AuthMiddleware(
  JwtAuthValidator.hmac(secretKey),
  DatabaseAuthorizationProvider(db),
);
```

### Full-Stack Example

**Client-Side (Flutter App):**
```dart
// 1. User login on mobile app
final loginService = LoginService(Auth0LoginProvider(config));
final result = await loginService.loginWithEmail('user@example.com', 'password');

// 2. Store JWT token locally
await storage.store('jwt_token', result.accessToken);

// 3. Include token in API requests
final response = await http.get(
  '/api/protected-resource',
  headers: {'Authorization': 'Bearer ${result.accessToken}'},
);
```

**Server-Side (Dart API):**
```dart
// 1. Validate incoming JWT token
final authValidator = JwtAuthValidator.hmac(jwtSecret);
final authData = await authValidator.validateToken(incomingToken);

// 2. Check user permissions
final authzProvider = DatabaseAuthorizationProvider();
final hasAccess = await authzProvider.hasPermission(
  authData.userId, 
  'resource:read'
);

// 3. Process request or return 403
if (hasAccess) {
  return await processRequest();
} else {
  return Response.forbidden('Insufficient permissions');
}
```

## Implementation Examples

### Reference: InMemoryLoginProvider

See the complete reference implementation at:
`lib/src/login/login_provider_in_memory.dart`

Key features demonstrated:
- ✅ Supports multiple credential types
- ✅ Token generation and management
- ✅ Refresh token handling
- ✅ Proper error handling with specific error codes
- ✅ Provider metadata

### Reference: InMemoryAuthorizationProvider

See the complete reference implementation at:
`lib/src/authorization_provider_in_memory.dart`

Key features demonstrated:
- ✅ Role and permission checking
- ✅ Context-aware authorization
- ✅ Batch operations for performance
- ✅ Resource-specific permissions

## Creating a New Provider Package

### 1. Package Structure

```
kiss_auth_yourservice/
├── lib/
│   ├── kiss_auth_yourservice.dart
│   └── src/
│       ├── yourservice_login_provider.dart
│       ├── yourservice_auth_validator.dart
│       └── yourservice_authorization_provider.dart
├── example/
│   └── main.dart
├── test/
│   ├── login_provider_test.dart
│   ├── auth_validator_test.dart
│   └── authorization_provider_test.dart
└── pubspec.yaml
```

### 2. Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kiss_auth: ^0.1.0
  # Your service-specific dependencies
  
dev_dependencies:
  test: ^1.24.0
```

### 3. Implementation Template

#### LoginProvider Implementation

```dart
import 'package:kiss_auth/kiss_login.dart';

class YourServiceLoginProvider implements LoginProvider {
  YourServiceLoginProvider({
    required this.apiKey,
    required this.baseUrl,
  });
  
  final String apiKey;
  final String baseUrl;
  
  @override
  Future<LoginResult> authenticate(LoginCredentials credentials) async {
    try {
      switch (credentials.type) {
        case 'username_password':
          return _authenticateWithPassword(credentials as UsernamePasswordCredentials);
        case 'email_password':
          return _authenticateWithEmail(credentials as EmailPasswordCredentials);
        case 'api_key':
          return _authenticateWithApiKey(credentials as ApiKeyCredentials);
        default:
          return LoginResult.failure(
            error: 'Unsupported credential type: ${credentials.type}',
            errorCode: 'unsupported_credential_type',
          );
      }
    } catch (e) {
      return LoginResult.failure(
        error: 'Authentication failed: $e',
        errorCode: 'authentication_error',
      );
    }
  }
  
  Future<LoginResult> _authenticateWithPassword(UsernamePasswordCredentials creds) async {
    // Implement your service's username/password authentication
    // Return LoginResult.success() or LoginResult.failure()
  }
  
  @override
  Future<LoginResult> refreshToken(String refreshToken) async {
    // Implement token refresh logic
  }
  
  @override
  Future<bool> logout(String token) async {
    // Implement logout/token invalidation
  }
  
  @override
  Future<bool> isTokenValid(String token) async {
    // Implement token validation
  }
  
  @override
  Future<String?> getUserIdFromToken(String token) async {
    // Extract user ID from token
  }
  
  @override
  Map<String, dynamic> getProviderInfo() {
    return {
      'name': 'YourServiceLoginProvider',
      'version': '1.0.0',
      'service': 'yourservice',
      'capabilities': ['username_password', 'email_password', 'api_key'],
    };
  }
}
```

#### AuthValidator Implementation

```dart
import 'package:kiss_auth/kiss_authentication.dart';

class YourServiceAuthValidator implements AuthValidator {
  YourServiceAuthValidator({required this.secretKey});
  
  final String secretKey;
  
  @override
  Future<AuthenticationData> validateToken(String token) async {
    try {
      // Validate the token with your service
      // Extract user information
      
      return YourServiceAuthenticationData(
        userId: extractedUserId,
        claims: extractedClaims,
        // Additional service-specific data
      );
    } catch (e) {
      throw Exception('Token validation failed: $e');
    }
  }
}

class YourServiceAuthenticationData implements AuthenticationData {
  const YourServiceAuthenticationData({
    required this.userId,
    required this.claims,
  });
  
  @override
  final String userId;
  
  @override
  final Map<String, dynamic> claims;
}
```

#### AuthorizationProvider Implementation

```dart
import 'package:kiss_auth/kiss_authorization.dart';

class YourServiceAuthorizationProvider implements AuthorizationProvider {
  YourServiceAuthorizationProvider({
    required this.apiClient,
  });
  
  final YourServiceApiClient apiClient;
  
  @override
  Future<AuthorizationData> getAuthorization(
    String userId, {
    String? resource,
    String? action,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Fetch authorization data from your service
      final response = await apiClient.getUserPermissions(userId, resource: resource);
      
      return AuthorizationData(
        userId: userId,
        roles: response.roles,
        permissions: response.permissions,
        attributes: response.attributes,
        resource: resource,
        action: action,
      );
    } catch (e) {
      throw Exception('Failed to get authorization: $e');
    }
  }
  
  @override
  Future<bool> hasPermission(
    String userId,
    String permission, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(userId, resource: resource, context: context);
    return authz.hasPermission(permission);
  }
  
  // Implement other methods...
}
```

### 4. Public API

Create your main library file:

```dart
// lib/kiss_auth_yourservice.dart
library kiss_auth_yourservice;

export 'src/yourservice_login_provider.dart';
export 'src/yourservice_auth_validator.dart';
export 'src/yourservice_authorization_provider.dart';
```

### 5. Example Usage

```dart
// example/main.dart
import 'package:kiss_auth/kiss_login.dart';
import 'package:kiss_auth_yourservice/kiss_auth_yourservice.dart';

void main() async {
  // Setup the provider
  final loginProvider = YourServiceLoginProvider(
    apiKey: 'your-api-key',
    baseUrl: 'https://api.yourservice.com',
  );
  
  final loginService = LoginService(loginProvider);
  
  // Login with credentials
  final result = await loginService.loginWithPassword('user', 'password');
  
  if (result.isSuccess) {
    print('Login successful: ${result.user?.userId}');
    print('Token: ${result.accessToken}');
  } else {
    print('Login failed: ${result.error}');
  }
}
```

## Testing Your Implementation

### 1. Unit Tests

Test each interface implementation:

```dart
// test/login_provider_test.dart
import 'package:test/test.dart';
import 'package:kiss_auth/kiss_login.dart';
import 'package:kiss_auth_yourservice/kiss_auth_yourservice.dart';

void main() {
  group('YourServiceLoginProvider', () {
    late YourServiceLoginProvider provider;
    
    setUp(() {
      provider = YourServiceLoginProvider(
        apiKey: 'test-key',
        baseUrl: 'https://test.api.com',
      );
    });
    
    test('should authenticate with valid credentials', () async {
      final credentials = UsernamePasswordCredentials(
        username: 'testuser',
        password: 'testpass',
      );
      
      final result = await provider.authenticate(credentials);
      
      expect(result.isSuccess, isTrue);
      expect(result.user?.userId, isNotNull);
    });
    
    test('should fail with invalid credentials', () async {
      final credentials = UsernamePasswordCredentials(
        username: 'invalid',
        password: 'invalid',
      );
      
      final result = await provider.authenticate(credentials);
      
      expect(result.isSuccess, isFalse);
      expect(result.errorCode, equals('invalid_credentials'));
    });
  });
}
```

### 2. Integration Tests

Test with the Kiss Auth service classes:

```dart
void main() {
  test('should work with LoginService', () async {
    final provider = YourServiceLoginProvider(/* config */);
    final loginService = LoginService(provider);
    
    final result = await loginService.loginWithPassword('user', 'pass');
    expect(result.isSuccess, isTrue);
  });
}
```

## Best Practices

### Client-Side Security
- **Token Storage**: Use secure storage mechanisms (Keychain, encrypted SharedPreferences)
- **No Secrets**: Never store JWT signing secrets or API keys in client code
- **Token Refresh**: Implement automatic token refresh before expiration
- **Secure Communication**: Always use HTTPS for authentication requests
- **Local Validation**: Basic token expiration checking before API calls

**Example Secure Client Implementation:**
```dart
class SecureAuthService {
  final SecureStorage _storage;
  
  Future<String?> getValidToken() async {
    final token = await _storage.getSecure('access_token');
    if (token != null && !isTokenExpired(token)) {
      return token;
    }
    
    // Attempt refresh if token is expired
    return await refreshTokenIfNeeded();
  }
}
```

### Server-Side Security
- **Secret Protection**: Securely store and manage JWT signing secrets
- **Token Validation**: Always validate incoming tokens before processing requests
- **Permission Checking**: Verify user permissions for each protected resource
- **Rate Limiting**: Implement rate limiting for authorization endpoints
- **Audit Logging**: Log authorization failures for security monitoring

**Example Secure Server Implementation:**
```dart
class SecureAuthMiddleware {
  final AuthValidator _validator;
  final AuthorizationProvider _authzProvider;
  
  Future<AuthResult> authorize(String token, String permission) async {
    try {
      // 1. Validate token signature and expiration
      final authData = await _validator.validateToken(token);
      
      // 2. Check user permissions
      final hasPermission = await _authzProvider.hasPermission(
        authData.userId, 
        permission
      );
      
      if (!hasPermission) {
        _auditLog.logUnauthorizedAccess(authData.userId, permission);
      }
      
      return AuthResult(success: hasPermission, user: authData);
    } catch (e) {
      _auditLog.logAuthenticationFailure(token, e);
      return AuthResult(success: false);
    }
  }
}
```

### Error Handling
- Use specific error codes for different failure scenarios
- Provide meaningful error messages
- Handle network timeouts and service unavailability

### Performance
- **Client-Side**: Cache user permissions locally, implement token refresh strategies
- **Server-Side**: Use caching for authorization data, implement batch operations
- Consider connection pooling for HTTP clients

### Configuration
- Support environment-based configuration
- Provide sensible defaults
- Document all configuration options

## Publishing Your Package

1. **Package Metadata**: Update `pubspec.yaml` with proper metadata
2. **Documentation**: Include comprehensive README and API docs
3. **Examples**: Provide working examples
4. **Tests**: Ensure good test coverage
5. **Publish**: Use `dart pub publish` to publish to pub.dev

## Community

- Submit your provider package to the Kiss Auth ecosystem
- Follow the naming convention: `kiss_auth_<service>`
- Consider contributing improvements back to the core library

## Reference Implementations

Study these reference implementations in the Kiss Auth core package:

- **InMemoryLoginProvider** - Complete login provider example
- **InMemoryAuthorizationProvider** - Complete authorization provider example
- **JwtAuthValidator** - JWT validation implementation

These provide working examples of all interfaces and demonstrate best practices for error handling, testing, and documentation.

## Quick Reference: Client vs Server Usage

### Client-Side (Mobile Apps, Web Frontends)
```dart
// What you typically implement on client-side:
- LoginProvider implementations (Firebase, Auth0, etc.)
- LoginService (high-level auth operations)
- AuthService (token management, persistence)
- LoginCredentials (user input handling)

// What you DON'T put on client-side:
- JWT signing secrets
- AuthValidator implementations
- AuthorizationProvider implementations
- Server-side authorization logic
```

### Server-Side (API Servers, Backend Services)
```dart
// What you typically implement on server-side:
- AuthValidator implementations (JWT validation)
- AuthorizationProvider implementations (permissions)
- AuthorizationService (combined auth + authz)
- API middleware for endpoint protection

// What you DON'T put on server-side:
- User credential collection logic
- LoginProvider implementations (unless SSO)
- Client-side token storage
- User interface components
```

### Shared Components (Both Sides)
```dart
// Data classes used on both client and server:
- AuthenticationData (token validation results)
- AuthorizationData (user permissions and roles)
- LoginResult (authentication operation results)
- UserProfile (user identity information)
- JWT-related data classes
```
