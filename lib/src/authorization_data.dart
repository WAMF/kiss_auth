/// Represents authorization data for a user
class AuthorizationData {

  /// Creates authorization data for a user
  const AuthorizationData({
    required this.userId,
    required this.roles,
    required this.permissions,
    this.attributes = const {},
    this.expiresAt,
    this.resource,
    this.action,
  });
  
  /// User identifier
  final String userId;
  
  /// List of roles assigned to the user
  final List<String> roles;
  
  /// List of permissions granted to the user
  final List<String> permissions;
  
  /// Additional attributes associated with the authorization
  final Map<String, dynamic> attributes;
  
  /// Optional expiration time for the authorization
  final DateTime? expiresAt;
  
  /// Optional resource context for the authorization
  final String? resource;
  
  /// Optional action context for the authorization
  final String? action;

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user has a specific permission
  bool hasPermission(String permission) => permissions.contains(permission);

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) =>
      roles.any((role) => this.roles.contains(role));

  /// Check if user has all of the specified roles
  bool hasAllRoles(List<String> roles) =>
      roles.every((role) => this.roles.contains(role));

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) =>
      permissions.any((perm) => this.permissions.contains(perm));

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissions) =>
      permissions.every((perm) => this.permissions.contains(perm));

  /// Check if authorization has expired
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Check if this authorization is valid (not expired)
  bool get isValid => !isExpired;

  /// Get attribute value by key
  T? getAttribute<T>(String key) => attributes[key] as T?;

  /// Create a copy with updated values
  AuthorizationData copyWith({
    String? userId,
    List<String>? roles,
    List<String>? permissions,
    Map<String, dynamic>? attributes,
    DateTime? expiresAt,
    String? resource,
    String? action,
  }) {
    return AuthorizationData(
      userId: userId ?? this.userId,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      attributes: attributes ?? this.attributes,
      expiresAt: expiresAt ?? this.expiresAt,
      resource: resource ?? this.resource,
      action: action ?? this.action,
    );
  }

  @override
  String toString() {
    return 'AuthorizationData(userId: $userId, roles: $roles, permissions: $permissions, resource: $resource, action: $action)';
  }

}
