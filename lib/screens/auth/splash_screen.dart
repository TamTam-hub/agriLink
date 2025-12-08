import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import 'login_screen.dart';
import '../../services/firebase_firestore_service.dart';

class SplashScreen extends StatefulWidget {
  final bool skipLoading;

  const SplashScreen({
    super.key,
    this.skipLoading = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool isBuyer = true;
  bool _isLoading = true;
  AnimationController? _loadingController;
  late Animation<double> _loadingOpacityAnimation;
  late Animation<double> _loadingScaleAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.skipLoading) {
      _isLoading = false;
      return;
    }

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _loadingOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController!, curve: Curves.easeIn),
    );
    _loadingScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController!, curve: Curves.elasticOut),
    );

    _loadingController!.forward();

    // Check for existing session
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkExistingSession();
      }
    });
  }

  Future<void> _checkExistingSession() async {
    try {
      // Check Supabase session
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        // User is logged in via Supabase, determine role from Firestore
        final firestoreService = FirebaseFirestoreService();
        final userProfile = await firestoreService.getUserProfile(supabaseUser.id);
        
        if (mounted) {
          if (userProfile != null) {
            // Navigate to appropriate home based on role (isBuyer flag)
            if (userProfile.isBuyer) {
              Navigator.of(context).pushReplacementNamed('/buyer_home');
            } else {
              Navigator.of(context).pushReplacementNamed('/farmer_home');
            }
          } else {
            // Profile not found, go to login
            setState(() {
              _isLoading = false;
            });
          }
        }
        return;
      }

      // Also check Firebase Auth for fallback
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        final firestoreService = FirebaseFirestoreService();
        final userProfile = await firestoreService.getUserProfile(fbUser.uid);
        
        if (mounted) {
          if (userProfile != null) {
            if (userProfile.isBuyer) {
              Navigator.of(context).pushReplacementNamed('/buyer_home');
            } else {
              Navigator.of(context).pushReplacementNamed('/farmer_home');
            }
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
        return;
      }

      // No session found, show role selection
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Error checking session, show role selection
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _loadingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingScreen() : _buildMainScreen(),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return AnimatedBuilder(
      animation: _loadingController!,
      builder: (context, child) {
        return Opacity(
          opacity: _loadingOpacityAnimation.value,
          child: Transform.scale(
            scale: _loadingScaleAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                  Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.agriculture,
                    size: MediaQuery.of(context).size.width * 0.18,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                // App Name
                Text(
                  'AgriLink',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textWhite,
                    fontSize: (MediaQuery.of(context).size.width * 0.085).clamp(24, 34),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // Modern Loading Animation
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.16,
                  height: MediaQuery.of(context).size.width * 0.16,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.background.withValues(alpha: 0.8),
                    ),
                    strokeWidth: 4,
                    backgroundColor: AppColors.background.withValues(alpha: 0.2),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                // Loading Text
                Text(
                  'Loading...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.8),
                    fontSize: (MediaQuery.of(context).size.width * 0.038).clamp(12, 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainScreen() {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Logo
          Container(
            width: MediaQuery.of(context).size.width * 0.26,
            height: MediaQuery.of(context).size.width * 0.26,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Icon(
              Icons.agriculture,
              size: MediaQuery.of(context).size.width * 0.16,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          // App Name
          Text(
            'AgriLink',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textWhite,
              fontSize: (MediaQuery.of(context).size.width * 0.085).clamp(24, 34),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.012),
          // Tagline
          Text(
            'Connecting farmers with local markets for fair trade and sustainable growth',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite,
              fontSize: (MediaQuery.of(context).size.width * 0.03).clamp(11, 14),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // Role Toggle
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildRoleButton(
                    icon: Icons.shopping_bag,
                    label: 'Buyer',
                    isSelected: isBuyer,
                    onTap: () => setState(() => isBuyer = true),
                  ),
                ),
                Expanded(
                  child: _buildRoleButton(
                    icon: Icons.agriculture,
                    label: 'Farmer',
                    isSelected: !isBuyer,
                    onTap: () => setState(() => isBuyer = false),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          // Get Started Button
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.065,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(isBuyer: isBuyer),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'Get Started',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.018),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
              size: MediaQuery.of(context).size.width * 0.055,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
