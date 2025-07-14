
/// Kiss Auth Authentication Module
/// 
/// Provides JWT token validation and identity extraction interfaces.
/// This module handles the "is this token valid?" part of authentication.
/// 
/// For credential-based authentication (the "how do I get a token?" part), 
/// use the kiss_login module.
/// 
/// For authorization checks (the "what can this user do?" part), use the
/// kiss_authorization module.
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:kiss_auth/kiss_authentication.dart';
/// 
/// // Create a JWT validator
/// final validator = JwtAuthValidator.hmac('your-secret-key');
/// 
/// // Validate a token
/// try {
///   final authData = await validator.validateToken(incomingToken);
///   print('User ID: ${authData.userId}');
///   print('Claims: ${authData.claims}');
/// } catch (e) {
///   print('Token validation failed: $e');
/// }
/// ```
library;

export 'src/authentication_data.dart';
export 'src/authentication_data_extensions.dart';
export 'src/authentication_validator.dart';
export 'src/authentication_validator_jwt.dart';
export 'src/jwt_authentication_data.dart';
export 'src/jwt_claims.dart';
export 'src/jwt_claims_data.dart';
