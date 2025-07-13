import 'package:kiss_auth/src/authentication_data.dart';
import 'package:kiss_auth/src/authentication_data_extensions.dart';
import 'package:kiss_auth/src/authentication_validator.dart';
import 'package:kiss_auth/src/authorization_data.dart';
import 'package:kiss_auth/src/authorization_provider.dart';
import 'package:kiss_auth/src/jwt_claims.dart';

/// Server-side authorization manager that combines token validation with authorization checking
class AuthorizationService {

  /// Creates an authorization service with token validator and authorization provider
  AuthorizationService(this._authValidator, this._authzProvider);
  final AuthValidator _authValidator;
  final AuthorizationProvider _authzProvider;

  /// Validate token and get authorization data
  Future<AuthorizationContext> authorize(
    String token, {
    String? resource,
    String? action,
    Map<String, dynamic>? context,
  }) async {
    final authMetadata = await _authValidator.validateToken(token);

    final authzData = await _authzProvider.getAuthorization(
      authMetadata.userId,
      resource: resource,
      action: action,
      context: context,
    );

    return AuthorizationContext(authMetadata, authzData);
  }

  /// Check if token holder has specific permission
  Future<bool> hasPermission(
    String token,
    String permission, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final contextObj = await authorize(
        token,
        resource: resource,
        context: context,
      );
      return contextObj.hasPermission(permission);
    } on Exception {
      return false;
    }
  }

  /// Check if token holder has specific role
  Future<bool> hasRole(
    String token,
    String role, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final contextObj = await authorize(
        token,
        resource: resource,
        context: context,
      );
      return contextObj.hasRole(role);
    } on Exception {
      return false;
    }
  }

  /// Check if token holder has any of the specified permissions
  Future<bool> hasAnyPermission(
    String token,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final contextObj = await authorize(
        token,
        resource: resource,
        context: context,
      );
      return contextObj.hasAnyPermission(permissions);
    } on Exception {
      return false;
    }
  }

  /// Check if token holder has all of the specified permissions
  Future<bool> hasAllPermissions(
    String token,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final contextObj = await authorize(
        token,
        resource: resource,
        context: context,
      );
      return contextObj.hasAllPermissions(permissions);
    } on Exception {
      return false;
    }
  }

  /// Check if token holder has any of the specified roles
  Future<bool> hasAnyRole(
    String token,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final contextObj = await authorize(
        token,
        resource: resource,
        context: context,
      );
      return contextObj.hasAnyRole(roles);
    } on Exception {
      return false;
    }
  }

  /// Check if token holder has all of the specified roles
  Future<bool> hasAllRoles(
    String token,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final contextObj = await authorize(
        token,
        resource: resource,
        context: context,
      );
      return contextObj.hasAllRoles(roles);
    } on Exception {
      return false;
    }
  }

  /// Comprehensive authorization check with multiple criteria
  Future<bool> checkAuthorization(
    String token, {
    String? resource,
    String? action,
    List<String>? requiredRoles,
    List<String>? requiredPermissions,
    bool requireAllRoles = false,
    bool requireAllPermissions = false,
    Map<String, dynamic>? context,
  }) async {
    try {
      final authContext = await authorize(
        token,
        resource: resource,
        action: action,
        context: context,
      );

      if (requiredRoles != null && requiredRoles.isNotEmpty) {
        if (requireAllRoles) {
          if (!authContext.authorization.hasAllRoles(requiredRoles)) {
            return false;
          }
        } else {
          if (!authContext.authorization.hasAnyRole(requiredRoles)) {
            return false;
          }
        }
      }

      if (requiredPermissions != null && requiredPermissions.isNotEmpty) {
        if (requireAllPermissions) {
          if (!authContext.authorization.hasAllPermissions(
            requiredPermissions,
          )) {
            return false;
          }
        } else {
          if (!authContext.authorization.hasAnyPermission(
            requiredPermissions,
          )) {
            return false;
          }
        }
      }

      return true;
    } on Exception {
      return false;
    }
  }

  /// Get user ID from token
  Future<String?> getUserId(String token) async {
    try {
      final authMetadata = await _authValidator.validateToken(token);
      return authMetadata.userId;
    } on Exception {
      return null;
    }
  }

  /// Get user's effective permissions for a resource
  Future<List<String>> getEffectivePermissions(
    String token,
    String resource,
  ) async {
    try {
      final authMetadata = await _authValidator.validateToken(token);
      return await _authzProvider.getEffectivePermissions(
        authMetadata.userId,
        resource,
      );
    } on Exception {
      return [];
    }
  }

  /// Get user's effective roles for a resource
  Future<List<String>> getEffectiveRoles(String token, String resource) async {
    try {
      final authMetadata = await _authValidator.validateToken(token);
      return await _authzProvider.getEffectiveRoles(
        authMetadata.userId,
        resource,
      );
    } on Exception {
      return [];
    }
  }

  /// Batch check multiple permissions
  Future<Map<String, bool>> checkPermissions(
    String token,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final authMetadata = await _authValidator.validateToken(token);
      return await _authzProvider.checkPermissions(
        authMetadata.userId,
        permissions,
        resource: resource,
        context: context,
      );
    } on Exception {
      return Map.fromEntries(permissions.map((perm) => MapEntry(perm, false)));
    }
  }

  /// Batch check multiple roles
  Future<Map<String, bool>> checkRoles(
    String token,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    try {
      final authMetadata = await _authValidator.validateToken(token);
      return await _authzProvider.checkRoles(
        authMetadata.userId,
        roles,
        resource: resource,
        context: context,
      );
    } on Exception {
      return Map.fromEntries(roles.map((role) => MapEntry(role, false)));
    }
  }
}

