import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../constants/currency.dart';
import '../../models/order_model.dart';
import '../../widgets/common/status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _timelineSteps();
    final activeIndex = _activeIndex(order.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      backgroundColor: AppColors.backgroundGrey,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.network(
                    order.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.backgroundGrey,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: AppTextStyles.h3.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('From: ${order.farmName}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${order.quantity} • ${AppCurrency.format(order.price)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          StatusBadge.fromOrderStatus(order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate), style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Timeline
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Timeline', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                const SizedBox(height: AppSpacing.md),
                ...List.generate(steps.length, (i) => _TimelineTile(
                  label: steps[i],
                  isDone: i <= activeIndex,
                  isLast: i == steps.length - 1,
                )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Delivery details
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Details', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                const SizedBox(height: AppSpacing.md),
                if (order.deliveryAddress.isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(order.deliveryAddress, style: AppTextStyles.bodyMedium)),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (order.contactNumber.isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.phone_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(order.contactNumber, style: AppTextStyles.bodyMedium),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Row(children: [
                  const Icon(Icons.payments_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Payment: ${order.paymentMethod.toUpperCase()}', style: AppTextStyles.bodyMedium),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _timelineSteps() => const [
    'Pending',
    'Accepted',
    'Preparing',
    'Ready',
    'Out for Delivery',
    'Delivered',
  ];

  int _activeIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
      case OrderStatus.active:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return 0; // show as not progressed
    }
  }
}

class _TimelineTile extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isLast;

  const _TimelineTile({
    required this.label,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: AppColors.textWhite),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
