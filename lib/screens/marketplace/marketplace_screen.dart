import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../widgets/product/product_card.dart';
import '../../services/firebase_firestore_service.dart';
import '../../models/product_model.dart';
import '../../utils/sample_data.dart';
import 'product_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedFilter = 'All Categories';
  String _selectedSort = 'Newest';
  bool _organicOnly = false;
  double _maxPrice = 1000000; // default very high
  final List<String> _preferredCategories = [];
  final _firestoreService = FirebaseFirestoreService();
  final GlobalKey _filterBtnKey = GlobalKey();
  final GlobalKey _sortBtnKey = GlobalKey();
  final List<String> _filterOptions = const [
    'All Categories',
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Herbs'
  ];
  final List<String> _sortOptions = const [
    'Newest',
    'Oldest',
    'Price: Low to High',
    'Price: High to Low'
  ];

  @override
  Widget build(BuildContext context) {
    // Live products from Firestore

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
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
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: const Icon(
                            Icons.storefront,
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
                                'Marketplace',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textWhite,
                                ),
                              ),
                              Text(
                                'Browse fresh produce from local farmers',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textWhite.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Filters
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.background,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterButton(
                          label: _selectedFilter,
                          icon: Icons.filter_list,
                          onTap: () {
                            _showAnchoredMenu(
                              key: _filterBtnKey,
                              options: _filterOptions,
                              selected: _selectedFilter,
                              onSelected: (val) => setState(() { _selectedFilter = val; }),
                            );
                          },
                          key: _filterBtnKey,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildFilterButton(
                          label: _selectedSort,
                          icon: Icons.sort,
                          onTap: () {
                            _showAnchoredMenu(
                              key: _sortBtnKey,
                              options: _sortOptions,
                              selected: _selectedSort,
                              onSelected: (val) => setState(() { _selectedSort = val; }),
                            );
                          },
                          key: _sortBtnKey,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
                // Live count + grid with static products appended
                StreamBuilder<List<Product>>(
                  stream: _firestoreService.productsStream(),
                  builder: (context, snapshot) {
                  final products = snapshot.data ?? const <Product>[];
                    final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

                  var liveFiltered = _organicOnly
                    ? products.where((p) => p.isOrganic).toList()
                    : products;

                  // Apply category filter (simple demo for now)
                  if (_selectedFilter != 'All Categories') {
                    liveFiltered = liveFiltered.where((p) => (p.category).toLowerCase().contains(_selectedFilter.toLowerCase())).toList();
                  }

                  // Apply buyer preferences: categories and max price
                  if (_preferredCategories.isNotEmpty) {
                    liveFiltered = liveFiltered.where((p) => _preferredCategories.contains(p.category)).toList();
                  }
                  liveFiltered = liveFiltered.where((p) => p.price <= _maxPrice).toList();

                  var sampleFiltered = _organicOnly
                    ? SampleData.products.where((p) => p.isOrganic).toList()
                    : SampleData.products;
                  if (_selectedFilter != 'All Categories') {
                    sampleFiltered = sampleFiltered.where((p) => (p.category).toLowerCase().contains(_selectedFilter.toLowerCase())).toList();
                  }
                  if (_preferredCategories.isNotEmpty) {
                    sampleFiltered = sampleFiltered.where((p) => _preferredCategories.contains(p.category)).toList();
                  }
                  sampleFiltered = sampleFiltered.where((p) => p.price <= _maxPrice).toList();

                  // Build pairs (product, isLive) and de-dupe by id preferring live
                  final Map<String, (Product, bool)> byId = {};
                  for (final p in sampleFiltered) {
                    byId[p.id] = (p, false);
                  }
                  for (final p in liveFiltered) {
                    byId[p.id] = (p, true); // overwrite sample if same id
                  }
                  var visiblePairs = byId.values.toList();

                  // Sort by createdAt or price based on selected sort
                  visiblePairs.sort((a, b) {
                    final (pa, isLiveA) = a;
                    final (pb, isLiveB) = b;
                    switch (_selectedSort) {
                      case 'Newest':
                        return pb.createdAt.compareTo(pa.createdAt);
                      case 'Oldest':
                        return pa.createdAt.compareTo(pb.createdAt);
                      case 'Price: Low to High':
                        return pa.price.compareTo(pb.price);
                      case 'Price: High to Low':
                        return pb.price.compareTo(pa.price);
                      default:
                        return pb.createdAt.compareTo(pa.createdAt);
                    }
                  });

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          color: AppColors.background,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isLoading ? 'Loading products…' : '${visiblePairs.length} products found',
                                style: AppTextStyles.bodySmall,
                              ),
                              GestureDetector(
                                onTap: () { setState(() { _organicOnly = !_organicOnly; }); },
                                child: Row(
                                  children: [
                                    Text(
                                      'Organic only',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: _organicOnly ? AppColors.primary : AppColors.textSecondary,
                                        fontWeight: _organicOnly ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(
                                      _organicOnly ? Icons.check_box : Icons.check_box_outline_blank,
                                      color: _organicOnly ? AppColors.primary : AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final containerWidth = constraints.maxWidth;
                            final crossAxis = containerWidth > 900 ? 3 : (containerWidth > 600 ? 2 : 2);
                            final aspect = containerWidth > 600 ? 0.8 : 0.75;
                            final totalSpacing = AppSpacing.md * (crossAxis - 1);
                            final horizontalPadding = AppSpacing.md * 2;
                            final tileWidth = (containerWidth - horizontalPadding - totalSpacing) / crossAxis;
                            final tileHeight = tileWidth / aspect;

                            if (isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

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
                              itemCount: visiblePairs.length,
                              itemBuilder: (context, index) {
                                final (product, isLive) = visiblePairs[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(product: product, orderable: isLive),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBuyerPreferences();
  }

  Future<void> _loadBuyerPreferences() async {
    final uid = supa.Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) { return; }
    try {
      final prefs = await _firestoreService.getBuyerPreferences(uid);
      if (prefs != null) {
        setState(() {
          _organicOnly = (prefs['organicOnly'] as bool?) ?? _organicOnly;
          _maxPrice = (prefs['maxPrice'] is num) ? (prefs['maxPrice'] as num).toDouble() : _maxPrice;
          final cats = (prefs['categories'] as List?)?.cast<String>() ?? _preferredCategories;
          _preferredCategories
            ..clear()
            ..addAll(cats);
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAnchoredMenu({
    required GlobalKey key,
    required List<String> options,
    required String selected,
    required void Function(String) onSelected,
  }) async {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) {
      return;
    }
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final rect = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: rect,
      items: options.map((opt) {
        final isSel = opt == selected;
        return PopupMenuItem<String>(
          value: opt,
          child: Row(
            children: [
              Expanded(child: Text(opt, style: AppTextStyles.bodyMedium)),
              if (isSel) const Icon(Icons.check, color: AppColors.primary),
            ],
          ),
        );
      }).toList(),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
    );
    if (result != null) onSelected(result);
  }

}
