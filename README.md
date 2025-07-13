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
│   AuthValidator      │    │ AuthorizationProvider│    │ AuthorizationService │
│   (JWT validation)   │    │ (External service)   │    │ (Auth + Authz)       │
│         │            │    │         │            │    │         │            │
│         ▼            │    │         ▼            │    │         ▼            │
│ AuthenticationData   │    │ AuthorizationData    │    │AuthorizationContext  │
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
  final authData = await validator.validateToken(jwtToken);
  print('User ID: ${authData.userId}');
  print('Roles: ${authData.jwt.getClaim<List>('roles') ?? []}');
  print('Claims: ${authData.claims}');
  print('Subject: ${authData.jwt.subject}');
  print('Expiration: ${authData.jwt.expiration}');
} catch (e) {
  print('Invalid token: $e');
}
```

### Features
- 🔐 **JWT Token Validation** - HMAC and RSA signature algorithms
- 👤 **Identity Extraction** - User ID and claims from tokens
- 🔒 **JWT Claims Access** - Access to standard and custom JWT claims through extension methods
- 📦 **Lightweight** - Minimal dependencies, focused functionality
- 🧪 **Well Tested** - Comprehensive test coverage

## Authorization Only

If you have your own authentication system but need role-based access control:

```dart
import 'package:kiss_auth/kiss_authorization.dart';

// Configure authorization provider (example with in-memory provider)
final authzProvider = InMemoryAuthorizationProvider();

// Set up user authorization data
authzProvider.setUserData(
  'user123',
  const AuthorizationData(
    userId: 'user123',
    roles: ['editor', 'user'],
    permissions: ['document:read', 'document:edit'],
    attributes: {'department': 'engineering'},
  ),
);

final authzClient = AuthorizationClient(authzProvider);

// Check user permissions
final canEdit = await authzClient.hasPermission(
  'user123',
  'document:edit',
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
final authzProvider = InMemoryAuthorizationProvider();

// Set up authorization data
authzProvider.setUserData(
  'user123',
  const AuthorizationData(
    userId: 'user123',
    roles: ['editor', 'user'],
    permissions: ['document:edit', 'document:read'],
    attributes: {'department': 'engineering'},
  ),
);

final authzService = AuthorizationService(authValidator, authzProvider);

// Validate token and check permissions in one call
final authorized = await authzService.checkAuthorization(
  token,
  resource: 'documents',
  requiredRoles: ['editor'],
  requiredPermissions: ['document:edit'],
);

if (authorized) {
  // User is authenticated and authorized
  final context = await authzService.authorize(token, resource: 'documents');
  print('User: ${context.userId}');
  print('Token roles: ${context.tokenRoles}');
  print('Provider roles: ${context.authzRoles}');
  print('All roles: ${context.allRoles}');
  print('Permissions: ${context.allPermissions}');
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
    final authData = await validator.validateToken(token);
    
    // Basic identity checks
    print('User: ${authData.userId}');
    print('Subject: ${authData.jwt.subject}');
    print('Expiration: ${authData.jwt.expiration}');
    
    // Access JWT claims
    final roles = authData.jwt.getClaim<List>('roles')?.cast<String>() ?? <String>[];
    final permissions = authData.jwt.getClaim<List>('permissions')?.cast<String>() ?? <String>[];
    
    print('Roles: $roles');
    print('Permissions: $permissions');
    
    // Check specific claims
    if (roles.contains('admin')) {
      print('User is admin');
    }
    
    if (permissions.contains('read')) {
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
  // Set up in-memory authorization provider
  final authzProvider = InMemoryAuthorizationProvider();
  
  // Configure user authorization data
  authzProvider.setUserData(
    'user123',
    const AuthorizationData(
      userId: 'user123',
      roles: ['editor', 'user'],
      permissions: ['document:read', 'document:edit', 'document:delete'],
      attributes: {'department': 'engineering', 'level': 'senior'},
    ),
  );
  
  final authzClient = AuthorizationClient(authzProvider);
  
  // Check specific permission
  final canEdit = await authzClient.hasPermission('user123', 'document:edit');
  print('Can edit: $canEdit');
  
  // Get all permissions for a resource
  final permissions = await authzClient.getEffectivePermissions('user123', 'documents');
  print('Permissions: $permissions');
  
  // Batch check multiple permissions
  final results = await authzClient.checkPermissions(
    'user123',
    ['document:read', 'document:write', 'document:delete'],
  );
  print('Permission results: $results');
  
  // Check roles
  final hasEditorRole = await authzClient.hasRole('user123', 'editor');
  print('Is editor: $hasEditorRole');
}
```

### Combined Example

```dart
import 'package:kiss_auth/kiss_authorization.dart';

void main() async {
  // Setup authentication and authorization
  final authValidator = JwtAuthValidator.hmac('secret');
  final authzProvider = InMemoryAuthorizationProvider();
  
  // Configure authorization data
  authzProvider.setUserData(
    'user123',
    const AuthorizationData(
      userId: 'user123',
      roles: ['editor', 'user'],
      permissions: ['document:edit', 'document:read'],
      attributes: {'department': 'engineering', 'level': 'senior'},
    ),
  );
  
  final authzService = AuthorizationService(authValidator, authzProvider);
  
  // Comprehensive authorization check
  final authorized = await authzService.checkAuthorization(
    token,
    resource: 'documents',
    requiredRoles: ['editor'],
    requiredPermissions: ['document:edit'],
  );
  
  if (authorized) {
    // Get full context
    final context = await authzService.authorize(token, resource: 'documents');
    
    // Access both identity and authorization data
    print('User: ${context.userId}');
    print('Token roles: ${context.tokenRoles}');
    print('Provider roles: ${context.authzRoles}');
    print('All roles: ${context.allRoles}');
    print('Token permissions: ${context.tokenPermissions}');
    print('Provider permissions: ${context.authzPermissions}');
    print('All permissions: ${context.allPermissions}');
    print('Attributes: ${context.attributes}');
    
    // Use context for fine-grained checks
    if (context.hasRole('editor')) {
      print('User can edit');
    }
    
    if (context.hasPermission('document:edit')) {
      print('User has edit permission');
    }
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
