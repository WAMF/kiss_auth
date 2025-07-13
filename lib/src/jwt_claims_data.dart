import 'package:kiss_auth/src/jwt_claims.dart';

/// Structured representation of JWT claims with standard fields and extra claims
class JwtClaimsData {
  /// Creates JWT claims data from raw claims map
  const JwtClaimsData(this._rawClaims);

  /// Raw claims map from JWT token
  final Map<String, dynamic> _rawClaims;

  /// Subject - identifies the principal that is the subject of the JWT
  String? get subject => _rawClaims[JwtClaims.subject] as String?;

  /// Issuer - identifies the principal that issued the JWT
  String? get issuer => _rawClaims[JwtClaims.issuer] as String?;

  /// Audience - identifies the recipients that the JWT is intended for
  dynamic get audience => _rawClaims[JwtClaims.audience];

  /// Expiration time - identifies the expiration time on or after which the JWT must not be accepted
  DateTime? get expiration {
    final exp = _rawClaims[JwtClaims.expiration];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }
    return null;
  }

  /// Issued at - identifies the time at which the JWT was issued
  DateTime? get issuedAt {
    final iat = _rawClaims[JwtClaims.issuedAt];
    if (iat is int) {
      return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
    }
    return null;
  }

  /// Not before - identifies the time before which the JWT must not be accepted
  DateTime? get notBefore {
    final nbf = _rawClaims[JwtClaims.notBefore];
    if (nbf is int) {
      return DateTime.fromMillisecondsSinceEpoch(nbf * 1000);
    }
    return null;
  }

  /// JWT ID - provides a unique identifier for the JWT
  String? get jwtId => _rawClaims[JwtClaims.jwtId] as String?;

  /// Get a specific claim value by key
  T? getClaim<T>(String key) => _rawClaims[key] as T?;

  /// Check if token is expired
  bool get isExpired {
    final exp = expiration;
    return exp != null && DateTime.now().isAfter(exp);
  }

  /// Check if token is not yet valid (before nbf time)
  bool get isNotYetValid {
    final nbf = notBefore;
    return nbf != null && DateTime.now().isBefore(nbf);
  }

  /// Check if token is currently valid (not expired and not before nbf)
  bool get isValid => !isExpired && !isNotYetValid;

  /// Get all raw claims (for backward compatibility)
  Map<String, dynamic> get allClaims => Map<String, dynamic>.from(_rawClaims);
}