/// Combined authorization context containing both identity and authorization data
class AuthorizationContext {

  /// Creates authorization context with identity and authorization data
  AuthorizationContext(this.identity, this.authorization);
  
  /// Authentication data from token validation
  final AuthenticationData identity;
  
  /// Authorization data from authorization provider
  final AuthorizationData authorization;

  /// User ID from token
  String get userId => identity.userId;

  /// User roles from token
  List<String> get tokenRoles {
    final rolesClaim = identity.jwt.getClaim<List<dynamic>>(AuthClaims.roles);
    if (rolesClaim is List) {
      return List<String>.from(rolesClaim);
    }
    return <String>[];
  }

  /// User claims from token
  Map<String, dynamic> get claims => identity.claims;

  /// Authorization roles from service
  List<String> get authzRoles => authorization.roles;

  /// Authorization permissions from service
  List<String> get permissions => authorization.permissions;

  /// Authorization attributes from service
  Map<String, dynamic> get attributes => authorization.attributes;

  /// Combined roles from token and authorization service
  List<String> get allRoles => <String>{...tokenRoles, ...authzRoles}.toList();

  /// Check if user has role (checks both token and authorization service)
  bool hasRole(String role) =>
      tokenRoles.contains(role) || authorization.hasRole(role);

  /// Check if user has permission (checks both token and authorization service)
  bool hasPermission(String permission) {
    final permissionsClaim = identity.jwt.getClaim<List<dynamic>>(AuthClaims.permissions);
    final tokenHasPermission = permissionsClaim is List && 
        List<String>.from(permissionsClaim).contains(permission);
    return tokenHasPermission || authorization.hasPermission(permission);
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) => roles.any(hasRole);

  /// Check if user has all of the specified roles
  bool hasAllRoles(List<String> roles) => roles.every(hasRole);

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) =>
      permissions.any(hasPermission);

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissions) =>
      permissions.every(hasPermission);

  /// Get attribute value by key
  T? getAttribute<T>(String key) => authorization.getAttribute<T>(key);

  @override
  String toString() {
    return 'AuthorizationContext(userId: $userId, tokenRoles: $tokenRoles, authzRoles: $authzRoles, permissions: $permissions)';
  }
}
