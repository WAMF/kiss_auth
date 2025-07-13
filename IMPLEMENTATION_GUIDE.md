# Kiss Auth Implementation Guide

This guide explains how to create new provider packages for Kiss Auth. Each provider package should implement one or more of the core interfaces to integrate with external services.

## Overview

Kiss Auth has three main interfaces that can be implemented:

1. **LoginProvider** - For credential-based authentication (getting tokens)
2. **AuthValidator** - For token validation (validating tokens)  
3. **AuthorizationProvider** - For role/permission checking (authorization)

## Package Naming Convention

Follow this naming pattern for consistency:
- `kiss_auth_firebase` - Firebase implementation
- `kiss_auth_pocketbase` - PocketBase implementation
- `kiss_auth_auth0` - Auth0 implementation
- `kiss_auth_supabase` - Supabase implementation

## Core Interfaces

### 1. LoginProvider Interface

**Purpose**: Handle credential-based authentication and token generation.

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

```dart
abstract class AuthValidator {
  /// Validates a token and returns authentication data
  Future<AuthenticationData> validateToken(String token);
}
```

### 3. AuthorizationProvider Interface

**Purpose**: Provide role-based and permission-based access control.

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

### Error Handling
- Use specific error codes for different failure scenarios
- Provide meaningful error messages
- Handle network timeouts and service unavailability

### Performance
- Implement caching where appropriate
- Use batch operations for multiple checks
- Consider connection pooling for HTTP clients

### Security
- Never log sensitive information (passwords, tokens)
- Validate all inputs
- Use secure HTTP (HTTPS) for all API calls
- Implement proper token expiration handling

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