
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // 1. Initial authentication resolution
    if (auth.isLoading && !auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: colors.primaryContainer == colors.primary
                      ? null
                      : LinearGradient(
                    colors: [
                      colors.primary,
                      colors.secondary,
                    ],
                  ),
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  size: 40,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'NEURON',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Second Brain for the Digital World',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Unauthenticated user
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // 3. Authenticated but email not verified
    if (!auth.isEmailVerified) {
      return const EmailVerificationScreen();
    }

    // 4. Authenticated and verified user
    return const MainNavigationScreen();
  }
}
