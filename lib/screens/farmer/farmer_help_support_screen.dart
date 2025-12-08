import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';

class FarmerHelpSupportScreen extends StatelessWidget {
  const FarmerHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Help & Support',
          style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
        ),
      ),
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                        size: AppSpacing.iconLg,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How can we help you?',
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            'Find answers to common questions or get in touch with our support team.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Support Options
              _buildSupportItem(
                icon: Icons.question_answer_outlined,
                title: 'Frequently Asked Questions',
                subtitle: 'Find answers to common questions',
                onTap: () => _showFAQDialog(context),
              ),

              _buildSupportItem(
                icon: Icons.email_outlined,
                title: 'Contact Support',
                subtitle: 'Send us a message',
                onTap: () => _showContactDialog(context),
              ),

              _buildSupportItem(
                icon: Icons.phone_outlined,
                title: 'Call Support',
                subtitle: 'Speak with our team directly',
                onTap: () => _showCallDialog(context),
              ),

              _buildSupportItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () => _showTermsDialog(context),
              ),

              _buildSupportItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Learn how we protect your data',
                onTap: () => _showPrivacyDialog(context),
              ),

              _buildSupportItem(
                icon: Icons.info_outline,
                title: 'About AgriLink',
                subtitle: 'Learn more about our mission',
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Contact Information
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: AppTextStyles.h4.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildContactInfo(
                      icon: Icons.email,
                      title: 'Email',
                      value: 'christianalbos237@gmail.com',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildContactInfo(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: '09215970666',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildContactInfo(
                      icon: Icons.schedule,
                      title: 'Support Hours',
                      value: 'Mon-Fri 9AM-6PM EST',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.question_answer, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('FAQ', style: AppTextStyles.h4),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFAQItem(
                  question: 'How do I add products to my store?',
                  answer: 'Go to "My Products" in the main menu, then tap the "+" button to add new products with details, pricing, and photos.',
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFAQItem(
                  question: 'How do I manage my orders?',
                  answer: 'Check the "Orders" section to view incoming orders, update their status, and communicate with buyers.',
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFAQItem(
                  question: 'What are the fees for using AgriLink?',
                  answer: 'We charge a small commission on successful sales. Contact support for detailed pricing information.',
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFAQItem(
                  question: 'How do I get paid for my sales?',
                  answer: 'Payments are processed through our secure system. Funds are typically available within 3-5 business days.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.email, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Contact Support', style: AppTextStyles.h4),
            ],
          ),
          content: const Text(
            'Please send us an email at christianalbos237@gmail.com with details about your issue. We\'ll get back to you within 24 hours.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.phone, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Call Support', style: AppTextStyles.h4),
            ],
          ),
          content: const Text(
            'Call us at 09215970666 during business hours (Mon-Fri 9AM-6PM EST).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.description, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Terms of Service', style: AppTextStyles.h4),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'By using AgriLink, you agree to our terms of service. We are committed to providing a safe and fair marketplace for farmers and buyers. Please read our full terms at www.agrilink.com/terms.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.privacy_tip, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Privacy Policy', style: AppTextStyles.h4),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Your privacy is important to us. We collect minimal personal information necessary to provide our services. Please read our full privacy policy at www.agrilink.com/privacy.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('About AgriLink', style: AppTextStyles.h4),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'AgriLink connects local farmers directly with consumers, promoting fresh, local produce and fair trade practices. Our mission is to support sustainable agriculture and strengthen local food systems.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          answer,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
