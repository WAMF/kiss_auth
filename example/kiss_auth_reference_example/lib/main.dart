import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'setup_functions.dart';

void main() {
  // Configure dependencies - easily swap implementations by changing this:
  runApp(MyApp(setup: setupInMemoryProviders));

  // To use different providers, just pass a different setup function:
  // runApp(MyApp(setup: () => setupPocketBaseProviders(
  //   baseUrl: 'http://localhost:8090',
  //   jwtSecret: 'your-secret-key',
  // )));

  // Or for Firebase:
  // runApp(MyApp(setup: () => setupFirebaseProviders(
  //   firebaseConfig: 'your-config',
  //   jwtSecret: 'your-secret-key',
  // )));
}

class MyApp extends StatelessWidget {
  final SetupFunction setup;

  const MyApp({super.key, required this.setup});

  @override
  Widget build(BuildContext context) {
    // Call the setup function to configure dependencies
    setup();

    return MaterialApp(
      title: 'Kiss Auth Reference Example',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F172A),
          secondary: Color(0xFF64748B),
          surface: Color(0xFFFFFFFF),
          surfaceContainerHighest: Color(0xFFF1F5F9),
          outline: Color(0xFFE2E8F0),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE2E8F0),
          secondary: Color(0xFF94A3B8),
          surface: Color(0xFF020817),
          surfaceContainerHighest: Color(0xFF0F172A),
          outline: Color(0xFF334155),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await _authService.initialize();

    if (!mounted) return;

    if (_authService.isAuthenticated && _authService.currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(authData: _authService.currentUser!),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 24),
            Text(
              'Kiss Auth',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
