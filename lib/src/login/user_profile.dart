import 'package:meta/meta.dart';

/// Basic user identity information returned after successful authentication
@immutable
class UserProfile {
  /// Creates a user profile with basic identity information
  const UserProfile({
    required this.userId,
    this.email,
    this.username,
    this.roles = const [],
    this.permissions = const [],
    this.claims = const {},
  });

  /// Create from map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'] as String,
      email: map['email'] as String?,
      username: map['username'] as String?,
      roles: List<String>.from(map['roles'] as List? ?? []),
      permissions: List<String>.from(map['permissions'] as List? ?? []),
      claims: Map<String, dynamic>.from(map['claims'] as Map? ?? {}),
    );
  }

  /// Unique user identifier
  final String userId;

  /// User's email address (if available)
  final String? email;

  /// User's username (if available)
  final String? username;

  /// User's roles for authorization
  final List<String> roles;

  /// User's permissions for authorization
  final List<String> permissions;

  /// Additional claims/metadata from the authentication provider
  final Map<String, dynamic> claims;

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roleList) =>
      roleList.any(roles.contains);

  /// Check if user has all of the specified roles
  bool hasAllRoles(List<String> roleList) =>
      roleList.every(roles.contains);

  /// Check if user has a specific permission
  bool hasPermission(String permission) => permissions.contains(permission);

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissionList) =>
      permissionList.any(permissions.contains);

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissionList) =>
      permissionList.every(permissions.contains);

  /// Get a claim value by key
  T? getClaim<T>(String key) => claims[key] as T?;

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? userId,
    String? email,
    String? username,
    List<String>? roles,
    List<String>? permissions,
    Map<String, dynamic>? claims,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      claims: claims ?? this.claims,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      'roles': roles,
      'permissions': permissions,
      'claims': claims,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'UserProfile(userId: $userId, email: $email)';
}
