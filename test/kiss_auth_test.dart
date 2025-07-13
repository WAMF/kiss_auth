import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:kiss_auth/kiss_authentication.dart';
import 'package:test/test.dart';

void main() {
  group('AuthMetadata', () {
    test('should create AuthMetadata with required fields', () {
      final metadata = JwtAuthenticationData(
        claims: {
          'sub': 'user123',
          'roles': ['admin', 'user'],
          'email': 'test@example.com',
          'permissions': ['read', 'write'],
        },
      );

      expect(metadata.userId, equals('user123'));
      expect(metadata.claims['roles'], equals(['admin', 'user']));
      expect(metadata.claims['email'], equals('test@example.com'));
    });

    test('should access roles from claims', () {
      final metadata = JwtAuthenticationData(
        claims: {
          'sub': 'user123',
          'roles': ['admin', 'user'],
        },
      );

      expect(metadata.claims['roles'], equals(['admin', 'user']));
      expect((metadata.claims['roles'] as List).contains('admin'), isTrue);
      expect((metadata.claims['roles'] as List).contains('user'), isTrue);
      expect((metadata.claims['roles'] as List).contains('guest'), isFalse);
    });

    test('should access permissions from claims', () {
      final metadata = JwtAuthenticationData(
        claims: {
          'sub': 'user123',
          'roles': ['user'],
          'permissions': ['read', 'write', 'delete'],
        },
      );

      expect(metadata.claims['permissions'], equals(['read', 'write', 'delete']));
      expect((metadata.claims['permissions'] as List).contains('read'), isTrue);
      expect((metadata.claims['permissions'] as List).contains('write'), isTrue);
      expect((metadata.claims['permissions'] as List).contains('delete'), isTrue);
      expect((metadata.claims['permissions'] as List).contains('admin'), isFalse);
    });

    test(
      'should return null for permissions when claims do not contain permissions',
      () {
        final metadata = JwtAuthenticationData(
          claims: {
            'sub': 'user123',
            'roles': ['user'],
            'email': 'test@example.com',
          },
        );

        expect(metadata.claims['permissions'], isNull);
      },
    );

    test('should handle null permissions claim', () {
      final metadata = JwtAuthenticationData(
        claims: {
          'sub': 'user123',
          'roles': ['user'],
          'permissions': null,
        },
      );

      expect(metadata.claims['permissions'], isNull);
    });
  });

  group('JwtAuthValidator', () {
    const hmacSecret = 'test-secret-key-123';

    group('HMAC validation', () {
      late JwtAuthValidator validator;

      setUp(() {
        validator = JwtAuthValidator.hmac(hmacSecret);
      });

      test('should validate valid HMAC JWT token', () async {
        // Create a test JWT token
        final jwt = JWT({
          'sub': 'user123',
          'roles': ['admin', 'user'],
          'permissions': ['read', 'write'],
          'email': 'test@example.com',
        });

        final token = jwt.sign(SecretKey(hmacSecret));

        final result = await validator.validateToken(token);

        expect(result.userId, equals('user123'));
        expect(result.claims['roles'], equals(['admin', 'user']));
        expect(result.claims['email'], equals('test@example.com'));
        expect(result.claims['permissions'], equals(['read', 'write']));
      });

      test('should handle token without sub claim', () async {
        final jwt = JWT({
          'roles': ['user'],
          'email': 'test@example.com',
        });

        final token = jwt.sign(SecretKey(hmacSecret));

        final result = await validator.validateToken(token);

        expect(result.userId, equals(''));
        expect(result.claims['roles'], equals(['user']));
      });

      test('should handle token without roles claim', () async {
        final jwt = JWT({'sub': 'user123', 'email': 'test@example.com'});

        final token = jwt.sign(SecretKey(hmacSecret));

        final result = await validator.validateToken(token);

        expect(result.userId, equals('user123'));
        expect(result.claims['roles'], isNull);
      });

      test('should throw exception for invalid HMAC token', () async {
        const invalidToken = 'invalid.jwt.token';

        expect(
          () async => validator.validateToken(invalidToken),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Invalid JWT'),
            ),
          ),
        );
      });

      test(
        'should throw exception for token signed with wrong secret',
        () async {
          final jwt = JWT({'sub': 'user123'});
          final token = jwt.sign(SecretKey('wrong-secret'));

          expect(
            () async => validator.validateToken(token),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Invalid JWT'),
              ),
            ),
          );
        },
      );

      test('should throw exception for expired token', () async {
        final jwt = JWT({
          'sub': 'user123',
          'exp':
              DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000,
        });
        final token = jwt.sign(SecretKey(hmacSecret));

        expect(
          () async => validator.validateToken(token),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Invalid JWT'),
            ),
          ),
        );
      });
    });

    group('RSA validation', () {
      test('should create RSA validator', () {
        const rsaPublicKey = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1234567890
-----END PUBLIC KEY-----''';

        final validator = JwtAuthValidator.rsa(rsaPublicKey);
        expect(validator, isA<JwtAuthValidator>());
      });

      test('should throw exception for invalid RSA key format', () async {
        const invalidRsaKey = 'invalid-rsa-key';
        final validator = JwtAuthValidator.rsa(invalidRsaKey);

        const invalidToken = 'some.jwt.token';

        expect(
          () async => validator.validateToken(invalidToken),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Invalid JWT'),
            ),
          ),
        );
      });
    });

    group('Edge cases', () {
      late JwtAuthValidator validator;

      setUp(() {
        validator = JwtAuthValidator.hmac(hmacSecret);
      });

      test('should handle empty string token', () async {
        expect(
          () async => validator.validateToken(''),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed JWT structure', () async {
        const malformedToken = 'not.a.jwt';

        expect(
          () async => validator.validateToken(malformedToken),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle JWT with non-standard claims structure', () async {
        final jwt = JWT({
          'sub': 'user123',
          'roles': 'not-an-array', // This should be handled gracefully
          'custom_claim': {'nested': 'value'},
        });

        final token = jwt.sign(SecretKey(hmacSecret));

        expect(
          () async => validator.validateToken(token),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
