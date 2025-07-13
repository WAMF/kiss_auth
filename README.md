# kiss_auth

A modular authentication and authorization library for Dart applications. Kiss Auth follows the "Keep It Simple, Stupid" principle with clear separation of concerns.

## 📋 Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Modules](#modules)
- [Quick Start](#quick-start)
- [Examples](#examples)

## Overview

Kiss Auth provides three independent modules:

1. **Login** (`kiss_login`) - Credential-based authentication (get tokens)
2. **Authentication** (`kiss_authentication`) - JWT token validation (validate tokens)  
3. **Authorization** (`kiss_authorization`) - Role/permission-based access control

Each module can be used independently or combined as needed.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kiss_auth: ^0.1.0
```

## Modules

### 🔐 Login Module (`kiss_login`)
Get tokens using credentials. Provides interfaces for external authentication providers.

```dart
import 'package:kiss_auth/kiss_login.dart';

final provider = SomeExternalLoginProvider(); // Firebase, PocketBase, etc.
final loginService = LoginService(provider);

final result = await loginService.loginWithPassword('user', 'password');
if (result.isSuccess) {
  print('Token: ${result.accessToken}');
}
```

### 🔍 Authentication Module (`kiss_authentication`)  
Validate JWT tokens and extract identity.

```dart
import 'package:kiss_auth/kiss_authentication.dart';

final validator = JwtAuthValidator.hmac('secret-key');
final authData = await validator.validateToken(token);
print('User: ${authData.userId}');
```

### 🛡️ Authorization Module (`kiss_authorization`)
Role and permission-based access control.

```dart
import 'package:kiss_auth/kiss_authorization.dart';

final authzClient = AuthorizationClient(provider);
final canEdit = await authzClient.hasPermission('user123', 'document:edit');
```

## Quick Start

### Option 1: Login Only (Get Tokens)
```dart
import 'package:kiss_auth/kiss_login.dart';

final provider = InMemoryLoginProvider(); // or Firebase, PocketBase, etc.
final loginService = LoginService(provider);

final result = await loginService.loginWithPassword('admin', 'admin123');
if (result.isSuccess) {
  print('Logged in: ${result.user?.userId}');
  print('Token: ${result.accessToken}');
}
```

### Option 2: Authentication Only (Validate Tokens)
```dart
import 'package:kiss_auth/kiss_authentication.dart';

final validator = JwtAuthValidator.hmac('your-secret-key');
final authData = await validator.validateToken(jwtToken);
print('User: ${authData.userId}');
print('Roles: ${authData.jwt.getClaim<List>('roles')}');
```

### Option 3: Authorization Only (Check Permissions)
```dart
import 'package:kiss_auth/kiss_authorization.dart';

final provider = InMemoryAuthorizationProvider();

final canEdit = await provider.hasPermission('user123', 'document:edit');
print('Can edit: $canEdit');
```

### Option 4: Combined Usage
```dart
// 1. Get token (Login Module)
final loginResult = await loginService.loginWithPassword('user', 'pass');
final token = loginResult.accessToken!;

// 2. Validate token (Authentication Module)  
final authData = await validator.validateToken(token);

// 3. Check permissions (Authorization Module)  
final canEdit = await authzProvider.hasPermission(authData.userId, 'edit');
```

## Examples

Run the examples to see the modules in action:

```bash
# Login module example
dart run example/login_example.dart

# Authentication module example  
dart run example/kiss_auth_example.dart

# Authorization module example
dart run example/separate_concerns_example.dart
```

## External Providers

The login module is designed to work with external authentication providers:

- **kiss_auth_firebase** - Firebase Authentication
- **kiss_auth_pocketbase** - PocketBase Authentication  
- **kiss_auth_auth0** - Auth0 Authentication
- **kiss_auth_supabase** - Supabase Authentication

Each provider implements the `LoginProvider` interface for seamless integration.

## Contributing

Contributions welcome! Please read the contributing guidelines and submit pull requests.

## License

MIT License - see LICENSE file for details.
