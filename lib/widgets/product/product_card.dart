import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/currency.dart';
import '../../constants/spacing.dart';
import '../../models/product_model.dart';
import '../common/status_badge.dart';
import '../../utils/unit_utils.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // make the image height adaptive so the card can fit in small grid tiles
          final availableHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
              ? constraints.maxHeight
              : AppSpacing.productImageHeight + 140; // fallback
          final imageHeight = math.min(AppSpacing.productImageHeight, availableHeight * 0.55);

          return Container(
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
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
                // Product Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusMd),
                        topRight: Radius.circular(AppSpacing.radiusMd),
                      ),
                      child: Image.network(
                        product.imageUrl,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: imageHeight,
                            color: AppColors.backgroundGrey,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.textLight,
                            ),
                          );
                        },
                      ),
                    ),
                    if (product.isOrganic)
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: StatusBadge.organic(),
                      ),
                  ],
                ),
                // Product Details
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product Name
                          Text(
                            product.name,
                            style: AppTextStyles.h4.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Price
                          Text(
                            '${AppCurrency.format(product.price)} ${formatUnitWithSlash(product.priceUnit)}',
                            style: AppTextStyles.price.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Farm Name
                          Text(
                            product.farmName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  product.location,
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Category and Stock
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGrey,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  '${product.stockAmount} left',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
