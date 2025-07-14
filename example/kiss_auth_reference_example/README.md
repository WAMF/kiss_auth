# Kiss Auth Reference Example

This Flutter app demonstrates how to use all three Kiss Auth modules together with dependency injection, making it easy to swap providers for testing and different implementations.

## 📋 Features

- **Dependency Injection**: Uses `kiss_dependencies` to inject providers
- **Modular Architecture**: Demonstrates Login, Authentication, and Authorization modules working together
- **Provider Swapping**: Easy configuration to switch between different auth providers
- **Complete Demo**: Shows real authentication flows with role-based permissions

## 🏗️ Architecture

The app is structured around three Kiss Auth modules:

1. **Login Module** - Getting tokens with credentials (InMemoryLoginProvider)
2. **Authentication Module** - Validating JWT tokens (JwtAuthValidator)  
3. **Authorization Module** - Role/permission checks (InMemoryAuthorizationProvider)

All providers are injected using dependency injection, making it trivial to swap implementations.

## 🚀 Quick Start

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Login with demo credentials**:
   - **Admin**: admin@example.com / admin123
   - **Editor**: editor@example.com / editor123  
   - **User**: user@example.com / user123

## 🔧 Provider Configuration

### Current Setup (InMemory)

```dart
// In main.dart
runApp(MyApp(setup: setupInMemoryProviders));
```

### Swapping Providers

To use a different provider (e.g., PocketBase, Firebase), just pass a different setup function:

```dart
// For PocketBase (when available)
runApp(MyApp(setup: () => setupPocketBaseProviders(
  baseUrl: 'http://localhost:8090',
  jwtSecret: 'your-secret-key',
)));

// For Firebase (when available)  
runApp(MyApp(setup: () => setupFirebaseProviders(
  firebaseConfig: 'your-config',
  jwtSecret: 'your-secret-key',
)));
```

## 📁 Project Structure

```
lib/
├── di/
│   └── setup_functions.dart     # Setup functions for different providers
├── services/
│   └── auth_service.dart        # High-level auth service (uses direct resolve)
├── screens/
│   ├── login_screen.dart        # Login UI
│   └── home_screen.dart         # Main app UI with auth data
└── main.dart                    # App entry point & setup function selection
```

## 🔐 Dependency Injection Setup

Setup functions configure dependencies directly using `kiss_dependencies`:

```dart
void setupInMemoryProviders() {
  registerLazy<LoginProvider>(() => InMemoryLoginProvider());
  registerLazy<AuthValidator>(() => JwtAuthValidator.hmac('secret'));
  registerLazy<AuthorizationProvider>(() => InMemoryAuthorizationProvider());
  
  registerLazy<LoginService>(() => LoginService(resolve<LoginProvider>()));
  registerLazy<AuthorizationService>(() => AuthorizationService(
    resolve<AuthValidator>(),
    resolve<AuthorizationProvider>(),
  ));
}
```

Services use direct `resolve<T>()` calls when needed:

```dart
class AuthService {
  Future<AuthenticationData> login({required String email, required String password}) async {
    final loginService = resolve<LoginService>();
    final authValidator = resolve<AuthValidator>();
    final authorizationService = resolve<AuthorizationService>();
    
    // Use the resolved services...
  }
}
```

## 🎭 Demo Users & Permissions

| User | Roles | Permissions |
|------|-------|-------------|
| admin@example.com | admin, manager | user:create, user:delete, user:read, user:update |
| editor@example.com | editor, user | user:read, content:edit, content:publish |
| user@example.com | user | user:read |

## 🧪 Testing Different Providers

This reference example makes it easy to test new Kiss Auth provider implementations:

1. **Implement your provider** (e.g., `MyCustomLoginProvider`)
2. **Create a setup function** in `setup_functions.dart`
3. **Pass your setup function** to `MyApp` in main.dart
4. **Run the app** - everything else stays the same!

Example of adding a custom provider:

```dart
void setupMyCustomProviders() {
  registerLazy<LoginProvider>(() => MyCustomLoginProvider());
  registerLazy<AuthValidator>(() => JwtAuthValidator.hmac('my-secret'));
  registerLazy<AuthorizationProvider>(() => MyCustomAuthorizationProvider());
  
  registerLazy<LoginService>(() => LoginService(resolve<LoginProvider>()));
  registerLazy<AuthorizationService>(() => AuthorizationService(
    resolve<AuthValidator>(),
    resolve<AuthorizationProvider>(),
  ));
}

// Then in main.dart:
runApp(MyApp(setup: setupMyCustomProviders));
```

## 🔗 Integration with External Providers

The app is designed to work with external provider packages:

- **kiss_auth_firebase** - Firebase Authentication
- **kiss_auth_pocketbase** - PocketBase Authentication  
- **kiss_auth_auth0** - Auth0 Authentication
- **kiss_auth_supabase** - Supabase Authentication

Each provider package implements the Kiss Auth interfaces and can be injected seamlessly.

## 📖 Learning

This example demonstrates:

- ✅ **Clean Architecture** - Separation of concerns with DI
- ✅ **Provider Pattern** - Swappable implementations  
- ✅ **JWT Validation** - Token-based authentication
- ✅ **Role-Based Access** - Permission and role checking
- ✅ **State Management** - Handling auth state in Flutter
- ✅ **Error Handling** - Graceful error handling for auth flows

## 🤝 Contributing

This reference example should remain simple and focused. For complex features, create separate example apps.

## 📝 License

MIT License - see the Kiss Auth main repository for details.