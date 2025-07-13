import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/kiss_authorization.dart';
import 'package:test/test.dart';

void main() {
  group('Authorization Tests', () {
    // Test InMemoryAuthorizationProvider using reusable test suite
    group('InMemoryAuthorizationProvider', () {
      generateTests(provider: () {
        final provider = InMemoryAuthorizationProvider();
        setupTestData(provider);
        return provider;
      });
    });

    // Example: Test a different provider (uncomment to use)
    // group('CustomAuthorizationProvider', () {
    //   generateTests(provider: () {
    //     final provider = CustomAuthorizationProvider();
    //     setupCustomTestData(provider);
    //     return provider;
    //   });
    // });

    // Additional provider-specific tests for InMemoryAuthorizationProvider
    group('InMemoryAuthorizationProvider - Specific Tests', () {
      late InMemoryAuthorizationProvider provider;

      setUp(() {
        provider = InMemoryAuthorizationProvider();
        setupTestData(provider);
      });

      test('should handle data updates', () async {
        provider.setUserData(
          'admin123',
          const AuthorizationData(
            userId: 'admin123',
            roles: ['admin', 'manager', 'supervisor'],
            permissions: [
              'user:create',
              'user:delete',
              'user:read',
              'user:update',
              'audit:view',
            ],
            attributes: {'department': 'IT', 'region': 'US'},
          ),
        );

        final data = await provider.getAuthorization('admin123');
        expect(data.roles, contains('supervisor'));
        expect(data.permissions, contains('audit:view'));
        expect(data.getAttribute<String>('region'), equals('US'));
      });

      test('should handle data removal', () async {
        provider.removeUserData('admin123');

        final data = await provider.getAuthorization('admin123');
        expect(data.roles, isEmpty);
        expect(data.permissions, isEmpty);
      });

      test('should handle clear all data', () async {
        provider.clear();

        final adminData = await provider.getAuthorization('admin123');
        final userData = await provider.getAuthorization('user456');

        expect(adminData.roles, isEmpty);
        expect(userData.roles, isEmpty);
      });
    });

    group('InMemoryAuthorizationProvider direct usage', () {
      late InMemoryAuthorizationProvider provider;

      setUp(() {
        provider = InMemoryAuthorizationProvider();
        setupTestData(provider);
      });

      test('should work directly without client wrapper', () async {
        final data = await provider.getAuthorization('admin123');
        expect(data.userId, equals('admin123'));
        expect(data.roles, containsAll(['admin', 'manager']));
      });

      test('should handle permission checks', () async {
        expect(await provider.hasPermission('admin123', 'user:create'), isTrue);
        expect(await provider.hasPermission('user456', 'user:create'), isFalse);
      });

      test('should handle role checks', () async {
        expect(await provider.hasRole('admin123', 'admin'), isTrue);
        expect(await provider.hasRole('user456', 'admin'), isFalse);
      });

      test('should handle batch operations', () async {
        final permissionResults = await provider.checkPermissions(
          'admin123',
          ['user:create', 'user:delete', 'unknown:permission'],
        );

        expect(permissionResults['user:create'], isTrue);
        expect(permissionResults['user:delete'], isTrue);
        expect(permissionResults['unknown:permission'], isFalse);
      });
    });

    group('AuthorizationService with JWT', () {
      late JwtAuthValidator authValidator;
      late InMemoryAuthorizationProvider authzProvider;
      late AuthorizationService authzService;

      setUp(() {
        authValidator = JwtAuthValidator.hmac('test-secret');
        authzProvider = InMemoryAuthorizationProvider();
        setupTestData(authzProvider);
        authzService = AuthorizationService(authValidator, authzProvider);
      });

      test('should combine JWT and provider data', () async {
        final token = JWT({
          'sub': 'admin123',
          'roles': ['user'],
          'permissions': ['read'],
        }).sign(SecretKey('test-secret'));

        final context = await authzService.authorize(
          token,
          resource: 'users',
          action: 'create',
        );

        expect(context.userId, equals('admin123'));
        expect(context.tokenRoles, equals(['user']));
        expect(context.authzRoles, containsAll(['admin', 'manager']));
        expect(context.allRoles, containsAll(['user', 'admin', 'manager']));
      });

      test('should handle permission checks with JWT', () async {
        final token = JWT({
          'sub': 'admin123',
          'permissions': ['read'],
        }).sign(SecretKey('test-secret'));

        expect(
          await authzService.hasPermission(token, 'user:create'),
          isTrue,
        );
        expect(await authzService.hasPermission(token, 'read'), isTrue);
      });

      test('should handle role checks with JWT', () async {
        final token = JWT({
          'sub': 'admin123',
          'roles': ['user'],
        }).sign(SecretKey('test-secret'));

        expect(await authzService.hasRole(token, 'admin'), isTrue);
        expect(await authzService.hasRole(token, 'user'), isTrue);
        expect(await authzService.hasRole(token, 'unknown'), isFalse);
      });

      test('should handle batch operations with JWT', () async {
        final token = JWT({
          'sub': 'admin123',
          'roles': ['user'],
          'permissions': ['read'],
        }).sign(SecretKey('test-secret'));

        final result = await authzService.checkAuthorization(
          token,
          resource: 'users',
          requiredRoles: ['admin'],
          requiredPermissions: ['user:create'],
        );

        expect(result, isTrue);
      });

      test('should handle comprehensive authorization checks', () async {
        final token = JWT({
          'sub': 'admin123',
          'roles': ['user'],
          'permissions': ['read'],
        }).sign(SecretKey('test-secret'));

        final context = await authzService.authorize(
          token,
          resource: 'users',
          action: 'create',
        );

        expect(context.hasRole('admin'), isTrue);
        expect(context.hasRole('user'), isTrue);
        expect(context.hasPermission('user:create'), isTrue);
        expect(context.hasPermission('read'), isTrue);
      });

      test('should fail authorization with insufficient permissions', () async {
        final token = JWT({
          'sub': 'user456',
          'roles': ['user'],
        }).sign(SecretKey('test-secret'));

        final result = await authzService.checkAuthorization(
          token,
          resource: 'admin',
          requiredRoles: ['admin'],
          requiredPermissions: ['admin:manage'],
        );

        expect(result, isFalse);
      });

      test('should handle invalid tokens gracefully', () async {
        expect(
          await authzService.hasPermission('invalid-token', 'user:create'),
          isFalse,
        );
        expect(await authzService.hasRole('invalid-token', 'admin'), isFalse);

        final result = await authzService.checkAuthorization(
          'invalid-token',
          resource: 'users',
          requiredRoles: ['admin'],
        );
        expect(result, isFalse);
      });
    });
  });
}

