import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../widgets/order/order_card.dart';
import '../../models/order_model.dart';
import '../../services/firebase_firestore_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedTab = 'All';

  final List<String> _tabs = ['All', 'Pending', 'Active', 'Done'];
  final _firestore = FirebaseFirestoreService();

  @override
  Widget build(BuildContext context) {
    final buyerId = supa.Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
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
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
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
                              'My Orders',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textWhite,
                              ),
                            ),
                            Text(
                              'Track your purchases and deliveries',
                              style: AppTextStyles.bodyMedium.copyWith(
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
            // Tabs
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.background,
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.backgroundGrey
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          tab,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Orders List (live from Firestore)
            Expanded(
              child: StreamBuilder<List<Order>>(
                stream: _firestore.ordersByBuyerStream(buyerId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Failed to load orders. Please try again.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final orders = snapshot.data ?? const <Order>[];
                  final filtered = _filterByTab(orders);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No orders found',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Start shopping to see your orders here',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md).copyWith(
                      bottom: AppSpacing.bottomNavHeight + AppSpacing.md,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return OrderCard(
                        order: order,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(order: order),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Order> _filterByTab(List<Order> orders) {
    List<Order> list;
    switch (_selectedTab) {
      case 'All':
        list = List<Order>.from(orders);
        break;
      case 'Pending':
        list = orders.where((o) => o.status == OrderStatus.pending).toList();
        break;
      case 'Active':
        list = orders.where((o) =>
          o.status == OrderStatus.confirmed ||
          o.status == OrderStatus.active ||
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.ready ||
          o.status == OrderStatus.outForDelivery
        ).toList();
        break;
      case 'Done':
        list = orders.where((o) => o.status == OrderStatus.delivered).toList();
        break;
      default:
        list = List<Order>.from(orders);
        break;
    }
    // Sort newest → oldest by orderDate
    list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return list;
  }
}
