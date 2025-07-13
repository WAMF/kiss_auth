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
