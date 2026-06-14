import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/currency_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/main_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Force login every time (as requested)
  await FirebaseAuth.instance.signOut();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CurrencyProvider(),
      child: const SafarSathiApp(),
    ),
  );
}

class SafarSathiApp extends StatefulWidget {
  const SafarSathiApp({super.key});

  @override
  State<SafarSathiApp> createState() => _SafarSathiAppState();
}

class _SafarSathiAppState extends State<SafarSathiApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Move splash screen logic here
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafarSathi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showSplash 
        ? const SplashScreen() // Remove nextScreen parameter reliance
        : StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData) {
                return const MainScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
    );
  }
}