/// Generate reusable test suite for any AuthorizationProvider implementation
void generateTests({required AuthorizationProvider Function() provider}) {
  late AuthorizationProvider authProvider;

  setUp(() {
    authProvider = provider();
  });

    test('should return empty data for unknown user', () async {
      final data = await authProvider.getAuthorization('unknown_user');

      expect(data.userId, equals('unknown_user'));
      expect(data.roles, isEmpty);
      expect(data.permissions, isEmpty);
      expect(data.attributes, isEmpty);
    });

    test('should return correct data for known user', () async {
      final data = await authProvider.getAuthorization('admin123');

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
      expect(await authProvider.hasRole('admin123', 'admin'), isTrue);
      expect(await authProvider.hasRole('admin123', 'manager'), isTrue);
      expect(await authProvider.hasRole('admin123', 'user'), isFalse);
      expect(await authProvider.hasRole('user456', 'user'), isTrue);
      expect(await authProvider.hasRole('user456', 'admin'), isFalse);
    });

    test('should handle permission checks correctly', () async {
      expect(await authProvider.hasPermission('admin123', 'user:create'), isTrue);
      expect(
        await authProvider.hasPermission('admin123', 'user:delete'),
        isTrue,
      );
      expect(
        await authProvider.hasPermission('admin123', 'content:edit'),
        isFalse,
      );
      expect(await authProvider.hasPermission('user456', 'user:read'), isTrue);
      expect(await authProvider.hasPermission('user456', 'user:create'), isFalse);
    });

    test('should handle batch permission checks', () async {
      final results = await authProvider.checkPermissions(
        'admin123',
        ['user:create', 'user:delete', 'user:read', 'content:edit'],
      );

      expect(results['user:create'], isTrue);
      expect(results['user:delete'], isTrue);
      expect(results['user:read'], isTrue);
      expect(results['content:edit'], isFalse);
    });

    test('should handle batch role checks', () async {
      final results = await authProvider.checkRoles(
        'admin123',
        ['admin', 'manager', 'user', 'editor'],
      );

      expect(results['admin'], isTrue);
      expect(results['manager'], isTrue);
      expect(results['user'], isFalse);
      expect(results['editor'], isFalse);
    });

    test('should handle any permission checks', () async {
      expect(
        await authProvider.hasAnyPermission('admin123', ['user:create', 'unknown']),
        isTrue,
      );
      expect(
        await authProvider.hasAnyPermission('admin123', ['unknown1', 'unknown2']),
        isFalse,
      );
      expect(
        await authProvider.hasAnyPermission('user456', ['user:read', 'user:write']),
        isTrue,
      );
      expect(
        await authProvider.hasAnyPermission('user456', ['admin:create']),
        isFalse,
      );
    });

    test('should handle all permission checks', () async {
      expect(
        await authProvider.hasAllPermissions('admin123', [
          'user:create',
          'user:delete',
        ]),
        isTrue,
      );
      expect(
        await authProvider.hasAllPermissions('admin123', [
          'user:create',
          'unknown',
        ]),
        isFalse,
      );
      expect(
        await authProvider.hasAllPermissions('user456', ['user:read']),
        isTrue,
      );
      expect(
        await authProvider.hasAllPermissions('user456', [
          'user:read',
          'user:create',
        ]),
        isFalse,
      );
    });

    test('should handle any role checks', () async {
      expect(
        await authProvider.hasAnyRole('admin123', ['admin', 'unknown']),
        isTrue,
      );
      expect(
        await authProvider.hasAnyRole('admin123', ['unknown1', 'unknown2']),
        isFalse,
      );
      expect(
        await authProvider.hasAnyRole('user456', ['user', 'editor']),
        isTrue,
      );
    });

    test('should handle all role checks', () async {
      expect(
        await authProvider.hasAllRoles('admin123', ['admin', 'manager']),
        isTrue,
      );
      expect(
        await authProvider.hasAllRoles('admin123', ['admin', 'unknown']),
        isFalse,
      );
      expect(
        await authProvider.hasAllRoles('editor789', ['editor']),
        isTrue,
      );
    });

    test('should get effective permissions', () async {
      final permissions = await authProvider.getEffectivePermissions(
        'admin123',
        'users',
      );
      expect(
        permissions,
        containsAll(['user:create', 'user:delete', 'user:read', 'user:update']),
      );
    });

    test('should get effective roles', () async {
      final roles = await authProvider.getEffectiveRoles('admin123', 'users');
      expect(roles, containsAll(['admin', 'manager']));
    });
}

void setupTestData(InMemoryAuthorizationProvider provider) {
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
    ..setUserData(
      'user456',
      const AuthorizationData(
        userId: 'user456',
        roles: ['user'],
        permissions: ['user:read'],
        attributes: {'department': 'Sales', 'level': 'junior'},
      ),
    )
    ..setUserData(
      'editor789',
      const AuthorizationData(
        userId: 'editor789',
        roles: ['editor'],
        permissions: ['content:read', 'content:edit'],
        attributes: {'department': 'Content', 'level': 'mid'},
      ),
    );
}
