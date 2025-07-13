import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:kiss_auth/src/authentication_data.dart';
import 'package:kiss_auth/src/authentication_validator.dart';
import 'package:kiss_auth/src/jwt_authentication_data.dart';
import 'package:kiss_auth/src/jwt_claims.dart';

/// JWT algorithm types supported
enum JwtAlgorithm { 
  /// HMAC-based algorithm
  hmac, 
  /// RSA-based algorithm  
  rsa 
}

/// JWT token validator implementation
class JwtAuthValidator implements AuthValidator {

  /// Create HMAC-based JWT validator
  JwtAuthValidator.hmac(this.secretOrPublicKey) : algorithm = JwtAlgorithm.hmac;
  
  /// Create RSA-based JWT validator
  JwtAuthValidator.rsa(this.secretOrPublicKey) : algorithm = JwtAlgorithm.rsa;
  
  /// Secret key for HMAC or public key for RSA
  final String secretOrPublicKey;
  
  /// Algorithm type used for validation
  final JwtAlgorithm algorithm;

  @override
  Future<AuthenticationData> validateToken(String token) async {
    try {
      final jwt = JWT.verify(token, _getJwtKey());

      final payload = jwt.payload as Map<String, dynamic>;
      
      if (payload[AuthClaims.roles] != null && payload[AuthClaims.roles] is! List) {
        throw Exception('Invalid JWT: roles must be a list');
      }
      
      if (payload[AuthClaims.permissions] != null && payload[AuthClaims.permissions] is! List) {
        throw Exception('Invalid JWT: permissions must be a list');
      }

      return JwtAuthenticationData(
        claims: payload,
      );
    } catch (e) {
      throw Exception('Invalid JWT: $e');
    }
  }

  JWTKey _getJwtKey() {
    switch (algorithm) {
      case JwtAlgorithm.hmac:
        return SecretKey(secretOrPublicKey);
      case JwtAlgorithm.rsa:
        return RSAPublicKey(secretOrPublicKey);
    }
  }
}
