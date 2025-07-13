import 'package:kiss_auth/src/authorization_data.dart';
import 'package:kiss_auth/src/authorization_provider.dart';

/// Client-side authorization manager
class AuthorizationClient {

  /// Creates an authorization client with the given provider
  AuthorizationClient(this._provider);
  final AuthorizationProvider _provider;

  /// Get authorization data for a user
  Future<AuthorizationData> getAuthorization(
    String userId, {
    String? resource,
    String? action,
    Map<String, dynamic>? context,
  }) async {
    return _provider.getAuthorization(
      userId,
      resource: resource,
      action: action,
      context: context,
    );
  }

  /// Check if user has specific permission
  Future<bool> hasPermission(
    String userId,
    String permission, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.hasPermission(
      userId,
      permission,
      resource: resource,
      context: context,
    );
  }

  /// Check if user has specific role
  Future<bool> hasRole(
    String userId,
    String role, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.hasRole(
      userId,
      role,
      resource: resource,
      context: context,
    );
  }

  /// Batch check multiple permissions
  Future<Map<String, bool>> checkPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.checkPermissions(
      userId,
      permissions,
      resource: resource,
      context: context,
    );
  }

  /// Batch check multiple roles
  Future<Map<String, bool>> checkRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.checkRoles(
      userId,
      roles,
      resource: resource,
      context: context,
    );
  }

  /// Get user's effective permissions for a resource
  Future<List<String>> getEffectivePermissions(
    String userId,
    String resource,
  ) async {
    return _provider.getEffectivePermissions(userId, resource);
  }

  /// Get user's effective roles for a resource
  Future<List<String>> getEffectiveRoles(String userId, String resource) async {
    return _provider.getEffectiveRoles(userId, resource);
  }

  /// Check if user has any of the specified permissions
  Future<bool> hasAnyPermission(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.hasAnyPermission(
      userId,
      permissions,
      resource: resource,
      context: context,
    );
  }

  /// Check if user has all of the specified permissions
  Future<bool> hasAllPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.hasAllPermissions(
      userId,
      permissions,
      resource: resource,
      context: context,
    );
  }

  /// Check if user has any of the specified roles
  Future<bool> hasAnyRole(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.hasAnyRole(
      userId,
      roles,
      resource: resource,
      context: context,
    );
  }

  /// Check if user has all of the specified roles
  Future<bool> hasAllRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    return _provider.hasAllRoles(
      userId,
      roles,
      resource: resource,
      context: context,
    );
  }
}
