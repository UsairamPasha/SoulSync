import 'package:flutter/material.dart';
import 'package:soulsync/features/auth/presentation/screens/login_screen.dart';

/// Backward compatibility entry point delegating to LoginScreen.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
