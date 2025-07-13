import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/kiss_authorization.dart';

Future<void> main() async {
  print('=== In-Memory Authorization Provider Example ===\n');

  // Create an in-memory provider
  final provider = InMemoryAuthorizationProvider();

  // Set up test data for different users
  await setupTestData(provider);

  // Test different scenarios
  await testUserScenarios(provider);

  print('\n=== Testing with JWT Authentication ===\n');
  await testWithJwtAuthentication(provider);
}

Future<void> setupTestData(InMemoryAuthorizationProvider provider) async {
  print('🔧 Setting up test data...\n');

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

  print('✅ Test data configured for 3 users: admin123, user456, editor789');
}

Future<void> testUserScenarios(InMemoryAuthorizationProvider provider) async {
  print('\n📊 Testing different user scenarios:\n');

  // Test admin user
  print('👑 Admin User (admin123):');
  final adminData = await provider.getAuthorization('admin123');
  print('   Roles: ${adminData.roles}');
  print('   Permissions: ${adminData.permissions}');
  print(
    '   Can create users: ${await provider.hasPermission('admin123', 'user:create')}',
  );
  print('   Is admin: ${await provider.hasRole('admin123', 'admin')}');
  print('   Department: ${adminData.getAttribute<String>('department')}');

  // Test regular user
  print('\n👤 Regular User (user456):');
  final userData = await provider.getAuthorization('user456');
  print('   Roles: ${userData.roles}');
  print('   Permissions: ${userData.permissions}');
  print(
    '   Can read users: ${await provider.hasPermission('user456', 'user:read')}',
  );
  print(
    '   Can create users: ${await provider.hasPermission('user456', 'user:create')}',
  );
  print('   Is admin: ${await provider.hasRole('user456', 'admin')}');

  // Test editor user
  print('\n✏️ Editor User (editor789):');
  final editorData = await provider.getAuthorization('editor789');
  print('   Roles: ${editorData.roles}');
  print('   Permissions: ${editorData.permissions}');
  print(
    '   Can edit content: ${await provider.hasPermission('editor789', 'content:edit')}',
  );
  print(
    '   Can publish content: ${await provider.hasPermission('editor789', 'content:publish')}',
  );
  print(
    '   Has any content permission: ${await provider.hasAnyPermission('editor789', ['content:read', 'content:edit'])}',
  );

  // Test batch operations
  print('\n🔍 Batch Permission Check:');
  final batchResults = await provider.checkPermissions('admin123', [
    'user:create',
    'user:delete',
    'user:read',
    'content:edit', // Admin doesn't have this
  ]);
  print('   Batch results: $batchResults');

  // Test role checking
  print('\n🎭 Batch Role Check:');
  final roleResults = await provider.checkRoles('editor789', [
    'editor',
    'user',
    'admin', // Editor doesn't have this
  ]);
  print('   Role results: $roleResults');
}

Future<void> testWithJwtAuthentication(
  InMemoryAuthorizationProvider provider,
) async {
  // Create JWT validator
  const secretKey = 'test-secret-key';
  final authValidator = JwtAuthValidator.hmac(secretKey);

  // Create authorization service
  final authzService = AuthorizationService(authValidator, provider);

  // Create a JWT token for admin user
  final token = JWT({
    'sub': 'admin123',
    'email': 'admin@example.com',
    'roles': ['user'], // JWT roles
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'exp':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
  }, issuer: 'kiss_auth_example').sign(SecretKey(secretKey));

  print('🔐 Testing JWT + In-Memory Provider combination...\n');

  // Test combined authentication and authorization
  final context = await authzService.authorize(token);
  print('✅ Authentication and authorization successful!');
  print('   User ID: ${context.userId}');
  print('   JWT roles: ${context.tokenRoles}');
  print('   Provider roles: ${context.authzRoles}');
  print('   All roles: ${context.allRoles}');
  print('   Permissions: ${context.permissions}');

  // Test authorization checks
  print('\n🔒 Authorization checks:');
  print('   Has admin role (provider): ${context.hasRole('admin')}');
  print('   Has user role (JWT): ${context.hasRole('user')}');
  print('   Can create users: ${context.hasPermission('user:create')}');
  print('   Can read users: ${context.hasPermission('user:read')}');

  // Test dynamic data updates
  print('\n🔄 Testing dynamic data updates...');

  // Update user data in real-time
  provider.setUserData(
    'admin123',
    const AuthorizationData(
      userId: 'admin123',
      roles: ['admin', 'manager', 'supervisor'], // Added supervisor
      permissions: [
        'user:create',
        'user:delete',
        'user:read',
        'user:update',
        'audit:view',
      ], // Added audit:view
      attributes: {'department': 'IT', 'level': 'senior', 'region': 'US'},
    ),
  );

  // Test with updated data
  final updatedContext = await authzService.authorize(token);
  print('   Updated roles: ${updatedContext.authzRoles}');
  print('   Updated permissions: ${updatedContext.permissions}');
  print('   Has supervisor role: ${updatedContext.hasRole('supervisor')}');
  print('   Can view audit: ${updatedContext.hasPermission('audit:view')}');
  print('   Region: ${updatedContext.getAttribute<String>('region')}');

  print('\n✅ In-memory provider allows real-time data updates for testing!');
}
