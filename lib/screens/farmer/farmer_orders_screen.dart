import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/currency.dart';
import '../../constants/spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../utils/sample_data.dart';
import '../../models/order_model.dart';
import '../../services/firebase_firestore_service.dart';


class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  String selectedTab = 'New';
  final _firestore = FirebaseFirestoreService();
  final Map<String, String> _buyerNameCache = {};
  bool _debugShowAll = false;
  bool _autoAccept = false;
  final Set<String> _autoAcceptedOrderIds = {};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final farmerId = supa.Supabase.instance.client.auth.currentUser?.id ?? '';

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
                      const Icon(
                        Icons.receipt_long,
                        color: AppColors.textWhite,
                        size: AppSpacing.iconLg,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Orders',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Manage incoming orders from buyers',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Tabs
            Container(
              height: isSmallScreen ? 46 : 50,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTab('New', Icons.fiber_new, compact: isSmallScreen),
                  _buildTab('In Progress', Icons.hourglass_empty, compact: isSmallScreen),
                  _buildTab('Completed', Icons.check_circle_outline, compact: isSmallScreen),
                  _buildTab('Cancelled', Icons.cancel_outlined, compact: isSmallScreen),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Orders List (live from Firestore)
            Expanded(
              child: StreamBuilder<List<Order>>(
                stream: _debugShowAll ? _firestore.ordersAllStream() : _firestore.ordersByFarmerStream(farmerId),
                builder: (context, snapshot) {
                  final live = snapshot.data ?? const <Order>[];
                  // Auto-accept pending orders if preference is enabled
                  if (_autoAccept) {
                    for (final o in live) {
                      if (o.status == OrderStatus.pending && !_autoAcceptedOrderIds.contains(o.id)) {
                        _autoAcceptedOrderIds.add(o.id);
                        // Fire-and-forget; mounted check not required here
                        _firestore.updateOrderStatus(o.id, OrderStatus.confirmed, buyerId: o.buyerId).catchError((_){});
                      }
                    }
                  }
                  // Merge live orders with sample orders (deduped by id)
                  final merged = <Order>[];
                  final seen = <String>{};
                  for (final o in live) { merged.add(o); seen.add(o.id); }
                  for (final o in SampleData.orders) { if (!seen.contains(o.id)) merged.add(o); }
                  final filtered = _filterByTab(merged)
                    ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No ${selectedTab.toLowerCase()} orders',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'FarmerId: $farmerId',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: () {
                              setState(() { _debugShowAll = !_debugShowAll; });
                            },
                            child: Text(_debugShowAll ? 'Hide All Orders' : 'Show All Orders (Debug)'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return _buildOrderCard(order);
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

  @override
  void initState() {
    super.initState();
    _loadFarmerAutoAccept();
  }

  Future<void> _loadFarmerAutoAccept() async {
    final uid = supa.Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final prefs = await _firestore.getFarmerPreferences(uid);
      if (prefs != null && mounted) {
        setState(() {
          _autoAccept = (prefs['autoAcceptOrders'] as bool?) ?? false;
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Widget _buildTab(String label, IconData icon, {bool compact = false}) {
    final isSelected = selectedTab == label;
    final iconSize = compact ? 18.0 : 20.0;
    final fontSize = compact ? 9.0 : 11.0;
    final gap = compact ? 1.0 : 2.0;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                size: iconSize,
              ),
              SizedBox(height: gap),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return SizedBox(
      width: double.infinity,
      child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          // Order Header
          SizedBox(
            width: double.infinity,
            child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusMd),
                topRight: Radius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: _buildBuyerName(order.buyerId),
                          ),
                        ],
                      ),
                      if (_debugShowAll) ...[
                        const SizedBox(height: 2),
                        Text(
                          'fid: ${order.farmerId}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    order.statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
          // Order Details
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.network(
                    order.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.backgroundGrey,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${order.quantity}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppCurrency.format(order.price),
                        style: AppTextStyles.price,
                      ),
                      const SizedBox(height: 4),
                      if (order.deliveryAddress.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.deliveryAddress,
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (order.contactNumber.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              order.contactNumber,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.orderDate),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          if (selectedTab == 'New')
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showRejectDialog(context, order);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAcceptDialog(context, order);
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Color(0xFFFFFFFF),
                      ),
                      label: const Text(
                        'Accept',
                        style: TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (selectedTab == 'In Progress') _buildProgressAction(order),
        ],
      ),
      ),
    );
  }

  List<Order> _filterByTab(List<Order> orders) {
    switch (selectedTab) {
      case 'New':
        return orders.where((o) => o.status == OrderStatus.pending).toList();
      case 'In Progress':
        return orders.where((o) =>
          o.status == OrderStatus.confirmed ||
          o.status == OrderStatus.active ||
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.ready ||
          o.status == OrderStatus.outForDelivery
        ).toList();
      case 'Completed':
        return orders.where((o) => o.status == OrderStatus.delivered).toList();
      case 'Cancelled':
        return orders.where((o) => o.status == OrderStatus.cancelled).toList();
      default:
        return orders;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return AppColors.confirmed;
      case OrderStatus.preparing:
        return AppColors.info;
      case OrderStatus.ready:
        return AppColors.info;
      case OrderStatus.outForDelivery:
        return AppColors.warning;
      case OrderStatus.delivered:
        return AppColors.delivered;
      case OrderStatus.pending:
        return AppColors.pending;
      case OrderStatus.active:
        return AppColors.info;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  void _showAcceptDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Text('Accept order for ${order.productName}?\nQuantity: ${order.quantity}\nShip to: ${order.deliveryAddress}\nContact: ${order.contactNumber}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.updateOrderStatus(order.id, OrderStatus.confirmed, buyerId: order.buyerId);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Order accepted successfully!')),
                  );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Failed to accept: $e')),
                  );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Accept', style: TextStyle(color: Color(0xFFFFFFFF))),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: Text('Are you sure you want to reject this order for ${order.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.updateOrderStatus(order.id, OrderStatus.cancelled);
                final qty = _parseOrderQuantity(order.quantity);
                if (qty > 0) {
                  await _firestore.incrementProductStock(order.productId, qty);
                }
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Order rejected and stock restored')),
                  );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Failed to reject: $e')),
                  );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject', style: TextStyle(color: Color(0xFFFFFFFF))),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerName(String buyerId) {
    final cached = _buyerNameCache[buyerId];
    if (cached != null) {
      return Text(
        cached,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      );
    }
    return FutureBuilder(
      future: _firestore.getUserData(buyerId),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? 'Buyer';
        if (snapshot.connectionState == ConnectionState.done) {
          _buyerNameCache[buyerId] = name;
        }
        return Text(
          name,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _buildProgressAction(Order order) {
    final action = _nextProgressAction(order.status);
    if (action == null) return const SizedBox.shrink();
    final (String label, OrderStatus next, IconData icon, Color color) = action;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await _firestore.updateOrderStatus(order.id, next);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status updated: $label')),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update: $e')),
              );
            }
          },
          icon: Icon(icon, color: const Color(0xFFFFFFFF)),
          label: Text(label, style: const TextStyle(color: Color(0xFFFFFFFF))),
          style: ElevatedButton.styleFrom(backgroundColor: color),
        ),
      ),
    );
  }

  (String, OrderStatus, IconData, Color)? _nextProgressAction(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
      case OrderStatus.active:
        return ('Mark Preparing', OrderStatus.preparing, Icons.local_dining, AppColors.info);
      case OrderStatus.preparing:
        return ('Mark Ready', OrderStatus.ready, Icons.restaurant, AppColors.info);
      case OrderStatus.ready:
        return ('Out for Delivery', OrderStatus.outForDelivery, Icons.local_shipping, AppColors.warning);
      case OrderStatus.outForDelivery:
        return ('Mark as Delivered', OrderStatus.delivered, Icons.check_circle, AppColors.primary);
      case OrderStatus.pending:
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  int _parseOrderQuantity(String quantity) {
    final parts = quantity.trim().split(' ');
    if (parts.isEmpty) return 0;
    return int.tryParse(parts.first) ?? 0;
  }
}
