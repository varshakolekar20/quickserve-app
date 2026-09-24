import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer account created! Welcome to QuickServe.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    } else if (mounted) {
      final error =
          ref.read(authProvider).errorMessage ?? 'Registration failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Sign Up',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create an account to book certified home & office services',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _fullNameController,
                  label: AppStrings.fullName,
                  hint: 'e.g. Varsha Kolekar',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => Validators.validateRequired(v, 'Full name'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: AppStrings.phoneNumber,
                  hint: '+1 (555) 012-3456',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPassword,
                  hint: 'Re-enter password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => Validators.validateConfirmPassword(
                      v, _passwordController.text),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: AppStrings.register,
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        AppStrings.login,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
