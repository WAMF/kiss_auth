import 'package:kiss_auth/kiss_authorization.dart';
import 'package:kiss_auth/kiss_login.dart';
import 'package:kiss_dependencies/kiss_dependencies.dart';

/// Setup function type definition
typedef SetupFunction = void Function();

/// Setup dependencies for InMemory providers (default for testing)
void setupInMemoryProviders() {
  const jwtSecret = 'default-test-secret';

  register<LoginProvider>(InMemoryLoginProvider.new);

  register<AuthValidator>(() => JwtAuthValidator.hmac(jwtSecret));

  register<AuthorizationProvider>(InMemoryAuthorizationProvider.new);

  register<LoginService>(() => LoginService(resolve<LoginProvider>()));

  register<AuthorizationService>(
    () => AuthorizationService(
      resolve<AuthValidator>(),
      resolve<AuthorizationProvider>(),
    ),
  );

  _setupInMemoryTestData();
}

/// Setup test data for InMemory providers
void _setupInMemoryTestData() {
  (resolve<AuthorizationProvider>() as InMemoryAuthorizationProvider)
    ..setUserData(
      'user_admin',
      const AuthorizationData(
        userId: 'user_admin',
        roles: ['admin', 'manager'],
        permissions: ['user:create', 'user:delete', 'user:read', 'user:update'],
        attributes: {'department': 'IT', 'level': 'senior'},
      ),
    )
    ..setUserData(
      'user_001',
      const AuthorizationData(
        userId: 'user_001',
        roles: ['user'],
        permissions: ['user:read'],
        attributes: {'department': 'Sales', 'level': 'junior'},
      ),
    )
    ..setUserData(
      'user_002',
      const AuthorizationData(
        userId: 'user_002',
        roles: ['user', 'editor'],
        permissions: ['user:read', 'content:edit', 'content:publish'],
        attributes: {'department': 'Marketing', 'level': 'mid'},
      ),
    );
}
