import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_form_provider.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/auth/presentation/widgets/auth_header.dart';
import 'package:soulsync/features/auth/presentation/widgets/remember_me_checkbox.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/buttons/app_text_button.dart';
import 'package:soulsync/shared/widgets/inputs/app_email_text_field.dart';
import 'package:soulsync/shared/widgets/inputs/app_password_text_field.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

import 'package:soulsync/core/widgets/server_url_dialog.dart';

/// Production-ready Login Screen for SoulSync supporting Riverpod state management and mock auth.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final formNotifier = ref.read(loginFormNotifierProvider.notifier);
    formNotifier.setEmail(_emailController.text);
    formNotifier.setPassword(_passwordController.text);

    final isValid = formNotifier.validateForm();
    if (!isValid) return;

    final formState = ref.read(loginFormNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    final success = await authNotifier.login(
      email: formState.email,
      password: formState.password,
      rememberMe: formState.rememberMe,
    );

    if (mounted && !success) {
      final authState = ref.read(authNotifierProvider);
      if (authState.errorMessage != null) {
        AppSnackBars.showError(context, authState.errorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final formState = ref.watch(loginFormNotifierProvider);
    final formNotifier = ref.read(loginFormNotifierProvider.notifier);
    final isAuthenticating = authState.status == AuthStatus.authenticating;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
          actions: [
            IconButton(
              icon: const Icon(Icons.dns_rounded, color: Colors.white70),
              tooltip: 'Server Settings',
              onPressed: () => ServerUrlDialog.show(context),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Welcome Back',
                  subtitle: 'Sign in to access your shared music sync room',
                ),
                AppSpacing.vGapXL,

                // Email Input
                AppEmailTextField(
                  controller: _emailController,
                  enabled: !isAuthenticating,
                  onChanged: (val) => formNotifier.setEmail(val),
                ),
                if (formState.emailError != null) ...[
                  AppSpacing.vGapXS,
                  Text(
                    formState.emailError!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
                AppSpacing.vGapMD,

                // Password Input
                AppPasswordTextField(
                  controller: _passwordController,
                  enabled: !isAuthenticating,
                  onChanged: (val) => formNotifier.setPassword(val),
                ),
                if (formState.passwordError != null) ...[
                  AppSpacing.vGapXS,
                  Text(
                    formState.passwordError!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
                AppSpacing.vGapSM,

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RememberMeCheckbox(
                      value: formState.rememberMe,
                      onChanged: isAuthenticating
                          ? (_) {}
                          : (val) {
                              if (val != null) {
                                formNotifier.toggleRememberMe(val);
                              }
                            },
                    ),
                    AppTextButton(
                      label: 'Forgot Password?',
                      onPressed: () {
                        AppSnackBars.showInfo(
                          context,
                          'Password reset will be supported via email verification in Sprint 2.0.',
                        );
                      },
                    ),
                  ],
                ),
                AppSpacing.vGapXL,

                // Submit Button using Sprint 1.2 Design System
                AppPrimaryButton(
                  label: 'Sign In',
                  icon: Icons.login_rounded,
                  isLoading: isAuthenticating,
                  isFullWidth: true,
                  onPressed: isAuthenticating ? null : _handleLogin,
                ),
                AppSpacing.vGapLG,

                // Create Account Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
