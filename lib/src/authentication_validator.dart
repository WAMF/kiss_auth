import 'package:kiss_auth/src/authentication_data.dart';

/// Abstract interface for token validation
// ignore: one_member_abstracts
abstract class AuthValidator {
  /// Validates a token and returns authentication data
  Future<AuthenticationData> validateToken(String token);
}
