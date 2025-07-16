import 'package:kiss_auth/src/login/login_credentials.dart';
import 'package:kiss_auth/src/login/login_provider_in_memory.dart';
import 'package:test/test.dart';

void main() {
  group('UserCreationCredentials', () {
    test('should create UserCreationCredentials with required fields', () {
      const credentials = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(credentials.email, equals('test@example.com'));
      expect(credentials.password, equals('password123'));
      expect(credentials.displayName, isNull);
      expect(credentials.additionalData, isNull);
      expect(credentials.type, equals('user_creation'));
    });

    test('should create UserCreationCredentials with optional fields', () {
      const credentials = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
        additionalData: {'role': 'admin'},
      );

      expect(credentials.email, equals('test@example.com'));
      expect(credentials.password, equals('password123'));
      expect(credentials.displayName, equals('Test User'));
      expect(credentials.additionalData, equals({'role': 'admin'}));
      expect(credentials.type, equals('user_creation'));
    });

    test('should convert to map correctly', () {
      const credentials = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
        additionalData: {'role': 'admin'},
      );

      final map = credentials.toMap();
      expect(map['type'], equals('user_creation'));
      expect(map['email'], equals('test@example.com'));
      expect(map['password'], equals('password123'));
      expect(map['display_name'], equals('Test User'));
      expect(map['additional_data'], equals({'role': 'admin'}));
    });

    test('should handle equality correctly', () {
      const credentials1 = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );
      const credentials2 = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );
      const credentials3 = UserCreationCredentials(
        email: 'different@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      expect(credentials1, equals(credentials2));
      expect(credentials1, isNot(equals(credentials3)));
    });

    test('should generate consistent hash codes', () {
      const credentials1 = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
      );
      const credentials2 = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(credentials1.hashCode, equals(credentials2.hashCode));
    });

    test('should have proper toString representation', () {
      const credentials = UserCreationCredentials(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      final stringRepresentation = credentials.toString();
      expect(stringRepresentation, contains('UserCreationCredentials'));
      expect(stringRepresentation, contains('test@example.com'));
      expect(stringRepresentation, contains('Test User'));
      expect(stringRepresentation, isNot(contains('password123')));
    });
  });

  group('InMemoryLoginProvider - User Creation', () {
    late InMemoryLoginProvider provider;

    setUp(() {
      provider = InMemoryLoginProvider();
    });

    test('should create a new user successfully', () async {
      const credentials = UserCreationCredentials(
        email: 'newuser@example.com',
        password: 'password123',
        displayName: 'New User',
      );

      final result = await provider.createUser(credentials);

      expect(result.isSuccess, isTrue);
      expect(result.user?.email, equals('newuser@example.com'));
      expect(result.user?.username, equals('New User'));
      expect(result.user?.roles, equals(['user']));
      expect(result.user?.permissions, equals(['read']));
      expect(result.accessToken, isNotNull);
      expect(result.refreshToken, isNotNull);
      expect(result.expiresIn, equals(3600));
    });

    test('should fail to create user with existing email', () async {
      const credentials = UserCreationCredentials(
        email: 'admin@example.com',
        password: 'password123',
      );

      final result = await provider.createUser(credentials);

      expect(result.isSuccess, isFalse);
      expect(result.error, equals('User already exists'));
      expect(result.errorCode, equals('user_already_exists'));
    });

    test('should fail with invalid credential type', () async {
      const credentials = EmailPasswordCredentials(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = await provider.createUser(credentials);

      expect(result.isSuccess, isFalse);
      expect(result.error, equals('Invalid credential type for user creation'));
      expect(result.errorCode, equals('invalid_credential_type'));
    });

    test('should authenticate created user', () async {
      const createCredentials = UserCreationCredentials(
        email: 'newuser@example.com',
        password: 'password123',
        displayName: 'New User',
      );

      final createResult = await provider.createUser(createCredentials);
      expect(createResult.isSuccess, isTrue);

      const loginCredentials = EmailPasswordCredentials(
        email: 'newuser@example.com',
        password: 'password123',
      );

      final loginResult = await provider.authenticate(loginCredentials);
      expect(loginResult.isSuccess, isTrue);
      expect(loginResult.user?.email, equals('newuser@example.com'));
      expect(loginResult.user?.username, equals('New User'));
    });

    test('should update provider capabilities to include user_creation', () {
      final info = provider.getProviderInfo();
      final capabilities = info['capabilities'] as List<String>;
      
      expect(capabilities, contains('user_creation'));
    });
  });
}
