import 'package:kiss_auth/src/authentication_data.dart';
import 'package:kiss_auth/src/jwt_claims.dart';

/// JWT-based implementation of authentication data
class JwtAuthenticationData extends AuthenticationData {
  /// Creates JWT authentication data from claims
  JwtAuthenticationData({
    required Map<String, dynamic> claims,
  }) : _claims = claims;

  /// Raw JWT claims map
  final Map<String, dynamic> _claims;

  @override
  String get userId =>
      (_claims[JwtClaims.subject] ?? _claims[AuthClaims.userId] ?? '')
          as String;

  @override
  Map<String, dynamic> get claims => Map<String, dynamic>.from(_claims);
}
