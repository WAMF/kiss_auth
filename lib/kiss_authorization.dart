
/// Kiss Auth Authorization Module
/// 
/// Provides role-based and permission-based access control interfaces.
/// This module handles the "what can this user do?" part of authentication.
/// 
/// For credential-based authentication (the "how do I get a token?" part), 
/// use the kiss_login module.
/// 
/// For token validation (the "is this token valid?" part), use the
/// kiss_authentication module.
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:kiss_auth/kiss_authorization.dart';
/// 
/// // Create authorization service
/// final authValidator = JwtAuthValidator.hmac('secret');
/// final authzProvider = InMemoryAuthorizationProvider();
/// final authzService = AuthorizationService(authValidator, authzProvider);
/// 
/// // Check permissions
/// final hasPermission = await authzService.hasPermission(token, 'user:read');
/// if (hasPermission) {
///   // User can read users
/// }
/// 
/// // Get full authorization context
/// final context = await authzService.authorize(token);
/// print('User roles: ${context.authorizationData.roles}');
/// ```
library;

export 'src/authentication_data.dart';
export 'src/authentication_validator.dart';
export 'src/authentication_validator_jwt.dart';
export 'src/authorization_config.dart';
export 'src/authorization_data.dart';
export 'src/authorization_provider.dart';
export 'src/authorization_provider_in_memory.dart';
export 'src/authorization_service.dart';
