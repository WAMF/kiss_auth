# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kiss Auth is a modular Dart library providing authentication and authorization functionality following the KISS (Keep It Simple, Stupid) principle. The library is split into three independent modules that can be used separately or together.

## Architecture

The project follows a modular architecture with three main components:

1. **Login Module** (`kiss_login`) - Credential-based authentication and token acquisition
2. **Authentication Module** (`kiss_authentication`) - JWT token validation and identity extraction
3. **Authorization Module** (`kiss_authorization`) - Role-based and permission-based access control

Key architectural decisions:
- Modules are completely independent - users can import only what they need
- Clean interface design with `LoginProvider`, `AuthValidator`, and `AuthorizationProvider` abstractions
- Clear separation of concerns: login (get tokens) → authentication (validate tokens) → authorization (check permissions)
- External provider support through abstract interfaces

## Common Commands

```bash
# Install dependencies
dart pub get

# Run all tests
dart test

# Run a specific test file
dart test test/authentication_test.dart
dart test test/authorization_test.dart
dart test test/kiss_auth_test.dart
dart test test/login_test.dart

# Analyze code for issues
dart analyze

# Format code
dart format .

# Check formatting without changing files
dart format --output=none --set-exit-if-changed .

# Run example files
dart run example/login_example.dart
dart run example/kiss_auth_example.dart
dart run example/separate_concerns_example.dart
dart run example/in_memory_provider_example.dart
```

## Code Structure

```
lib/
├── kiss_login.dart             # Public API for login module
├── kiss_authentication.dart    # Public API for authentication module
├── kiss_authorization.dart     # Public API for authorization module
└── src/
    ├── login/                  # Login module implementation
    │   ├── login_provider.dart        # Abstract interface for external providers
    │   ├── login_credentials.dart     # Credential types (username/password, API key, etc.)
    │   ├── login_service.dart         # Login coordination service
    │   └── login_provider_in_memory.dart # Testing implementation
    ├── authentication/         # Authentication module implementation (planned)
    │   └── authentication_*.dart
    └── authorization/          # Authorization module implementation (planned)
        └── authorization_*.dart
```

The `src/` directory contains implementation details that should not be imported directly by users. All public APIs are exported through the main module files.

Note: Currently authentication and authorization files are in the root `src/` directory but should be moved to subdirectories for consistency.

## Testing Approach

Tests are organized by module:
- `login_test.dart` - Tests for login providers and credential handling
- `authentication_test.dart` - Tests for JWT validation and authentication
- `authorization_test.dart` - Tests for authorization providers and logic
- `kiss_auth_test.dart` - Integration tests for combined usage

When adding features, ensure corresponding tests are added to the appropriate test file.

## External Provider Integration

The login module is designed to work with external authentication providers:

- **kiss_auth_firebase** - Firebase Authentication
- **kiss_auth_pocketbase** - PocketBase Authentication
- **kiss_auth_auth0** - Auth0 Authentication
- **kiss_auth_supabase** - Supabase Authentication

Each provider package implements the `LoginProvider` interface to provide seamless integration with the Kiss Auth ecosystem.