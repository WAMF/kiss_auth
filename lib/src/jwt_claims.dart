/// JWT claim field names used across authentication components
library;

/// Standard JWT claim names as defined in RFC 7519
class JwtClaims {
  /// Subject - identifies the principal that is the subject of the JWT
  static const String subject = 'sub';
  
  /// Issued at - identifies the time at which the JWT was issued
  static const String issuedAt = 'iat';
  
  /// Expiration time - identifies the expiration time on or after which the JWT must not be accepted
  static const String expiration = 'exp';
  
  /// Issuer - identifies the principal that issued the JWT
  static const String issuer = 'iss';
  
  /// Audience - identifies the recipients that the JWT is intended for
  static const String audience = 'aud';
  
  /// Not before - identifies the time before which the JWT must not be accepted
  static const String notBefore = 'nbf';
  
  /// JWT ID - provides a unique identifier for the JWT
  static const String jwtId = 'jti';
}

/// Custom claim names used in this authentication library
class AuthClaims {
  /// Alternative user identifier field
  static const String userId = 'user_id';
  
  /// User roles array
  static const String roles = 'roles';
  
  /// User permissions array
  static const String permissions = 'permissions';
  
  /// User email address
  static const String email = 'email';
  
  /// User display name
  static const String name = 'name';
}
