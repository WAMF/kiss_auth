import 'package:flutter/material.dart';

import 'package:kiss_auth_reference_example/screens/home_screen.dart';
import 'package:kiss_auth_reference_example/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final displayName = _displayNameController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please fill in all required fields';
        });
      }
      return;
    }

    if (!email.contains('@')) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please enter a valid email';
        });
      }
      return;
    }

    if (password.length < 6) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Password must be at least 6 characters';
        });
      }
      return;
    }

    if (password != confirmPassword) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final authData = await _authService.signup(
        email: email,
        password: password,
        displayName: displayName.isNotEmpty ? displayName : null,
      );

      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => HomeScreen(authData: authData),
        ),
      );
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Icon(
                    Icons.person_add_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Signup Form
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Display Name Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Display Name (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your display name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Confirm Password *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Error Message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.red.shade900.withValues(alpha: 0.2)
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark 
                                  ? Colors.red.shade700
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: isDark
                                    ? Colors.red.shade400
                                    : Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.red.shade400
                                        : Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
