import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/kiss_authorization.dart';
import 'package:test/test.dart';

void main() {
  group('Authorization Tests', () {
    late InMemoryAuthorizationProvider provider;

    setUp(() {
      provider = InMemoryAuthorizationProvider();
      setupTestData(provider);
    });

    group('InMemoryAuthorizationProvider', () {
      test('should return empty data for unknown user', () async {
        final data = await provider.getAuthorization('unknown_user');

        expect(data.userId, equals('unknown_user'));
        expect(data.roles, isEmpty);
        expect(data.permissions, isEmpty);
        expect(data.attributes, isEmpty);
      });

      test('should return correct data for known user', () async {
        final data = await provider.getAuthorization('admin123');

        expect(data.userId, equals('admin123'));
        expect(data.roles, containsAll(['admin', 'manager']));
        expect(
          data.permissions,
          containsAll([
            'user:create',
            'user:delete',
            'user:read',
            'user:update',
          ]),
        );
        expect(data.getAttribute<String>('department'), equals('IT'));
      });

      test('should handle role checks correctly', () async {
        expect(await provider.hasRole('admin123', 'admin'), isTrue);
        expect(await provider.hasRole('admin123', 'manager'), isTrue);
        expect(await provider.hasRole('admin123', 'user'), isFalse);
        expect(await provider.hasRole('user456', 'user'), isTrue);
        expect(await provider.hasRole('user456', 'admin'), isFalse);
      });

      test('should handle permission checks correctly', () async {
        expect(await provider.hasPermission('admin123', 'user:create'), isTrue);
        expect(await provider.hasPermission('admin123', 'user:delete'), isTrue);
        expect(
          await provider.hasPermission('admin123', 'content:edit'),
          isFalse,
        );
        expect(await provider.hasPermission('user456', 'user:read'), isTrue);
        expect(await provider.hasPermission('user456', 'user:create'), isFalse);
      });

      test('should handle batch permission checks', () async {
        final results = await provider.checkPermissions('admin123', [
          'user:create',
          'user:delete',
          'user:read',
          'content:edit', // Admin doesn't have this
        ]);

        expect(results['user:create'], isTrue);
        expect(results['user:delete'], isTrue);
        expect(results['user:read'], isTrue);
        expect(results['content:edit'], isFalse);
      });

      test('should handle batch role checks', () async {
        final results = await provider.checkRoles('editor789', [
          'editor',
          'user',
          'admin', // Editor doesn't have this
        ]);

        expect(results['editor'], isTrue);
        expect(results['user'], isTrue);
        expect(results['admin'], isFalse);
      });

      test('should handle any permission checks', () async {
        expect(
          await provider.hasAnyPermission('editor789', [
            'content:read',
            'content:edit',
          ]),
          isTrue,
        );
        expect(
          await provider.hasAnyPermission('editor789', [
            'content:read',
            'user:create',
          ]),
          isTrue,
        );
        expect(
          await provider.hasAnyPermission('editor789', [
            'user:create',
            'user:delete',
          ]),
          isFalse,
        );
      });

      test('should handle all permission checks', () async {
        expect(
          await provider.hasAllPermissions('admin123', [
            'user:create',
            'user:read',
          ]),
          isTrue,
        );
        expect(
          await provider.hasAllPermissions('admin123', [
            'user:create',
            'user:read',
            'user:update',
          ]),
          isTrue,
        );
        expect(
          await provider.hasAllPermissions('admin123', [
            'user:create',
            'content:edit',
          ]),
          isFalse,
        );
      });

      test('should handle any role checks', () async {
        expect(
          await provider.hasAnyRole('editor789', ['editor', 'user']),
          isTrue,
        );
        expect(
          await provider.hasAnyRole('editor789', ['editor', 'admin']),
          isTrue,
        );
        expect(
          await provider.hasAnyRole('editor789', ['admin', 'manager']),
          isFalse,
        );
      });

      test('should handle all role checks', () async {
        expect(
          await provider.hasAllRoles('editor789', ['editor', 'user']),
          isTrue,
        );
        expect(
          await provider.hasAllRoles('admin123', ['admin', 'manager']),
          isTrue,
        );
        expect(
          await provider.hasAllRoles('editor789', ['editor', 'admin']),
          isFalse,
        );
      });

      test('should get effective permissions', () async {
        final permissions = await provider.getEffectivePermissions(
          'editor789',
          'content',
        );
        expect(
          permissions,
          containsAll(['content:read', 'content:edit', 'content:publish']),
        );
      });

      test('should get effective roles', () async {
        final roles = await provider.getEffectiveRoles('admin123', 'users');
        expect(roles, containsAll(['admin', 'manager']));
      });

      test('should handle data updates', () async {
        // Initially user456 has only 'user' role
        expect(await provider.hasRole('user456', 'editor'), isFalse);

        // Update user data
        provider.setUserData(
          'user456',
          const AuthorizationData(
            userId: 'user456',
            roles: ['user', 'editor'],
            permissions: ['user:read', 'content:read'],
            attributes: {'department': 'Sales', 'level': 'mid'},
          ),
        );

        // Check updated data
        expect(await provider.hasRole('user456', 'editor'), isTrue);
        expect(await provider.hasPermission('user456', 'content:read'), isTrue);

        final data = await provider.getAuthorization('user456');
        expect(data.roles, containsAll(['user', 'editor']));
        expect(data.permissions, containsAll(['user:read', 'content:read']));
        expect(data.getAttribute<String>('level'), equals('mid'));
      });

      test('should handle data removal', () async {
        expect(await provider.hasRole('admin123', 'admin'), isTrue);

        provider.removeUserData('admin123');

        expect(await provider.hasRole('admin123', 'admin'), isFalse);
        final data = await provider.getAuthorization('admin123');
        expect(data.roles, isEmpty);
        expect(data.permissions, isEmpty);
      });

      test('should handle clear all data', () async {
        expect(
          provider.userIds,
          containsAll(['admin123', 'user456', 'editor789']),
        );

        provider.clear();

        expect(provider.userIds, isEmpty);
        expect(await provider.hasRole('admin123', 'admin'), isFalse);
        expect(await provider.hasRole('user456', 'user'), isFalse);
        expect(await provider.hasRole('editor789', 'editor'), isFalse);
      });
    });

    group('AuthorizationClient', () {
      late AuthorizationClient client;

      setUp(() {
        client = AuthorizationClient(provider);
      });

      test('should delegate to provider correctly', () async {
        final data = await client.getAuthorization('admin123');
        expect(data.userId, equals('admin123'));
        expect(data.roles, containsAll(['admin', 'manager']));
      });

      test('should handle permission checks', () async {
        expect(await client.hasPermission('admin123', 'user:create'), isTrue);
        expect(await client.hasPermission('user456', 'user:create'), isFalse);
      });

      test('should handle role checks', () async {
        expect(await client.hasRole('admin123', 'admin'), isTrue);
        expect(await client.hasRole('user456', 'admin'), isFalse);
      });

      test('should handle batch operations', () async {
        final permissionResults = await client.checkPermissions('editor789', [
          'content:read',
          'content:edit',
          'user:create',
        ]);

        expect(permissionResults['content:read'], isTrue);
        expect(permissionResults['content:edit'], isTrue);
        expect(permissionResults['user:create'], isFalse);
      });
    });

    group('AuthorizationService with JWT', () {
      late AuthorizationService service;
      late JwtAuthValidator authValidator;

      setUp(() {
        authValidator = JwtAuthValidator.hmac('test-secret');
        service = AuthorizationService(authValidator, provider);
      });

      test('should combine JWT and provider data', () async {
        // Create a JWT token
        final token = createTestToken('admin123', ['user']);

        final context = await service.authorize(token);

        expect(context.userId, equals('admin123'));
        expect(context.tokenRoles, contains('user'));
        expect(context.authzRoles, containsAll(['admin', 'manager']));
        expect(context.allRoles, containsAll(['user', 'admin', 'manager']));
        expect(
          context.permissions,
          containsAll([
            'user:create',
            'user:delete',
            'user:read',
            'user:update',
          ]),
        );
      });

      test('should handle permission checks with JWT', () async {
        final token = createTestToken('editor789', ['user']);

        expect(await service.hasPermission(token, 'content:edit'), isTrue);
        expect(await service.hasPermission(token, 'user:create'), isFalse);
      });

      test('should handle role checks with JWT', () async {
        final token = createTestToken('admin123', ['user']);

        expect(await service.hasRole(token, 'admin'), isTrue);
        expect(await service.hasRole(token, 'user'), isTrue);
        expect(await service.hasRole(token, 'manager'), isTrue);
      });

      test('should handle batch operations with JWT', () async {
        final token = createTestToken('editor789', ['user']);

        final permissionResults = await service.checkPermissions(token, [
          'content:read',
          'content:edit',
          'user:create',
        ]);

        expect(permissionResults['content:read'], isTrue);
        expect(permissionResults['content:edit'], isTrue);
        expect(permissionResults['user:create'], isFalse);
      });

      test('should handle comprehensive authorization checks', () async {
        final token = createTestToken('admin123', ['user']);

        final result = await service.checkAuthorization(
          token,
          requiredRoles: ['admin'],
          requiredPermissions: ['user:create'],
        );

        expect(result, isTrue);
      });

      test('should fail authorization with insufficient permissions', () async {
        final token = createTestToken('user456', ['user']);

        final result = await service.checkAuthorization(
          token,
          requiredRoles: ['admin'],
          requiredPermissions: ['user:create'],
        );

        expect(result, isFalse);
      });

      test('should handle invalid tokens gracefully', () async {
        const invalidToken = 'invalid.jwt.token';

        expect(
          await service.hasPermission(invalidToken, 'user:create'),
          isFalse,
        );
        expect(await service.hasRole(invalidToken, 'admin'), isFalse);
      });
    });
  });
}

void setupTestData(InMemoryAuthorizationProvider provider) {
  // Admin user
  provider
    ..setUserData(
      'admin123',
      const AuthorizationData(
        userId: 'admin123',
        roles: ['admin', 'manager'],
        permissions: ['user:create', 'user:delete', 'user:read', 'user:update'],
        attributes: {'department': 'IT', 'level': 'senior'},
      ),
    )
    // Regular user
    ..setUserData(
      'user456',
      const AuthorizationData(
        userId: 'user456',
        roles: ['user'],
        permissions: ['user:read'],
        attributes: {'department': 'Sales', 'level': 'junior'},
      ),
    )
    // Editor user
    ..setUserData(
      'editor789',
      const AuthorizationData(
        userId: 'editor789',
        roles: ['editor', 'user'],
        permissions: ['content:read', 'content:edit', 'content:publish'],
        attributes: {'department': 'Marketing', 'level': 'mid'},
      ),
    );
}

String createTestToken(
  String userId,
  List<String> roles, {
  String secret = 'test-secret',
}) {
  final jwt = JWT({
    'sub': userId,
    'roles': roles,
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'exp':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
  }, issuer: 'kiss_auth_test');
  return jwt.sign(SecretKey(secret));
}
