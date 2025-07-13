import 'package:kiss_auth/src/authorization_data.dart';
import 'package:kiss_auth/src/authorization_provider.dart';

/// In-memory authorization provider for testing and development
class InMemoryAuthorizationProvider implements AuthorizationProvider {
  final Map<String, AuthorizationData> _userData = {};

  /// Add or update authorization data for a user
  void setUserData(String userId, AuthorizationData data) {
    _userData[userId] = data;
  }

  /// Remove authorization data for a user
  void removeUserData(String userId) {
    _userData.remove(userId);
  }

  /// Clear all user data
  void clear() {
    _userData.clear();
  }

  /// Get all stored user IDs
  List<String> get userIds => _userData.keys.toList();

  @override
  Future<AuthorizationData> getAuthorization(
    String userId, {
    String? resource,
    String? action,
    Map<String, dynamic>? context,
  }) async {
    final data = _userData[userId];
    if (data == null) {
      return AuthorizationData(
        userId: userId,
        roles: [],
        permissions: [],
        attributes: {},
      );
    }
    return data;
  }

  @override
  Future<bool> hasPermission(
    String userId,
    String permission, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return data.hasPermission(permission);
  }

  @override
  Future<bool> hasRole(
    String userId,
    String role, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return data.hasRole(role);
  }

  @override
  Future<Map<String, bool>> checkPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return Map.fromEntries(
      permissions.map(
        (permission) => MapEntry(permission, data.hasPermission(permission)),
      ),
    );
  }

  @override
  Future<Map<String, bool>> checkRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return Map.fromEntries(
      roles.map((role) => MapEntry(role, data.hasRole(role))),
    );
  }

  @override
  Future<List<String>> getEffectivePermissions(
    String userId,
    String resource,
  ) async {
    final data = await getAuthorization(userId, resource: resource);
    return data.permissions;
  }

  @override
  Future<List<String>> getEffectiveRoles(String userId, String resource) async {
    final data = await getAuthorization(userId, resource: resource);
    return data.roles;
  }

  @override
  Future<bool> hasAnyPermission(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return data.hasAnyPermission(permissions);
  }

  @override
  Future<bool> hasAllPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return data.hasAllPermissions(permissions);
  }

  @override
  Future<bool> hasAnyRole(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return data.hasAnyRole(roles);
  }

  @override
  Future<bool> hasAllRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final data = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return data.hasAllRoles(roles);
  }
}
