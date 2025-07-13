import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/kiss_authentication.dart';
import 'package:test/test.dart';

// Private test constants
const _testSecret = 'test-secret-key';
const _testUserId = 'user123';
const _testEmail = 'user@example.com';
const _testIssuer = 'kiss_auth_test';
const _departmentIT = 'IT';
const _levelSenior = 'senior';

void main() {
  group('Authentication Tests', () {
    late JwtAuthValidator authValidator;
    setUp(() {
      authValidator = JwtAuthValidator.hmac(_testSecret);
    });

    group('JWT Token Validation', () {
      test('should validate valid JWT token', () async {
        // Create a valid JWT token
        final token = JWT({
          JwtClaims.subject: _testUserId,
          AuthClaims.email: _testEmail,
          AuthClaims.roles: ['user', 'editor'],
          JwtClaims.issuedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          JwtClaims.expiration:
              DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
              1000,
        }, issuer: _testIssuer).sign(SecretKey(_testSecret));

        // Validate the token
        final result = await authValidator.validateToken(token);

        // Verify the result
        expect(result.userId, equals(_testUserId));
        expect(result.claims[JwtClaims.subject], equals(_testUserId));
        expect(result.claims[AuthClaims.email], equals(_testEmail));
        expect(result.claims[AuthClaims.roles], containsAll(['user', 'editor']));
      });

      test('should throw exception for invalid token', () async {
        const invalidToken = 'invalid.jwt.token';

        expect(
          () => authValidator.validateToken(invalidToken),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for expired token', () async {
        // Create an expired JWT token
        final token = JWT({
          JwtClaims.subject: _testUserId,
          AuthClaims.email: _testEmail,
          AuthClaims.roles: ['user'],
          JwtClaims.issuedAt:
              DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .millisecondsSinceEpoch ~/
              1000,
          JwtClaims.expiration:
              DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000,
        }, issuer: _testIssuer).sign(SecretKey(_testSecret));

        expect(
          () => authValidator.validateToken(token),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for wrong secret key', () async {
        // Create token with different secret
        final token = JWT({
          JwtClaims.subject: _testUserId,
          AuthClaims.email: _testEmail,
          AuthClaims.roles: ['user'],
          JwtClaims.issuedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          JwtClaims.expiration:
              DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
              1000,
        }, issuer: _testIssuer).sign(SecretKey('different-secret'));

        expect(
          () => authValidator.validateToken(token),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle token without roles', () async {
        final token = JWT({
          JwtClaims.subject: _testUserId,
          AuthClaims.email: _testEmail,
          JwtClaims.issuedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          JwtClaims.expiration:
              DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
              1000,
        }, issuer: _testIssuer).sign(SecretKey(_testSecret));

        final result = await authValidator.validateToken(token);

        expect(result.userId, equals(_testUserId));
        expect(result.claims[AuthClaims.roles], isNull);
      });

      test('should handle token without email', () async {
        final token = JWT({
          JwtClaims.subject: _testUserId,
          AuthClaims.roles: ['user'],
          JwtClaims.issuedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          JwtClaims.expiration:
              DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
              1000,
        }, issuer: _testIssuer).sign(SecretKey(_testSecret));

        final result = await authValidator.validateToken(token);

        expect(result.userId, equals(_testUserId));
        expect(result.claims[AuthClaims.roles], contains('user'));
      });
    });


    group('Claims Access', () {
      test('should access claims correctly', () {
        final authMetadata = JwtAuthenticationData(
          claims: {
            JwtClaims.subject: _testUserId,
            AuthClaims.email: _testEmail,
            'department': _departmentIT,
            'level': _levelSenior,
            'active': true,
            AuthClaims.roles: ['user'],
          },
        );

        expect(authMetadata.claims[JwtClaims.subject], equals(_testUserId));
        expect(authMetadata.claims[AuthClaims.email], equals(_testEmail));
        expect(authMetadata.claims['department'], equals(_departmentIT));
        expect(authMetadata.claims['level'], equals(_levelSenior));
        expect(authMetadata.claims['active'], isTrue);
        expect(authMetadata.claims['nonexistent'], isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty roles list', () {
        final authMetadata = JwtAuthenticationData(
          claims: {
            JwtClaims.subject: _testUserId,
            AuthClaims.roles: <String>[],
          },
        );

        expect(authMetadata.claims[AuthClaims.roles], isEmpty);
      });

      test('should handle empty claims', () {
        final authMetadata = JwtAuthenticationData(
          claims: {},
        );

        expect(authMetadata.claims, isEmpty);
        expect(authMetadata.claims['any'], isNull);
      });

      test('should handle missing claims', () {
        final authMetadata = JwtAuthenticationData(
          claims: {
            JwtClaims.subject: _testUserId,
          },
        );

        expect(authMetadata.claims[AuthClaims.permissions], isNull);
        expect(authMetadata.claims[AuthClaims.roles], isNull);
      });
    });
  });
}
