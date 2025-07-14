import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kiss_auth/kiss_authorization.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthenticationData authData;
  final AuthService _authService = AuthService();

  HomeScreen({super.key, required this.authData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiss Auth Reference Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 16),
            _buildAuthenticationCard(context),
            const SizedBox(height: 16),
            _buildAuthorizationCard(context),
            const SizedBox(height: 16),
            _buildClaimsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Kiss Auth!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'This reference example demonstrates all three Kiss Auth modules working together with dependency injection. You can easily swap providers by changing the configuration in main.dart.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Login Module - Getting tokens with credentials'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Authentication Module - Validating JWT tokens'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Authorization Module - Role/permission checks'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', authData.userId),
            _buildInfoRow('Provider', 'InMemoryLoginProvider'),
            _buildInfoRow('Token Type', 'JWT'),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizationCard(BuildContext context) {
    final authContext = _authService.currentAuthContext;
    if (authContext == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Authorization Data',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text('Authorization context not available'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authorization Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('JWT Roles', authContext.tokenRoles.join(', ')),
            _buildInfoRow('Service Roles', authContext.authzRoles.join(', ')),
            _buildInfoRow('All Roles', authContext.allRoles.join(', ')),
            _buildInfoRow('Permissions', authContext.permissions.join(', ')),
            const SizedBox(height: 16),
            Text(
              'Permission Checks:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildPermissionCheck(authContext, 'user:read'),
            _buildPermissionCheck(authContext, 'user:create'),
            _buildPermissionCheck(authContext, 'user:delete'),
            _buildPermissionCheck(authContext, 'content:edit'),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCheck(AuthorizationContext context, String permission) {
    final hasPermission = context.hasPermission(permission);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            color: hasPermission ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$permission: ${hasPermission ? 'Allowed' : 'Denied'}'),
        ],
      ),
    );
  }

  Widget _buildClaimsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JWT Claims',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _prettyPrintJson(authData.claims),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _prettyPrintJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
}