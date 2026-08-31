import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';
import 'package:soulsync/features/auth/presentation/providers/register_provider.dart';
import 'package:soulsync/shared/widgets/buttons/app_primary_button.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';
import 'package:soulsync/shared/widgets/scaffold/app_scaffold.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    if (password.length < 8) return false;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    return hasUpper && hasLower && hasDigit;
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref.read(registerNotifierProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nicknameController.text.trim().isNotEmpty
              ? _nicknameController.text.trim()
              : null,
        );

    if (success && mounted) {
      AppSnackBars.showSuccess(
          context, 'Account created! Welcome to SoulSync.');
      context.go('/home');
    } else if (mounted) {
      final registerState = ref.read(registerNotifierProvider);
      if (registerState.errorMessage != null) {
        AppSnackBars.showError(context, registerState.errorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerNotifierProvider);
    final isLoading = registerState.status == RegisterStatus.loading;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join SoulSync',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your private couple space to share music and chat.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vGapXL,

                // First Name & Last Name
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _firstNameController,
                        labelText: 'First Name',
                        hintText: 'John',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'First name required';
                          }
                          return null;
                        },
                      ),
                    ),
                    AppSpacing.hGapMD,
                    Expanded(
                      child: AppTextField(
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        hintText: 'Doe',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Last name required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGapMD,

                // Email
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email address required';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                AppSpacing.vGapMD,

                // Optional Couple Nickname
                AppTextField(
                  controller: _nicknameController,
                  labelText: 'Couple Nickname (Optional)',
                  hintText: 'e.g. My Soulmate',
                  prefixIcon: const Icon(Icons.favorite_border_rounded),
                ),
                AppSpacing.vGapMD,

                // Password
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Min 8 chars (A-z, 0-9)',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password required';
                    }
                    if (!_validatePassword(val)) {
                      return 'Must be 8+ chars with uppercase, lowercase & number';
                    }
                    return null;
                  },
                ),
                AppSpacing.vGapMD,

                // Confirm Password
                AppTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                AppSpacing.vGapXL,

                // Create Account Button
                AppPrimaryButton(
                  label: 'Create Account',
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading ? null : _handleRegister,
                ),
                AppSpacing.vGapLG,

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text('Sign In'),
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
