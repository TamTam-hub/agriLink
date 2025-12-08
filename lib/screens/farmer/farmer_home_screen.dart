import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/currency.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
// import '../../utils/sample_data.dart';
import '../../services/firebase_firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../services/supabase_storage_service.dart';
import '../../utils/unit_utils.dart';
import 'farmer_main_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  UserModel? _userProfile;
  bool _isLoading = true;
  final GlobalKey _myProductsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Use Supabase Auth UID for Firestore documents
      final supabaseUser = supa.Supabase.instance.client.auth.currentUser;
      final supabaseUid = supabaseUser?.id;
      if (supabaseUid != null) {
        final firestoreService = FirebaseFirestoreService();
        final userProfile = await firestoreService.getUserProfile(supabaseUid);
        setState(() {
          _userProfile = userProfile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isLargeScreen = size.width > 600;

    // Responsive padding and sizing
    final horizontalPadding = size.width * 0.05; // 5% of screen width
    final verticalPadding = size.height * 0.02; // 2% of screen height
    final headerPadding = size.width * 0.06; // 6% for header
    final iconSize = isSmallScreen ? 20.0 : AppSpacing.iconLg;
    final imageSize = isSmallScreen ? 50.0 : (isLargeScreen ? 80.0 : 60.0);

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
              // Header
              Container(
                padding: EdgeInsets.all(headerPadding),
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
                                  _isLoading
                                      ? 'Loading...'
                                      : 'Hello, ${_userProfile?.name ?? 'Farmer'} 👋',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.textWhite,
                                    fontSize: isSmallScreen ? 22 : 26,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Manage your products and sales',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textWhite.withValues(alpha: 0.85),
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(size.width * 0.02),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Icon(
                            Icons.agriculture,
                            color: AppColors.textWhite,
                            size: iconSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Sales Statistics
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Overview',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: isSmallScreen ? 18 : null,
                      ),
                    ),
                    SizedBox(height: verticalPadding),
                    StreamBuilder<List<Order>>(
                      stream: FirebaseFirestoreService().ordersByFarmerStream(
                        supa.Supabase.instance.client.auth.currentUser?.id ?? '',
                      ),
                      builder: (context, snapshot) {
                        final orders = snapshot.data ?? const <Order>[];
                        final now = DateTime.now();
                        bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
                        bool isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

                        final todaysSales = orders
                            .where((o) => o.status == OrderStatus.delivered && isSameDay(o.orderDate, now))
                            .fold<double>(0.0, (sum, o) => sum + o.price);
                        final newOrders = orders.where((o) => o.status == OrderStatus.pending).length;
                        final monthSales = orders
                            .where((o) => o.status == OrderStatus.delivered && isSameMonth(o.orderDate, now))
                            .fold<double>(0.0, (sum, o) => sum + o.price);

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.payments,
                                    value: AppCurrency.format(todaysSales, decimals: 0),
                                    label: 'Today\'s Sales',
                                    color: AppColors.success,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                ),
                                SizedBox(width: horizontalPadding * 0.5),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.shopping_bag,
                                    value: '$newOrders',
                                    label: 'New Orders',
                                    color: AppColors.info,
                                    isSmallScreen: isSmallScreen,
                                    onTap: () {
                                      final ctrl = FarmerNavController.of(context);
                                      ctrl?.setIndex(3); // Orders tab
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: verticalPadding),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.trending_up,
                                    value: AppCurrency.format(monthSales, decimals: 0),
                                    label: 'This Month',
                                    color: AppColors.pink,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                ),
                                SizedBox(width: horizontalPadding * 0.5),
                                Expanded(
                                  child: StreamBuilder<List<Product>>(
                                    stream: FirebaseFirestoreService().productsByFarmerStream(
                                      supa.Supabase.instance.client.auth.currentUser?.id ?? '',
                                    ),
                                    builder: (context, snap) {
                                      final count = (snap.data ?? const <Product>[]).length;
                                      return _buildStatCard(
                                        icon: Icons.inventory_2,
                                        value: '$count',
                                        label: 'Products',
                                        color: AppColors.warning,
                                        isSmallScreen: isSmallScreen,
                                        onTap: () {
                                          final target = _myProductsKey.currentContext;
                                          if (target != null) {
                                            Scrollable.ensureVisible(
                                              target,
                                              duration: const Duration(milliseconds: 400),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              // Recent Orders
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Orders',
                          style: AppTextStyles.h3.copyWith(
                            fontSize: isSmallScreen ? 18 : null,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final ctrl = FarmerNavController.of(context);
                            if (ctrl != null) {
                              ctrl.setIndex(3); // Switch to Orders tab
                            }
                          },
                          child: Text(
                            'View All',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontSize: isSmallScreen ? 12 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalPadding),
                    StreamBuilder<List<Order>>(
                      stream: FirebaseFirestoreService().ordersByFarmerStream(
                        supa.Supabase.instance.client.auth.currentUser?.id ?? '',
                      ),
                      builder: (context, snapshot) {
                        final orders = List<Order>.from(snapshot.data ?? const <Order>[]);
                        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
                        final recent = orders.take(3).toList();
                        if (recent.isEmpty) {
                          return Text(
                            'No recent orders',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          );
                        }
                        return Column(
                          children: recent.map((order) {
                            return Container(
                              margin: EdgeInsets.only(bottom: verticalPadding),
                              padding: EdgeInsets.all(isSmallScreen ? AppSpacing.sm : AppSpacing.md),
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
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    child: Image.network(
                                      order.imageUrl,
                                      width: imageSize,
                                      height: imageSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: imageSize,
                                          height: imageSize,
                                          color: AppColors.backgroundGrey,
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.productName,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isSmallScreen ? 14 : null,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${order.quantity} • ${AppCurrency.format(order.price)}',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            fontSize: isSmallScreen ? 12 : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? AppSpacing.xs : AppSpacing.sm,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    ),
                                    child: Text(
                                      order.statusText,
                                      style: AppTextStyles.caption.copyWith(
                                        color: _getStatusColor(order.status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: isSmallScreen ? 10 : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // My Products Section
              Padding(
                key: _myProductsKey,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Products',
                          style: AppTextStyles.h3.copyWith(
                            fontSize: isSmallScreen ? 18 : null,
                          ),
                        ),
                        StreamBuilder<List<Product>>(
                          stream: FirebaseFirestoreService().productsByFarmerStream(
                            supa.Supabase.instance.client.auth.currentUser?.id ?? '',
                          ),
                          builder: (context, snapshot) {
                            final count = (snapshot.data ?? const <Product>[]).length;
                            return Text(
                              '$count items',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: isSmallScreen ? 12 : null,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: verticalPadding),
                    StreamBuilder<List<Product>>(
                      stream: FirebaseFirestoreService().productsByFarmerStream(
                        supa.Supabase.instance.client.auth.currentUser?.id ?? '',
                      ),
                      builder: (context, snapshot) {
                        final list = List<Product>.from(snapshot.data ?? const <Product>[]);
                        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                        final items = list.take(3).toList();
                        if (items.isEmpty) {
                          return Text(
                            'No products yet',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          );
                        }
                        final farmerId = supa.Supabase.instance.client.auth.currentUser?.id ?? '';
                        return StreamBuilder<List<Order>>(
                          stream: FirebaseFirestoreService().ordersByFarmerStream(farmerId),
                          builder: (context, osnap) {
                            final orders = osnap.data ?? const <Order>[];
                            final Map<String, double> salesRevenueByProduct = {};
                            for (final o in orders) {
                              if (o.status == OrderStatus.delivered) {
                                salesRevenueByProduct[o.productId] =
                                    (salesRevenueByProduct[o.productId] ?? 0.0) + o.price;
                              }
                            }
                            return Column(
                              children: items.map((product) {
                                final revenue = salesRevenueByProduct[product.id] ?? 0.0;
                                return Container(
                        margin: EdgeInsets.only(bottom: verticalPadding),
                        padding: EdgeInsets.all(isSmallScreen ? AppSpacing.sm : AppSpacing.md),
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
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: isSmallScreen ? 60 : 80,
                                    height: isSmallScreen ? 60 : 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: isSmallScreen ? 60 : 80,
                                        height: isSmallScreen ? 60 : 80,
                                        color: AppColors.backgroundGrey,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: isSmallScreen ? 20 : 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isSmallScreen ? 14 : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: isSmallScreen ? 2 : 4),
                                      Text(
                                        '${AppCurrency.format(product.price)} ${formatUnitWithSlash(product.priceUnit)}',
                                        style: AppTextStyles.price.copyWith(
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 2 : 4),
                                      Wrap(
                                        spacing: isSmallScreen ? AppSpacing.xs : AppSpacing.sm,
                                        runSpacing: 2,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            'Stock: ${product.stockAmount}',
                                            style: AppTextStyles.caption.copyWith(
                                              fontSize: isSmallScreen ? 10 : null,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (revenue > 0)
                                            Text(
                                              'Sales: ${AppCurrency.format(revenue, decimals: 0)}',
                                              style: AppTextStyles.caption.copyWith(
                                                fontSize: isSmallScreen ? 10 : null,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isSmallScreen ? 2.0 : AppSpacing.xs,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundGrey,
                                              borderRadius: BorderRadius.circular(
                                                AppSpacing.radiusSm,
                                              ),
                                            ),
                                            child: Text(
                                              product.category,
                                              style: AppTextStyles.caption.copyWith(
                                                fontSize: isSmallScreen ? 8 : 10,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showEditProductDialog(context, product),
                                    icon: Icon(Icons.edit_outlined, size: isSmallScreen ? 14 : 16),
                                    label: Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : null,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: const BorderSide(color: AppColors.border),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 2.0 : AppSpacing.xs,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showDeleteProductDialog(context, product),
                                    icon: Icon(Icons.delete_outline, size: isSmallScreen ? 14 : 16),
                                    label: Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : null,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 2.0 : AppSpacing.xs,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isSmallScreen,
    VoidCallback? onTap,
  }) {
    final iconSize = isSmallScreen ? 24.0 : AppSpacing.iconLg;
    final padding = isSmallScreen ? AppSpacing.sm : AppSpacing.md;
    final titleFontSize = isSmallScreen ? 16.0 : null;
    final labelFontSize = isSmallScreen ? 12.0 : null;

    final card = Container(
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
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(height: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontSize: titleFontSize,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: labelFontSize,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: card,
    );
  }

  

  Color _getStatusColor(Object? status) {
    switch (status.toString()) {
      case 'OrderStatus.confirmed':
        return AppColors.confirmed;
      case 'OrderStatus.delivered':
        return AppColors.delivered;
      case 'OrderStatus.pending':
        return AppColors.pending;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final firestore = FirebaseFirestoreService();
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
                  onChanged: (val) { if (val != null) setState(() => selectedUnit = val); },
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
                  await firestore.updateProduct(product.id, {
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
              child: const Text('Save', style: TextStyle(color: AppColors.textWhite)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteProductDialog(BuildContext context, Product product) {
    final firestore = FirebaseFirestoreService();
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
                // Attempt to delete image from Supabase (no-op if not from our bucket)
                final storage = SupabaseStorageService();
                if (product.imagePath.isNotEmpty) {
                  await storage.deleteProductImageByPath(product.imagePath);
                } else {
                  await storage.deleteProductImageByPublicUrl(product.imageUrl);
                }
                await firestore.deleteProduct(product.id);
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
            child: const Text('Delete', style: TextStyle(color: AppColors.textWhite),),
          ),
        ],
      ),
    );
  }
}
