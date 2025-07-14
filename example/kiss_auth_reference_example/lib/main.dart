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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
