## 0.2.0

### ✨ New Features
- **User Creation**: Added `createUser` method to `LoginProvider` interface
- **UserCreationCredentials**: New credential type for user registration
- **Enhanced LoginService**: Added `createUser` and `createUserWithEmail` methods
- **Signup Support**: Updated reference example app with complete signup flow
- **Comprehensive Tests**: Added full test suite for user creation functionality

### 🔧 Improvements
- **InMemoryLoginProvider**: Now supports user creation with duplicate email checking
- **AuthService**: Enhanced with proper signup functionality
- **Example App**: Added signup screen with form validation and navigation

### 🗂️ Example Updates
- Removed redundant example files in favor of comprehensive reference app
- Added signup screen with password confirmation and display name support
- Updated login screen with signup navigation link

## 0.1.0

Initial release with three independent modules:

### 🔐 Authentication Module (`kiss_authentication`)
- JWT token validation (HMAC & RSA)
- Extract user identity from tokens

### 👤 Login Module (`kiss_login`) 
- Credential-based authentication interfaces
- Support for username/password, email/password, API keys, OAuth, anonymous
- Abstract `LoginProvider` for external implementations (Firebase, PocketBase, Auth0, etc.)

### 🛡️ Authorization Module (`kiss_authorization`)
- Role-based and permission-based access control
- In-memory provider for testing
- Context-aware authorization

Each module can be used independently or combined as needed.
