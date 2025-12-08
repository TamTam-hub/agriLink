import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../main_screen.dart';
import '../farmer/farmer_main_screen.dart';
import 'signup_screen.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/firebase_firestore_service.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  final bool isBuyer;

  const LoginScreen({
    super.key,
    required this.isBuyer,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Capture navigation/messenger before async work
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseUser = await _authService
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          )
          .timeout(const Duration(seconds: 20), onTimeout: () {
        throw 'Login timed out. Please try again.';
      });

      if (supabaseUser != null) {
        // Use Supabase user ID for Firestore lookups (Supabase-only auth)
        final supabaseUid = supabaseUser.id;
        UserModel? userModel = await _firestoreService
            .getUserData(supabaseUid)
            .timeout(const Duration(seconds: 10), onTimeout: () => null);
        if (userModel != null) {
          if (userModel.isBuyer == widget.isBuyer) {
            if (!mounted) return;
            navigator.pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    userModel.isBuyer ? const MainScreen() : const FarmerMainScreen(),
              ),
            );
          } else {
            await _authService.signOut();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'This account is registered as a ${userModel.isBuyer ? 'Buyer' : 'Farmer'}. Please select the correct role on the splash screen.',
                ),
              ),
            );
            // Top banner removed; snackbar is sufficient
          }
        } else {
          // Auto-provision a Firestore user profile on first login
          final email = supabaseUser.email ?? '';
          final suggestedName = email.isNotEmpty ? email.split('@').first : 'New User';
          final newUser = UserModel(
            uid: supabaseUid,
            name: suggestedName,
            email: email,
            isBuyer: widget.isBuyer,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          try {
            await _firestoreService
                .saveUserData(newUser)
                .timeout(const Duration(seconds: 10), onTimeout: () {
              throw 'Creating profile timed out. Please try again.';
            });
            if (!mounted) return;
            navigator.pushReplacement(
              MaterialPageRoute(
                builder: (context) => widget.isBuyer ? const MainScreen() : const FarmerMainScreen(),
              ),
            );
            // Top banner removed
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text(e.toString().isEmpty ? 'Could not create user profile. Please try again.' : e.toString())),
            );
            // Top banner removed; snackbar already shown
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      final message = _mapAuthErrorToMessage(e.toString());
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapAuthErrorToMessage(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('unexpected_failure') || msg.contains('statuscode: 500') || msg.contains('refresh_token_hmac_key')) {
      return 'Supabase Auth error (500). Please verify your project URL/anon key and Auth settings.';
    }
    if (msg.contains('invalid login') || msg.contains('invalid credentials') || msg.contains('invalid email or password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('email not confirmed') || msg.contains('email_not_confirmed')) {
      return 'Please check your inbox and confirm your email.';
    }
    if (msg.contains('network') || msg.contains('timeout')) {
      return 'Network issue. Please check your connection and try again.';
    }
    if (msg.contains('signin_null_user')) {
      return 'Please check your inbox and confirm your email.';
    }
    return 'Sign in failed. Please try again.';
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    bool isResetLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: resetEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isResetLoading
                      ? null
                      : () async {
                          if (resetEmailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your email')),
                            );
                            return;
                          }

                          // Capture objects that depend on BuildContext before any `await`
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          setState(() {
                            isResetLoading = true;
                          });

                          try {
                            await _authService.sendPasswordResetEmail(
                              resetEmailController.text.trim(),
                            );
                            // Use captured references instead of calling `of(context)` after await
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent! Check your inbox.'),
                              ),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            setState(() {
                              isResetLoading = false;
                            });
                          }
                        },
                  child: isResetLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Reset Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              forceElevated: false,
              iconTheme: const IconThemeData(color: AppColors.primary),
              floating: true,
              snap: true,
              pinned: false,
            ),
            SliverToBoxAdapter(
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
                      'Welcome to AgriLink!',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: MediaQuery.of(context).size.width * 0.063,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                    Text(
                      'Sign in to browse local products',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: MediaQuery.of(context).size.width * 0.037,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    // Login Form
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
                          // Removed top error banner per request
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
                          SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(),
                              child: Text(
                                'Forgot password?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          CustomButton(
                            text: _isLoading ? 'Signing In...' : 'Sign In',
                            onPressed: _isLoading ? null : () => _handleLogin(),
                            width: double.infinity,
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTextStyles.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupScreen(isBuyer: widget.isBuyer),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
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
                    // Why Choose AgriLink Section
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
          ],
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
