import 'package:kiss_auth/kiss_login.dart';

Future<void> main() async {
  print('=== Kiss Auth Login Example ===\n');

  // Set up the login system with in-memory provider
  final loginProvider = InMemoryLoginProvider();
  final loginService = LoginService(loginProvider);

  print('Provider Info: ${loginService.getProviderInfo()}\n');

  // Example 1: Username/Password Login
  await usernamePasswordExample(loginService);

  print('\n${'=' * 50}\n');

  // Example 2: Email/Password Login
  await emailPasswordExample(loginService);

  print('\n${'=' * 50}\n');

  // Example 3: API Key Login
  await apiKeyExample(loginService);

  print('\n${'=' * 50}\n');

  // Example 4: Anonymous Login
  await anonymousExample(loginService);

  print('\n${'=' * 50}\n');

  // Example 5: Token Management
  await tokenManagementExample(loginService);

  print('\n${'=' * 50}\n');

  // Example 6: Error Handling
  await errorHandlingExample(loginService);
}

Future<void> usernamePasswordExample(LoginService loginService) async {
  print('1. Username/Password Login Example');
  print('==================================');

  final result = await loginService.loginWithPassword('admin', 'admin123');

  if (result.isSuccess) {
    print('✅ Login successful!');
    print('   User ID: ${result.user?.userId}');
    print('   Username: ${result.user?.username}');
    print('   Email: ${result.user?.email}');
    print('   Roles: ${result.user?.roles}');
    print('   Permissions: ${result.user?.permissions}');
    print('   Access Token: ${result.accessToken?.substring(0, 20)}...');
    print('   Expires In: ${result.expiresIn} seconds');
  } else {
    print('❌ Login failed: ${result.error}');
  }
}

Future<void> emailPasswordExample(LoginService loginService) async {
  print('2. Email/Password Login Example');
  print('===============================');

  final result = await loginService.loginWithEmail('user@example.com', 'user123');

  if (result.isSuccess) {
    print('✅ Login successful!');
    print('   User ID: ${result.user?.userId}');
    print('   Email: ${result.user?.email}');
    print('   Roles: ${result.user?.roles}');
    print('   Claims: ${result.user?.claims}');
  } else {
    print('❌ Login failed: ${result.error}');
  }
}

Future<void> apiKeyExample(LoginService loginService) async {
  print('3. API Key Login Example');
  print('========================');

  // API key format for in-memory provider: "api_key_<userId>"
  final result = await loginService.loginWithApiKey('api_key_user_admin');

  if (result.isSuccess) {
    print('✅ API Key login successful!');
    print('   User ID: ${result.user?.userId}');
    print('   Auth Method: ${result.user?.getClaim<String>('auth_method')}');
    print('   Roles: ${result.user?.roles}');
    print('   Expires In: ${result.expiresIn} seconds');
  } else {
    print('❌ API Key login failed: ${result.error}');
  }
}

Future<void> anonymousExample(LoginService loginService) async {
  print('4. Anonymous Login Example');
  print('==========================');

  final result = await loginService.loginAnonymously();

  if (result.isSuccess) {
    print('✅ Anonymous login successful!');
    print('   User ID: ${result.user?.userId}');
    print('   Roles: ${result.user?.roles}');
    print('   Permissions: ${result.user?.permissions}');
    print('   Auth Method: ${result.user?.getClaim<String>('auth_method')}');
  } else {
    print('❌ Anonymous login failed: ${result.error}');
  }
}

Future<void> tokenManagementExample(LoginService loginService) async {
  print('5. Token Management Example');
  print('===========================');

  // First, login to get tokens
  final loginResult = await loginService.loginWithPassword('user', 'user123');
  
  if (!loginResult.isSuccess) {
    print('❌ Could not login for token management demo');
    return;
  }

  final accessToken = loginResult.accessToken!;
  final refreshToken = loginResult.refreshToken;

  print('✅ Initial login successful');
  print('   Access Token: ${accessToken.substring(0, 20)}...');
  
  if (refreshToken != null) {
    print('   Refresh Token: ${refreshToken.substring(0, 20)}...');
  }

  // Check token validity
  final isValid = await loginService.isTokenValid(accessToken);
  print('   Token is valid: $isValid');

  // Get user ID from token
  final userId = await loginService.getUserIdFromToken(accessToken);
  print('   User ID from token: $userId');

  // Refresh token if available
  if (refreshToken != null) {
    print('\n🔄 Refreshing token...');
    final refreshResult = await loginService.refreshToken(refreshToken);
    
    if (refreshResult.isSuccess) {
      print('✅ Token refresh successful!');
      print('   New Access Token: ${refreshResult.accessToken?.substring(0, 20)}...');
    } else {
      print('❌ Token refresh failed: ${refreshResult.error}');
    }
  }

  // Logout
  print('\n🚪 Logging out...');
  final logoutSuccess = await loginService.logout(accessToken);
  print('   Logout successful: $logoutSuccess');

  // Check token validity after logout
  final stillValid = await loginService.isTokenValid(accessToken);
  print('   Token still valid after logout: $stillValid');
}

Future<void> errorHandlingExample(LoginService loginService) async {
  print('6. Error Handling Example');
  print('=========================');

  final testCases = [
    ('Wrong username', 'wronguser', 'password'),
    ('Wrong password', 'admin', 'wrongpassword'),
    ('Empty credentials', '', ''),
    ('Non-existent email', 'fake@example.com', 'password'),
  ];

  for (final (description, username, password) in testCases) {
    print('\nTesting: $description');
    final result = await loginService.loginWithPassword(username, password);
    
    if (result.isSuccess) {
      print('  ✅ Unexpected success');
    } else {
      print('  ❌ Expected failure: ${result.error}');
      print('     Error code: ${result.errorCode}');
    }
  }

  // Test invalid API key
  print('\nTesting: Invalid API key');
  final apiResult = await loginService.loginWithApiKey('invalid_key');
  print('  ❌ Expected failure: ${apiResult.error}');
  print('     Error code: ${apiResult.errorCode}');

  // Test invalid refresh token
  print('\nTesting: Invalid refresh token');
  final refreshResult = await loginService.refreshToken('invalid_refresh_token');
  print('  ❌ Expected failure: ${refreshResult.error}');
  print('     Error code: ${refreshResult.errorCode}');
}
