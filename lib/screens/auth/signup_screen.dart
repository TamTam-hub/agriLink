import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/firebase_firestore_service.dart';
import '../../models/user_model.dart';


class SignupScreen extends StatefulWidget {
  final bool isBuyer;

  const SignupScreen({
    super.key,
    required this.isBuyer,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Basic validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Quick connectivity check to avoid long timeouts when emulator is offline
    try {
      final result = await InternetAddress.lookup('jsapqhfqmzqttxdgcyzc.supabase.co')
          .timeout(const Duration(seconds: 5));
      if (result.isEmpty || result.first.rawAddress.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No internet connection. Please check emulator/network.')),
        );
        return;
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check emulator/network.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseUser = await _authService
          .signUpWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          )
          .timeout(const Duration(seconds: 45), onTimeout: () {
        throw 'Signup timed out. Please try again.';
      });

      if (supabaseUser != null) {
        // Save Firestore user with Supabase UID
        final supabaseUid = supabaseUser.id;
        UserModel userModel = UserModel(
          uid: supabaseUid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          isBuyer: widget.isBuyer,
          createdAt: DateTime.now(),
        );

        bool saveTimedOut = false;
        try {
          await _firestoreService
              .saveUserData(userModel)
              .timeout(const Duration(seconds: 15), onTimeout: () {
            saveTimedOut = true;
            return; // treat as soft success
          });
        } catch (e) {
          // Hard failure still surfaces
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(content: Text('Profile save failed: ${e.toString()}')),
          );
        }

        // Supabase manages verification emails automatically on sign-up

        if (!mounted) return;

        // Show success message
        messenger.showSnackBar(
          SnackBar(
            content: Text(saveTimedOut
                ? 'Account created (profile save slow). You can log in now.'
                : 'Account created successfully! Please log in.'),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to login screen immediately
        if (!mounted) return;
        navigator.pop();
      }
      // If Supabase requires email confirmation, `supabaseUser` can be null but the account was created.
      // Treat as success and prompt the user to log in after confirming email.
      if (supabaseUser == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Account created. Please verify your email, then log in.'),
            duration: Duration(seconds: 3),
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      if (!mounted) return;
      final message = _mapSignupErrorToMessage(e.toString());
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapSignupErrorToMessage(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('unexpected_failure') || msg.contains('statuscode: 500') || msg.contains('refresh_token_hmac_key')) {
      return 'Supabase Auth error (500). Please verify your project URL/anon key and Auth settings.';
    }
    if (msg.contains('signup timed out')) return 'Signup timed out. Please try again.';
    if (msg.contains('saving profile timed out')) return 'Saving profile timed out. Please try again.';
    if (msg.contains('already exists') || msg.contains('email already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('weak password')) {
      return 'Password is too weak. Please use at least 8 characters.';
    }
    if (msg.contains('network') || msg.contains('timeout')) {
      return 'Network issue. Please check your connection and try again.';
    }
    return 'Sign up failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // Logo
                Container(
                  width: MediaQuery.of(context).size.width * 0.21,
                  height: MediaQuery.of(context).size.width * 0.21,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Icon(
                    Icons.agriculture,
                    size: MediaQuery.of(context).size.width * 0.13,
                    color: AppColors.textWhite,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                // Welcome Text
                Text(
                  'Join AgriLink!',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.063,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                Text(
                  'Create your account to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: MediaQuery.of(context).size.width * 0.037,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // Signup Form
                Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        labelText: 'Full Name',
                        hintText: 'Juan Dela Cruz',
                        prefixIcon: Icons.person_outline,
                        controller: _nameController,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      CustomTextField(
                        labelText: 'Email',
                        hintText: 'juan@example.com',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      CustomTextField(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        onSuffixIconTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      CustomTextField(
                        labelText: 'Confirm Password',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        obscureText: _obscureConfirmPassword,
                        controller: _confirmPasswordController,
                        onSuffixIconTap: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      CustomButton(
                        text: _isLoading ? 'Creating Account...' : 'Sign Up',
                        onPressed: _isLoading ? () {} : _handleSignup,
                        width: double.infinity,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Log In',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // Why Choose AgriLink Section (same as login)
                Text(
                  'Why Choose AgriLink?',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.053,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildFeatureCard(
                  icon: Icons.eco,
                  title: 'Fresh & Local',
                  description:
                      'Connect directly with local farmers for the freshest produce',
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildFeatureCard(
                  icon: Icons.handshake,
                  title: 'Fair Trade',
                  description:
                      'Ensuring farmers get fair prices for their hard work',
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildFeatureCard(
                  icon: Icons.phone,
                  title: 'Easy Communication',
                  description:
                      'Message farmers directly to discuss your needs',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: MediaQuery.of(context).size.width * 0.08,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.042,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
