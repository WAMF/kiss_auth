# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kiss Auth is a modular Dart library providing authentication and authorization functionality following the KISS (Keep It Simple, Stupid) principle. The library is split into two independent modules that can be used separately or together.

## Architecture

The project follows a modular architecture with two main components:

1. **Authentication Module** (`kiss_authentication`) - JWT token validation and identity extraction
2. **Authorization Module** (`kiss_authorization`) - Role-based and permission-based access control

Key architectural decisions:
- Modules are completely independent - users can import only what they need
- Clean interface design with `AuthValidator` and `AuthorizationProvider` abstractions
- Separation of identity (AuthMetadata) from authorization (AuthorizationData)

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

# Analyze code for issues
dart analyze

# Format code
dart format .

# Check formatting without changing files
dart format --output=none --set-exit-if-changed .

# Run example files
dart run example/kiss_auth_example.dart
dart run example/separate_concerns_example.dart
dart run example/in_memory_provider_example.dart
```

## Code Structure

```
lib/
├── kiss_authentication.dart    # Public API for authentication module
├── kiss_authorization.dart     # Public API for authorization module
└── src/
    ├── authentication_*.dart   # Internal authentication implementation
    └── authorization_*.dart    # Internal authorization implementation
```

The `src/` directory contains implementation details that should not be imported directly by users. All public APIs are exported through the main module files.

## Testing Approach

Tests are organized by module:
- `authentication_test.dart` - Tests for JWT validation and authentication
- `authorization_test.dart` - Tests for authorization providers and logic
- `kiss_auth_test.dart` - Integration tests for combined usage

When adding features, ensure corresponding tests are added to the appropriate test file.