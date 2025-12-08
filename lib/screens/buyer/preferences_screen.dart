import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/currency.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../widgets/common/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../services/firebase_firestore_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Preference states
  bool _organicOnly = false;
  double _maxPrice = 100.0;
  final List<String> _selectedCategories = [];
  bool _saving = false;
  bool _loading = true;
  final _firestore = FirebaseFirestoreService();

  final List<String> _availableCategories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Meat',
    'Grains',
    'Herbs & Spices',
    'Honey & Sweets',
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Preferences', style: AppTextStyles.h3.copyWith(color: AppColors.textWhite)),
        ),
        backgroundColor: AppColors.backgroundGrey,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Preferences',
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
              // Dietary Preferences
              _buildSectionHeader('Dietary Preferences'),
              _buildSwitchTile(
                title: 'Organic Only',
                subtitle: 'Show only organic products',
                value: _organicOnly,
                onChanged: (value) => setState(() => _organicOnly = value),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Price Range
              _buildSectionHeader('Price Range'),
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
                      'Maximum Price: ${AppCurrency.format(_maxPrice, decimals: 0)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Slider(
                      value: _maxPrice,
                      min: 10,
                      max: 500,
                      divisions: 49,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                      onChanged: (value) => setState(() => _maxPrice = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppCurrency.format(10, decimals: 0), style: AppTextStyles.caption),
                        Text(AppCurrency.format(500, decimals: 0), style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Preferred Categories
              _buildSectionHeader('Preferred Categories'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _availableCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.1),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Save Button
              CustomButton(
                text: _saving ? 'Saving...' : 'Save Preferences',
                onPressed: _saving ? null : _savePreferences,
                width: double.infinity,
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.h4.copyWith(fontSize: 18),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _loadPreferences() async {
    final uid = supa.Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final prefs = await _firestore.getBuyerPreferences(uid);
      if (prefs != null) {
        setState(() {
          _organicOnly = (prefs['organicOnly'] as bool?) ?? _organicOnly;
          _maxPrice = (prefs['maxPrice'] is num) ? (prefs['maxPrice'] as num).toDouble() : _maxPrice;
          final cats = (prefs['categories'] as List?)?.cast<String>() ?? _selectedCategories;
          _selectedCategories
            ..clear()
            ..addAll(cats);
        });
      }
    } catch (_) {
      // ignore load errors, keep defaults
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePreferences() async {
    final uid = supa.Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save preferences')),
      );
      return;
    }
    setState(() => _saving = true);
    final prefs = {
      'organicOnly': _organicOnly,
      'maxPrice': _maxPrice,
      'categories': _selectedCategories,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    try {
      await _firestore.saveBuyerPreferences(uid, prefs);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save preferences: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
