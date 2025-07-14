import 'package:flutter/material.dart';
import 'package:kiss_auth/kiss_authentication.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthenticationData authData;

  const HomeScreen({super.key, required this.authData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authData = widget.authData; // Cache the authData reference

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Kiss Auth Dashboard',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            ]
                          : [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You are successfully authenticated',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // User Info Section
                _buildSection(
                  context,
                  title: 'User Information',
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow('User ID', widget.authData.userId),
                    _buildInfoRow('Email',
                        widget.authData.claims['email']?.toString() ?? 'N/A'),
                    _buildInfoRow('Username',
                        widget.authData.claims['username']?.toString() ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 16),

                // Roles Section
                _buildSection(
                  context,
                  title: 'Roles',
                  icon: Icons.admin_panel_settings_outlined,
                  children: [
                    if (widget.authData.jwt
                            .getClaim<List<dynamic>>('roles')
                            ?.isNotEmpty ??
                        false)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (widget.authData.jwt
                                    .getClaim<List<dynamic>>('roles') ??
                                [])
                            .map((role) => _buildBadge(
                                  context,
                                  role.toString(),
                                  _getRoleColor(role.toString()),
                                ))
                            .toList(),
                      )
                    else
                      Text(
                        'No roles assigned',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Permissions Section
                _buildSection(
                  context,
                  title: 'Permissions',
                  icon: Icons.security_outlined,
                  children: [
                    if (authData.jwt
                            .getClaim<List<dynamic>>('permissions')
                            ?.isNotEmpty ??
                        false)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (authData.jwt
                                    .getClaim<List<dynamic>>('permissions') ??
                                [])
                            .map((permission) => _buildBadge(
                                  context,
                                  permission.toString(),
                                  Theme.of(context).colorScheme.secondary,
                                ))
                            .toList(),
                      )
                    else
                      Text(
                        'No permissions assigned',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Token Info Section
                _buildSection(
                  context,
                  title: 'Token Information',
                  icon: Icons.key_outlined,
                  children: [
                    _buildInfoRow(
                      'Issued At',
                      authData.jwt.issuedAt != null
                          ? _formatDate(authData.jwt.issuedAt!)
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      'Expires At',
                      authData.jwt.expiration != null
                          ? _formatDate(authData.jwt.expiration!)
                          : 'N/A',
                    ),
                    if (authData.jwt.expiration != null)
                      _buildInfoRow(
                        'Time Remaining',
                        _getTimeRemaining(authData.jwt.expiration!),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Authorization Context Section
                if (authService.currentAuthContext != null) ...[
                  _buildSection(
                    context,
                    title: 'Authorization Context',
                    icon: Icons.shield_outlined,
                    children: [
                      _buildInfoRow(
                        'Provider Roles',
                        authService.currentAuthContext!.authzRoles.join(', '),
                      ),
                      _buildInfoRow(
                        'All Roles',
                        authService.currentAuthContext!.allRoles.join(', '),
                      ),
                      _buildInfoRow(
                        'Provider Permissions',
                        authService.currentAuthContext!.permissions.join(', '),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? color.withValues(alpha: 0.9) : color,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'editor':
        return Colors.blue;
      case 'user':
        return Colors.green;
      case 'manager':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _getTimeRemaining(DateTime expiration) {
    final now = DateTime.now();
    final difference = expiration.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return '${difference.inSeconds} seconds';
    }
  }
}