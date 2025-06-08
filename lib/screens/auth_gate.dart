// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// REMOVE: import 'home_screen.dart'; // We no longer go directly here
import 'main_screen.dart'; // <-- ADD Import for the new main screen
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null && authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If user is logged in, show MainScreen (which contains the BottomNavBar)
        else if (authProvider.user != null) {
          return const MainScreen(); // <--- CHANGE This line
        }
        // Otherwise, show LoginScreen
        else {
          return const LoginScreen();
        }
      },
    );
  }
}