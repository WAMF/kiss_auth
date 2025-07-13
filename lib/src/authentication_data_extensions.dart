import 'package:kiss_auth/src/authentication_data.dart';
import 'package:kiss_auth/src/jwt_claims_data.dart';

/// Extensions for AuthenticationData to provide structured JWT claims access
extension AuthenticationDataJwtExtension on AuthenticationData {
  /// Structured JWT claims with standard fields and custom claims
  JwtClaimsData get jwt => JwtClaimsData(claims);
}
