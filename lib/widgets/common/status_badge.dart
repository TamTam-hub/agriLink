import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  factory StatusBadge.organic() {
    return const StatusBadge(
      text: 'Organic',
      backgroundColor: AppColors.organic,
      textColor: AppColors.textWhite,
    );
  }

  factory StatusBadge.fromOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return const StatusBadge(
          text: 'Confirmed',
          backgroundColor: AppColors.confirmed,
          textColor: AppColors.textWhite,
        );
      case OrderStatus.preparing:
        return const StatusBadge(
          text: 'Preparing',
          backgroundColor: AppColors.info,
          textColor: AppColors.textWhite,
        );
      case OrderStatus.ready:
        return const StatusBadge(
          text: 'Ready',
          backgroundColor: AppColors.info,
          textColor: AppColors.textWhite,
        );
      case OrderStatus.outForDelivery:
        return const StatusBadge(
          text: 'Out for Delivery',
          backgroundColor: AppColors.primary,
          textColor: AppColors.textWhite,
        );
      case OrderStatus.delivered:
        return const StatusBadge(
          text: 'Delivered',
          backgroundColor: AppColors.delivered,
          textColor: AppColors.textWhite,
        );
      case OrderStatus.pending:
        return const StatusBadge(
          text: 'Pending',
          backgroundColor: AppColors.pending,
          textColor: AppColors.textWhite,
        );
      case OrderStatus.active:
        return const StatusBadge(
          text: 'Active',
          backgroundColor: AppColors.info,
          textColor: AppColors.textWhite,
        );
      case OrderStatus.cancelled:
        return const StatusBadge(
          text: 'Cancelled',
          backgroundColor: AppColors.error,
          textColor: AppColors.textWhite,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: textColor ?? AppColors.textWhite,
        ),
      ),
    );
  }
}
