import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/kiss_authentication.dart';
import 'package:kiss_auth/kiss_authorization.dart';

Future<void> main() async {
  print('=== Kiss Auth Separation Example ===\n');

  // Example 1: Authentication Only
  await authenticationOnlyExample();

  print('\n${'=' * 60}\n');

  // Example 2: Authorization Only (simulated)
  await authorizationOnlyExample();

  print('\n${'=' * 60}\n');

  // Example 3: Combined Usage
  await combinedUsageExample();
}

/// Example showing pure authentication without authorization services
Future<void> authenticationOnlyExample() async {
  print('1. AUTHENTICATION ONLY - JWT Token Validation');
  print('===============================================');
  print('Use case: Simple app that only needs token validation');
  print("Import: import 'package:kiss_auth/kiss_authentication.dart';");
  print('');

  const secretKey = 'my-secret-key';
  final validator = JwtAuthValidator.hmac(secretKey);

  // Create a JWT token with basic claims
  final jwt = JWT({
    'sub': 'user123',
    'email': 'user@example.com',
    'roles': ['user', 'editor'],
    'permissions': ['read', 'write'],
    'exp':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
  });

  final token = jwt.sign(SecretKey(secretKey));

  try {
    // Only authentication - no external services
    final metadata = await validator.validateToken(token);

    final roles = metadata.jwt.getClaim<List<dynamic>>('roles')?.cast<String>() ?? <String>[];
    final permissions = metadata.jwt.getClaim<List<dynamic>>('permissions')?.cast<String>() ?? <String>[];
    
    print('✅ Token validation successful!');
    print('   User ID: ${metadata.userId}');
    print('   Email: ${metadata.claims['email']}');
    print('   Roles from JWT: $roles');
    print('');
    print('📝 Simple authorization checks from JWT claims:');
    print('   Is user: ${roles.contains('user')}');
    print('   Is admin: ${roles.contains('admin')}');
    print('   Can read: ${permissions.contains('read')}');
    print('   Can delete: ${permissions.contains('delete')}');
    print('');
    print('💡 Perfect for: Simple apps, microservices, basic RBAC');
  } on Exception catch (e) {
    print('❌ Authentication failed: $e');
  }
}

/// Example showing pure authorization without authentication
Future<void> authorizationOnlyExample() async {
  print('2. AUTHORIZATION ONLY - External Service Integration');
  print('====================================================');
  print(
    'Use case: You have your own authentication, need complex authorization',
  );
  print("Import: import 'package:kiss_auth/kiss_authorization.dart';");
  print('');

  // Simulate an external authorization service
  final authzProvider = MockAuthorizationProvider();
  final authzClient = AuthorizationClient(authzProvider);

  const userId = 'user123';
  const resource = 'documents';

  try {
    print('🔍 Checking authorization for user: $userId');

    // Get comprehensive authorization data
    final authzData = await authzClient.getAuthorization(
      userId,
      resource: resource,
      action: 'edit',
    );

    print('✅ Authorization data retrieved from service!');
    print('   User ID: ${authzData.userId}');
    print('   Service roles: ${authzData.roles}');
    print('   Permissions: ${authzData.permissions}');
    print('   Resource: ${authzData.resource}');
    print('');
    print('📊 Advanced authorization checks:');
    print('   Can edit documents: ${authzData.hasPermission('document:edit')}');
    print(
      '   Can delete documents: ${authzData.hasPermission('document:delete')}',
    );
    print('   Is manager: ${authzData.hasRole('manager')}');
    print('   Department: ${authzData.getAttribute<String>('department')}');
    print('');
    print(
      '💡 Perfect for: Complex RBAC, external services, context-aware permissions',
    );
  } on Exception catch (e) {
    print('❌ Authorization failed: $e');
  }
}

