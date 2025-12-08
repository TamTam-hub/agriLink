import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../utils/sample_data.dart';
import '../../models/product_model.dart';
import '../../services/firebase_firestore_service.dart';
import '../../widgets/product/product_card.dart';
import '../marketplace/product_detail_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final FirebaseFirestoreService _firestore = FirebaseFirestoreService();
  String _selectedCategory = 'All';
  String _query = '';
  String _displayName = 'Buyer';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final supaUser = supa.Supabase.instance.client.auth.currentUser;
    if (supaUser == null) return;
    // Prefer Firestore profile name; fallback to Supabase metadata 'name'
    try {
      final profile = await _firestore.getUserProfile(supaUser.id);
      final name = profile?.name ?? (supaUser.userMetadata?['name'] as String?) ?? 'Buyer';
      if (!mounted) return;
      setState(() => _displayName = name);
    } catch (_) {
      final name = (supaUser.userMetadata?['name'] as String?) ?? 'Buyer';
      if (!mounted) return;
      setState(() => _displayName = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _displayName;
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Hello, $userName 👋',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.textWhite,
                                    fontSize: isSmall ? 22 : 26,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Find fresh products near you',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textWhite.withValues(alpha: 0.85),
                                  fontSize: isSmall ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: const Icon(Icons.agriculture, color: AppColors.textWhite),
                        )
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v.trim()),
                            decoration: InputDecoration(
                              hintText: 'Search for fruits, vegetables, etc.',
                              hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite.withValues(alpha: 0.9)),
                              filled: true,
                              fillColor: AppColors.background.withValues(alpha: 0.2),
                              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textWhite),
                              suffixIcon: (_query.isNotEmpty)
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: AppColors.textWhite),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() { _query = ''; });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textWhite),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final cat = SampleData.categories[index];
                      final selected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemCount: SampleData.categories.length,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Product grid (align like marketplace)
              StreamBuilder<List<Product>>(
                  stream: _firestore.productsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final live = snapshot.data ?? const <Product>[];
                    final pairs = <(Product,bool)>[]; // (product, isLive)
                    final seen = <String>{};
                    for (final p in live) { pairs.add((p, true)); seen.add(p.id); }
                    for (final p in SampleData.products) { if (!seen.contains(p.id)) pairs.add((p, false)); }

                    // Apply filters
                    final filteredPairs = pairs.where((pair) {
                      final product = pair.$1;
                      // ...existing code...
                      final matchesQuery = _query.isEmpty || product.name.toLowerCase().contains(_query.toLowerCase());
                      final cat = _selectedCategory.toLowerCase();
                      final matchesCat = _selectedCategory == 'All' || product.category.toLowerCase() == cat;
                      return matchesQuery && matchesCat;
                    }).toList();

                    if (filteredPairs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(
                          child: Text('No products match your filters', style: AppTextStyles.bodyMedium),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final containerWidth = constraints.maxWidth;
                        final crossAxis = containerWidth > 900 ? 3 : (containerWidth > 600 ? 2 : 2);
                        final aspect = containerWidth > 600 ? 0.8 : 0.75;
                        final totalSpacing = AppSpacing.md * (crossAxis - 1);
                        final horizontalPadding = AppSpacing.md * 2; // matches GridView left/right padding
                        final tileWidth = (containerWidth - horizontalPadding - totalSpacing) / crossAxis;
                        final tileHeight = tileWidth / aspect;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            left: AppSpacing.md,
                            right: AppSpacing.md,
                            top: AppSpacing.sm,
                            bottom: AppSpacing.bottomNavHeight + AppSpacing.md,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxis,
                            mainAxisExtent: tileHeight.clamp(220.0, 420.0),
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemCount: filteredPairs.length,
                          itemBuilder: (context, index) {
                            final (product, isLive) = filteredPairs[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: product, orderable: isLive),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
