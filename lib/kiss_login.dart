/// Kiss Auth Login Module
/// 
/// Provides credential-based authentication interfaces for external providers.
/// This module handles the "how do I get a token?" part of authentication.
/// 
/// For token validation (the "is this token valid?" part), use the 
/// kiss_authentication module.
/// 
/// For authorization checks (the "what can this user do?" part), use the
/// kiss_authorization module.
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:kiss_auth/kiss_login.dart';
/// 
/// // Use with external provider packages:
/// // - kiss_auth_firebase
/// // - kiss_auth_pocketbase  
/// // - kiss_auth_auth0
/// // etc.
/// 
/// final provider = SomeExternalLoginProvider();
/// final loginService = LoginService(provider);
/// 
/// // Login with username/password
/// final result = await loginService.loginWithPassword('user', 'password');
/// if (result.isSuccess) {
///   print('Access token: ${result.accessToken}');
///   print('User: ${result.user?.userId}');
/// }
/// ```
library;

export 'src/login/login_credentials.dart';
export 'src/login/login_provider.dart';
export 'src/login/login_provider_in_memory.dart';
export 'src/login/login_result.dart';
export 'src/login/login_service.dart';
export 'src/login/user_profile.dart';
