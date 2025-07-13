# kiss_auth

A modular authentication and authorization library for Dart applications. Kiss Auth follows the "Keep It Simple, Stupid" principle with a clear separation between authentication and authorization concerns.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Installation](#installation)
- [Authentication Only](#authentication-only)
- [Authorization Only](#authorization-only)
- [Combined Usage](#combined-usage)
- [Examples](#examples)

## Overview

Kiss Auth is split into two independent modules:

1. **Authentication** (`kiss_authentication`) - JWT token validation and identity extraction
2. **Authorization** (`kiss_authorization`) - Role-based and permission-based access control

This separation allows you to:
- Use only authentication if you don't need complex authorization
- Use only authorization if you have your own authentication system
- Combine both for a complete solution

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        KISS AUTH ARCHITECTURE                   │
└─────────────────────────────────────────────────────────────────┘

AUTHENTICATION ONLY          AUTHORIZATION ONLY         COMBINED USAGE
┌──────────────────────┐    ┌──────────────────────┐    ┌──────────────────────┐
│   AuthValidator      │    │ AuthorizationService │    │  AuthorizationServer │
│   (JWT validation)   │    │ (External service)   │    │ (Auth + Authz)       │
│         │            │    │         │            │    │         │            │
│         ▼            │    │         ▼            │    │         ▼            │
│   AuthMetadata       │    │ AuthorizationData    │    │AuthorizationContext  │
│   (Identity)         │    │ (Roles/Permissions)  │    │(Identity + Authz)    │
└──────────────────────┘    └──────────────────────┘    └──────────────────────┘
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kiss_auth: ^1.0.0
```

## Authentication Only

If you only need JWT token validation and identity extraction:

```dart
import 'package:kiss_auth/kiss_authentication.dart';

// Validate JWT tokens
final validator = JwtAuthValidator.hmac('your-secret-key');

try {
  final metadata = await validator.validateToken(jwtToken);
  print('User ID: ${metadata.userId}');
  print('Roles: ${metadata.roles}');
  print('Claims: ${metadata.claims}');
} catch (e) {
  print('Invalid token: $e');
}
```

### Features
- 🔐 **JWT Token Validation** - HMAC and RSA signature algorithms
- 👤 **Identity Extraction** - User ID, roles, and claims from tokens
- 🔒 **Basic Permission Checks** - Simple role and permission validation from JWT claims
- 📦 **Lightweight** - Minimal dependencies, focused functionality
- 🧪 **Well Tested** - Comprehensive test coverage

## Authorization Only

If you have your own authentication system but need role-based access control:

```dart
import 'package:kiss_auth/kiss_authorization.dart';

// Configure authorization service
final config = AuthorizationServiceConfig(
  baseUrl: 'https://authz-service.example.com',
  apiKey: 'your-api-key',
);

final authzService = YourAuthorizationProvider(config);
final authzClient = AuthorizationClient(authzService);

// Check user permissions
final canEdit = await authzClient.hasPermission(
  'user123',
  'document:edit',
  resource: 'document:456',
);

final userRoles = await authzClient.getEffectiveRoles('user123', 'documents');
```

### Features
- 🎭 **Role-Based Access Control** - Flexible role management
- 🔑 **Permission-Based Access Control** - Fine-grained permissions
- 🌐 **External Service Integration** - REST, GraphQL, Database providers
- 📊 **Context-Aware Authorization** - Dynamic permissions based on context
- 📈 **Batch Operations** - Check multiple permissions at once

## Combined Usage

For a complete authentication and authorization solution:

```dart
import 'package:kiss_auth/kiss_authorization.dart';

// Configure both authentication and authorization
final authValidator = JwtAuthValidator.hmac('secret-key');
final authzService = YourAuthorizationProvider(config);
final authzServer = AuthorizationServer(authValidator, authzService);

// Validate token and check permissions in one call
final authorized = await authzServer.checkAuthorization(
  token,
  resource: 'documents',
  action: 'edit',
  requiredRoles: ['editor', 'admin'],
  requiredPermissions: ['document:edit'],
);

if (authorized) {
  // User is authenticated and authorized
  final context = await authzServer.authorize(token, resource: 'documents');
  print('User: ${context.userId}');
  print('Token roles: ${context.tokenRoles}');
  print('Service roles: ${context.authzRoles}');
  print('Permissions: ${context.permissions}');
}
```

### Features
- 🔐 **Token Validation** - JWT authentication
- 🎭 **Role Management** - Both token-based and service-based roles
- 🔑 **Permission Control** - Fine-grained access control
- 🌐 **Service Integration** - External authorization services
- 📊 **Combined Context** - Unified view of identity and authorization
- ⚡ **Performance** - Optimized batch operations

## Examples

### Authentication Only Example

```dart
import 'package:kiss_auth/kiss_authentication.dart';

void main() async {
  final validator = JwtAuthValidator.hmac('secret-key');
  
  try {
    final metadata = await validator.validateToken(token);
    
    // Basic identity checks
    print('User: ${metadata.userId}');
    
    // Role checks from JWT claims
    if (metadata.hasRole('admin')) {
      print('User is admin');
    }
    
    // Permission checks from JWT claims
    if (metadata.hasPermission('read')) {
      print('User can read');
    }
    
  } catch (e) {
    print('Authentication failed: $e');
  }
}
```

### Authorization Only Example

```dart
import 'package:kiss_auth/kiss_authorization.dart';

void main() async {
  final config = AuthorizationServiceConfig(
    baseUrl: 'https://authz.example.com',
    apiKey: 'api-key',
  );
  
  final authzService = YourAuthorizationProvider(config);
  final authzClient = AuthorizationClient(authzService);
  
  // Check specific permission
  final canEdit = await authzClient.hasPermission(
    'user123',
    'document:edit',
    resource: 'document:456',
  );
  
  // Get all permissions for a resource
  final permissions = await authzClient.getEffectivePermissions(
    'user123',
    'documents',
  );
  
  // Batch check multiple permissions
  final results = await authzClient.checkPermissions(
    'user123',
    ['read', 'write', 'delete'],
    resource: 'documents',
  );
}
```

### Combined Example

```dart
import 'package:kiss_auth/kiss_authorization.dart';

void main() async {
  // Setup
  final authValidator = JwtAuthValidator.hmac('secret');
  final authzService = YourAuthorizationProvider(config);
  final authzServer = AuthorizationServer(authValidator, authzService);
  
  // Comprehensive authorization check
  final authorized = await authzServer.checkAuthorization(
    token,
    resource: 'documents',
    action: 'edit',
    requiredRoles: ['editor'],
    requiredPermissions: ['document:edit'],
    context: {'department': 'engineering'},
  );
  
  if (authorized) {
    // Get full context
    final context = await authzServer.authorize(
      token,
      resource: 'documents',
      action: 'edit',
    );
    
    // Access both identity and authorization data
    print('User: ${context.userId}');
    print('Token roles: ${context.tokenRoles}');
    print('Service roles: ${context.authzRoles}');
    print('Combined roles: ${context.allRoles}');
    print('Permissions: ${context.permissions}');
    print('Attributes: ${context.attributes}');
  }
}
```

## Module Choice Guide

### Use Authentication Only When:
- You only need JWT token validation
- Authorization logic is simple and can be handled in JWT claims
- You don't need external authorization services
- You want minimal dependencies

### Use Authorization Only When:
- You have your own authentication system
- You need complex role-based access control
- You want to integrate with external authorization services
- You need context-aware permissions

### Use Combined When:
- You need both JWT authentication and external authorization
- You want role information from both tokens and services
- You need comprehensive access control
- You're building a full-stack application

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
