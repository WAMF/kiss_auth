import 'package:kiss_auth/src/authorization_data.dart';

/// Abstract interface for authorization providers
abstract class AuthorizationProvider {
  /// Get user's current authorization data
  Future<AuthorizationData> getAuthorization(
    String userId, {
    String? resource,
    String? action,
    Map<String, dynamic>? context,
  });

  /// Check if user has specific permission
  Future<bool> hasPermission(
    String userId,
    String permission, {
    String? resource,
    Map<String, dynamic>? context,
  });

  /// Check if user has specific role
  Future<bool> hasRole(
    String userId,
    String role, {
    String? resource,
    Map<String, dynamic>? context,
  });

  /// Batch check multiple permissions
  Future<Map<String, bool>> checkPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  });

  /// Batch check multiple roles
  Future<Map<String, bool>> checkRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  });

  /// Get user's effective permissions for a resource
  Future<List<String>> getEffectivePermissions(String userId, String resource);

  /// Get user's effective roles for a resource
  Future<List<String>> getEffectiveRoles(String userId, String resource);

  /// Check if user has any of the specified permissions
  Future<bool> hasAnyPermission(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  });

  /// Check if user has all of the specified permissions
  Future<bool> hasAllPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  });

  /// Check if user has any of the specified roles
  Future<bool> hasAnyRole(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  });

  /// Check if user has all of the specified roles
  Future<bool> hasAllRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  });
}