/// Example showing authentication and authorization working together
Future<void> combinedUsageExample() async {
  print('3. COMBINED USAGE - Best of Both Worlds');
  print('=======================================');
  print('Use case: Full-stack app with JWT auth + external authorization');
  print("Import: import 'package:kiss_auth/kiss_authorization.dart';");
  print('');

  // Setup both authentication and authorization
  const secretKey = 'my-secret-key';
  final authValidator = JwtAuthValidator.hmac(secretKey);
  final authzProvider = MockAuthorizationProvider();
  final authzService = AuthorizationService(authValidator, authzProvider);

  // Create a JWT token
  final jwt = JWT({
    'sub': 'user123',
    'email': 'user@example.com',
    'roles': ['user'], // Basic role in JWT
    'permissions': ['read'], // Basic permission in JWT
    'exp':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
  });

  final token = jwt.sign(SecretKey(secretKey));

  try {
    print('🔐 Validating token AND checking authorization...');

    // Get complete authorization context
    final context = await authzService.authorize(
      token,
      resource: 'documents',
      action: 'edit',
    );

    print('✅ Authentication and authorization successful!');
    print('');
    print('👤 Identity (from JWT):');
    print('   User ID: ${context.userId}');
    print('   Email: ${context.claims['email']}');
    print('   JWT roles: ${context.tokenRoles}');
    print('');
    print('🎭 Authorization (from service):');
    print('   Service roles: ${context.authzRoles}');
    print('   Permissions: ${context.permissions}');
    print('   All roles combined: ${context.allRoles}');
    print('');
    print('🔒 Comprehensive authorization checks:');
    final jwtRoles = context.identity.jwt.getClaim<List<dynamic>>('roles')?.cast<String>() ?? <String>[];
    print('   Has user role (JWT): ${jwtRoles.contains('user')}');
    print(
      '   Has manager role (service): ${context.authorization.hasRole('manager')}',
    );
    print('   Has any admin role: ${context.hasRole('admin')}');
    print('   Can edit documents: ${context.hasPermission('document:edit')}');
    print('   Can read (JWT or service): ${context.hasPermission('read')}');
    print('');
    print('🚀 Advanced use case:');
    final canManageTeam = await authzService.checkAuthorization(
      token,
      resource: 'team',
      requiredRoles: ['manager'],
      requiredPermissions: ['team:manage'],
    );
    print('   Can manage team: $canManageTeam');
  } on Exception catch (e) {
    print('❌ Combined authentication/authorization failed: $e');
  }
}

/// Mock authorization service for demonstration
class MockAuthorizationProvider implements AuthorizationProvider {
  @override
  Future<AuthorizationData> getAuthorization(
    String userId, {
    String? resource,
    String? action,
    Map<String, dynamic>? context,
  }) async {
    // Simulate API call delay
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Simulate different authorization data based on user
    if (userId == 'user123') {
      return AuthorizationData(
        userId: userId,
        roles: ['manager', 'editor'],
        permissions: ['document:edit', 'document:delete', 'team:manage'],
        attributes: {
          'department': 'engineering',
          'level': 'senior',
          'region': 'us-west',
        },
        resource: resource,
        action: action,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
    }

    return AuthorizationData(
      userId: userId,
      roles: ['user'],
      permissions: ['read'],
      resource: resource,
      action: action,
    );
  }

  @override
  Future<bool> hasPermission(
    String userId,
    String permission, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return authz.hasPermission(permission);
  }

  @override
  Future<bool> hasRole(
    String userId,
    String role, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return authz.hasRole(role);
  }

  @override
  Future<Map<String, bool>> checkPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return Map.fromEntries(
      permissions.map((perm) => MapEntry(perm, authz.hasPermission(perm))),
    );
  }

  @override
  Future<Map<String, bool>> checkRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return Map.fromEntries(
      roles.map((role) => MapEntry(role, authz.hasRole(role))),
    );
  }

  @override
  Future<List<String>> getEffectivePermissions(
    String userId,
    String resource,
  ) async {
    final authz = await getAuthorization(userId, resource: resource);
    return authz.permissions;
  }

  @override
  Future<List<String>> getEffectiveRoles(String userId, String resource) async {
    final authz = await getAuthorization(userId, resource: resource);
    return authz.roles;
  }

  @override
  Future<bool> hasAnyPermission(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return authz.hasAnyPermission(permissions);
  }

  @override
  Future<bool> hasAllPermissions(
    String userId,
    List<String> permissions, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return authz.hasAllPermissions(permissions);
  }

  @override
  Future<bool> hasAnyRole(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return authz.hasAnyRole(roles);
  }

  @override
  Future<bool> hasAllRoles(
    String userId,
    List<String> roles, {
    String? resource,
    Map<String, dynamic>? context,
  }) async {
    final authz = await getAuthorization(
      userId,
      resource: resource,
      context: context,
    );
    return authz.hasAllRoles(roles);
  }
}
