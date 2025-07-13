import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/kiss_authentication.dart';

Future<void> main() async {
  print('=== Kiss Auth Example ===\n');

  // Example 1: Basic HMAC JWT validation
  await hmacExample();

  print('\n${'=' * 50}\n');

  // Example 2: Role-based authorization
  await roleBasedExample();

  print('\n${'=' * 50}\n');

  // Example 3: Permission-based access control
  await permissionBasedExample();

  print('\n${'=' * 50}\n');

  // Example 4: Error handling
  await errorHandlingExample();
}

Future<void> hmacExample() async {
  print('1. HMAC JWT Validation Example');
  print('================================');

  const secretKey = 'my-super-secret-key-123';
  final validator = JwtAuthValidator.hmac(secretKey);

  // Create a sample JWT token
  final jwt = JWT({
    'sub': 'user123',
    'roles': ['admin', 'user'],
    'permissions': ['read', 'write', 'delete'],
    'email': 'admin@example.com',
    'name': 'John Doe',
    'exp':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
  });

  final token = jwt.sign(SecretKey(secretKey));

  try {
    final metadata = await validator.validateToken(token);

    print('✅ Token validation successful!');
    print('User ID: ${metadata.userId}');
    print('Roles: ${metadata.jwt.getClaim<List<dynamic>>('roles') ?? []}');
    print('Email: ${metadata.claims['email']}');
    print('Name: ${metadata.claims['name']}');
    print('Subject: ${metadata.jwt.subject}');
    print('Expiration: ${metadata.jwt.expiration}');
    print('All claims: ${metadata.claims}');
  } on Exception catch (e) {
    print('❌ Token validation failed: $e');
  }
}

Future<void> roleBasedExample() async {
  print('2. Role-Based Authorization Example');
  print('===================================');

  const secretKey = 'my-super-secret-key-123';
  final validator = JwtAuthValidator.hmac(secretKey);

  // Create tokens with different roles
  final adminToken = JWT({
    'sub': 'admin123',
    'roles': ['admin', 'user'],
    'email': 'admin@example.com',
  }).sign(SecretKey(secretKey));

  final userToken = JWT({
    'sub': 'user456',
    'roles': ['user'],
    'email': 'user@example.com',
  }).sign(SecretKey(secretKey));

  final guestToken = JWT({
    'sub': 'guest789',
    'roles': ['guest'],
    'email': 'guest@example.com',
  }).sign(SecretKey(secretKey));

  // Test different role checks
  final tokens = [
    ('Admin Token', adminToken),
    ('User Token', userToken),
    ('Guest Token', guestToken),
  ];

  for (final (name, token) in tokens) {
    try {
      final metadata = await validator.validateToken(token);

      final roles = metadata.jwt.getClaim<List<dynamic>>('roles')?.cast<String>() ?? <String>[];
      
      print('\n$name (${metadata.userId}):');
      print('  Has admin role: ${roles.contains('admin')}');
      print('  Has user role: ${roles.contains('user')}');
      print('  Has guest role: ${roles.contains('guest')}');
      print('  Can access admin panel: ${roles.contains('admin')}');
      print(
        '  Can access user area: ${roles.contains('user') || roles.contains('admin')}',
      );
    } on Exception catch (e) {
      print('❌ Error processing $name: $e');
    }
  }
}

Future<void> permissionBasedExample() async {
  print('3. Permission-Based Access Control Example');
  print('==========================================');

  const secretKey = 'my-super-secret-key-123';
  final validator = JwtAuthValidator.hmac(secretKey);

  // Create tokens with different permissions
  final adminToken = JWT({
    'sub': 'admin123',
    'roles': ['admin'],
    'permissions': ['read', 'write', 'delete', 'user:create', 'user:delete'],
  }).sign(SecretKey(secretKey));

  final editorToken = JWT({
    'sub': 'editor456',
    'roles': ['editor'],
    'permissions': ['read', 'write'],
  }).sign(SecretKey(secretKey));

  final viewerToken = JWT({
    'sub': 'viewer789',
    'roles': ['viewer'],
    'permissions': ['read'],
  }).sign(SecretKey(secretKey));

  final tokens = [
    ('Admin', adminToken),
    ('Editor', editorToken),
    ('Viewer', viewerToken),
  ];

  for (final (name, token) in tokens) {
    try {
      final metadata = await validator.validateToken(token);

      final permissions = metadata.jwt.getClaim<List<dynamic>>('permissions')?.cast<String>() ?? <String>[];
      
      print('\n$name (${metadata.userId}):');
      print('  Can read: ${permissions.contains('read')}');
      print('  Can write: ${permissions.contains('write')}');
      print('  Can delete: ${permissions.contains('delete')}');
      print('  Can create users: ${permissions.contains('user:create')}');
      print('  Can delete users: ${permissions.contains('user:delete')}');

      // Advanced permission checking
      final canManageUsers =
          permissions.contains('user:create') &&
          permissions.contains('user:delete');
      print('  Can manage users: $canManageUsers');
    } on Exception catch (e) {
      print('❌ Error processing $name: $e');
    }
  }
}

Future<void> errorHandlingExample() async {
  print('4. Error Handling Example');
  print('=========================');

  const secretKey = 'my-super-secret-key-123';
  final validator = JwtAuthValidator.hmac(secretKey);

  // Test various error conditions
  final testCases = [
    ('Invalid token format', 'not.a.valid.jwt'),
    ('Empty token', ''),
    (
      'Wrong secret signed token',
      JWT({'sub': 'user123'}).sign(SecretKey('wrong-secret')),
    ),
    (
      'Expired token',
      JWT({
        'sub': 'user123',
        'exp':
            DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      }).sign(SecretKey(secretKey)),
    ),
  ];

  for (final (description, token) in testCases) {
    try {
      final metadata = await validator.validateToken(token);
      print(
        '✅ $description: Unexpectedly succeeded with user ${metadata.userId}',
      );
    } on Exception catch (e) {
      print('❌ $description: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

/// Example of how to integrate kiss_auth into a service class
class AuthService {

  AuthService(String secretKey) : _validator = JwtAuthValidator.hmac(secretKey);
  final JwtAuthValidator _validator;

  Future<bool> isAdmin(String token) async {
    try {
      final metadata = await _validator.validateToken(token);
      final roles = metadata.jwt.getClaim<List<dynamic>>('roles')?.cast<String>() ?? <String>[];
      return roles.contains('admin');
    } on Exception {
      return false;
    }
  }

  Future<bool> canAccess(String token, String permission) async {
    try {
      final metadata = await _validator.validateToken(token);
      final permissions = metadata.jwt.getClaim<List<dynamic>>('permissions')?.cast<String>() ?? <String>[];
      return permissions.contains(permission);
    } on Exception {
      return false;
    }
  }

  Future<String?> getUserId(String token) async {
    try {
      final metadata = await _validator.validateToken(token);
      return metadata.userId;
    } on Exception {
      return null;
    }
  }
}
