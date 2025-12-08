import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/currency.dart';
import '../../constants/spacing.dart';
import '../../services/firebase_firestore_service.dart';
import '../../models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/common/status_badge.dart';
import '../../services/supabase_storage_service.dart';
import '../../utils/unit_utils.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final _firestoreService = FirebaseFirestoreService();

  @override
  Widget build(BuildContext context) {
    final farmerId = Supabase.instance.client.auth.currentUser?.id ?? '';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: StreamBuilder<List<Product>>(
                  stream: _firestoreService.productsByFarmerStream(farmerId),
                  builder: (context, snapshot) {
                    final count = (snapshot.data ?? const <Product>[]).length;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isTight = constraints.maxWidth < 360;
                        final spacing = isTight ? AppSpacing.sm : AppSpacing.md;
                        final children = [
                          _buildStatCard(
                            icon: Icons.inventory_2_outlined,
                            value: '$count',
                            label: 'Active Listings',
                            color: AppColors.primary,
                          ),
                          SizedBox(width: spacing, height: spacing),
                          _buildStatCard(
                            icon: Icons.trending_up,
                            value: '+0% ',
                            label: 'Growth',
                            color: AppColors.success,
                          ),
                        ];

                        if (isTight) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              children[0],
                              children[1],
                              children[2],
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: children[0]),
                            SizedBox(width: spacing),
                            Expanded(child: children[2]),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Products', style: AppTextStyles.h3),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: StreamBuilder<List<Product>>(
                  stream: _firestoreService.productsByFarmerStream(farmerId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final items = List<Product>.from(snapshot.data ?? const <Product>[])
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(child: Text('No products yet. Add your first product!')),
                      );
                    }
                    return Column(
                      children: items.map((product) => _buildProductCard(product)).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final imageSize = (screenWidth * 0.25).clamp(70.0, 110.0).toDouble();
        final isTight = screenWidth < 340;
        final horizontalGap = isTight ? AppSpacing.sm : AppSpacing.md;
        final buttonHeight = isTight ? 40.0 : 44.0;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: EdgeInsets.all(isTight ? AppSpacing.sm : AppSpacing.md),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Image.network(
                      product.imageUrl,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          color: AppColors.backgroundGrey,
                          child: const Icon(Icons.image_not_supported, size: 40),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: horizontalGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTight ? 14 : AppTextStyles.bodyLarge.fontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.isOrganic) StatusBadge.organic(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppCurrency.format(product.price)} ${formatUnitWithSlash(product.priceUnit)}',
                          style: AppTextStyles.price.copyWith(fontSize: isTight ? 14 : AppTextStyles.price.fontSize),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Text(
                                'Stock: ${product.stockAmount}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: isTight ? 11 : AppTextStyles.caption.fontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: horizontalGap / 2),
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: isTight ? 1 : 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundGrey,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: Text(
                                  product.category,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: isTight ? 11 : AppTextStyles.caption.fontSize,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTight ? AppSpacing.sm : AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditDialog(context, product),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(
                        'Edit',
                        style: TextStyle(fontSize: isTight ? 13 : 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        padding: EdgeInsets.symmetric(vertical: isTight ? AppSpacing.xs : AppSpacing.sm),
                        minimumSize: Size(0, buttonHeight),
                      ),
                    ),
                  ),
                  SizedBox(width: horizontalGap),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context, product),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: Text(
                        'Delete',
                        style: TextStyle(fontSize: isTight ? 13 : 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: EdgeInsets.symmetric(vertical: isTight ? AppSpacing.xs : AppSpacing.sm),
                        minimumSize: Size(0, buttonHeight),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 180;
        final padding = isTight ? AppSpacing.sm : AppSpacing.md;
        final iconSize = isTight ? AppSpacing.iconMd : AppSpacing.iconLg;
        return Container(
          padding: EdgeInsets.all(padding),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: iconSize),
              SizedBox(height: isTight ? AppSpacing.xs : AppSpacing.sm),
              Text(
                value,
                style: AppTextStyles.h3.copyWith(
                  color: color,
                  fontSize: isTight ? 18 : AppTextStyles.h3.fontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(fontSize: isTight ? 11 : AppTextStyles.caption.fontSize),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Product product) {
    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl = TextEditingController(text: product.price.toString());
    final stockCtrl = TextEditingController(text: product.stockAmount.toString());
    String selectedUnit = product.priceUnit.startsWith('/') ? product.priceUnit.substring(1) : product.priceUnit;
    final units = [
      'kg',
      'g',
      'lb',
      'piece',
      'dozen',
      'L',
    ];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedUnit,
                    decoration: const InputDecoration(labelText: 'Price Unit'),
                    items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedUnit = val);
                    },
                  ),
                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock Amount'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim());
                final stock = int.tryParse(stockCtrl.text.trim());
                if (name.isEmpty || price == null || price < 0 || stock == null || stock < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide valid values.')),
                  );
                  return;
                }
                try {
                  await _firestoreService.updateProduct(product.id, {
                    'name': name,
                    'price': price,
                    'priceUnit': selectedUnit,
                    'stockAmount': stock,
                  });
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product updated successfully.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Attempt to delete image from Supabase (no-op for non-Supabase URLs)
                final storage = SupabaseStorageService();
                if (product.imagePath.isNotEmpty) {
                  await storage.deleteProductImageByPath(product.imagePath);
                } else {
                  await storage.deleteProductImageByPublicUrl(product.imageUrl);
                }
                // Then delete Firestore document
                await _firestoreService.deleteProduct(product.id);
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
