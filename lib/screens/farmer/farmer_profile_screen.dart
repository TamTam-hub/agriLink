import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../models/user_model.dart';
import '../../services/firebase_firestore_service.dart';
import '../auth/splash_screen.dart';
import '../buyer/edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'farmer_preferences_screen.dart';
import 'farmer_help_support_screen.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      _currentUser = await _firestoreService.getUserProfile(currentUser.id);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusXl),
                    bottomRight: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.agriculture,
                          color: AppColors.textWhite,
                          size: AppSpacing.iconLg,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Profile',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Manage your profile and account',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Farmer Profile Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Farmer Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user?.name ?? 'Farmer',
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      user?.roleText ?? 'Farmer',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Contact Info
                    if (user?.location.isNotEmpty ?? false)
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        user!.location,
                      ),
                    if (user?.location.isNotEmpty ?? false)
                      const SizedBox(height: AppSpacing.sm),
                    if (user?.phone.isNotEmpty ?? false)
                      _buildInfoRow(
                        Icons.phone_outlined,
                        user!.phone,
                      ),
                    if (user?.phone.isNotEmpty ?? false)
                      const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      Icons.email_outlined,
                      user?.email ?? '',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(currentUser: _currentUser),
                            ),
                          ).then((updatedUser) {
                            // Update the current user data immediately if returned
                            if (updatedUser != null && updatedUser is UserModel) {
                              setState(() {
                                _currentUser = updatedUser;
                              });
                            } else {
                              // Fallback: refresh user data after returning from edit screen
                              _loadCurrentUser();
                            }
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Farmer Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Farm Stats (dynamic, non-clickable)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<dynamic>>( // dynamic to avoid import churn here
                        stream: FirebaseFirestoreService()
                            .productsByFarmerStream(Supabase.instance.client.auth.currentUser?.id ?? '')
                            .map((list) => list),
                        builder: (context, snapshot) {
                          final count = (snapshot.data?.length ?? 0).toString();
                          return _buildStatCard(
                            count,
                            'Products',
                            Icons.inventory_2_outlined,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StreamBuilder<List<dynamic>>( // dynamic to avoid import churn here
                        stream: FirebaseFirestoreService()
                            .ordersByFarmerStream(Supabase.instance.client.auth.currentUser?.id ?? '')
                            .map((list) => list),
                        builder: (context, snapshot) {
                          final count = (snapshot.data?.length ?? 0).toString();
                          return _buildStatCard(
                            count,
                            'Orders',
                            Icons.shopping_bag_outlined,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Settings Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Settings',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    _buildSettingsItem(
                      Icons.notifications_outlined,
                      'Notifications',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerNotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      Icons.settings_outlined,
                      'Preferences',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerPreferencesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      Icons.help_outline,
                      'Help & Support',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerHelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Sign Out Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                      await fb_auth.FirebaseAuth.instance.signOut();
                    } catch (_) {}
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(skipLoading: true),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: AppSpacing.iconLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
