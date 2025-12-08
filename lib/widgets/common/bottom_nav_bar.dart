import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/spacing.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isFarmer;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isFarmer = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final navHeight = AppSpacing.bottomNavHeight + bottomInset;

    return SafeArea(
      top: false,
      child: Container(
        height: navHeight,
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? AppSpacing.xs : 0),
          child: isFarmer ? _buildFarmerNavBar() : _buildBuyerNavBar(),
        ),
      ),
    );
  }

  Widget _buildBuyerNavBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          index: 0,
        ),
        _buildNavItem(
          icon: Icons.store_outlined,
          activeIcon: Icons.store,
          label: 'Market',
          index: 1,
        ),
        _buildNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'Orders',
          index: 2,
        ),
        _buildNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          index: 3,
        ),
      ],
    );
  }

  Widget _buildFarmerNavBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gapForCenter = 60.0;
        final itemCount = 4;
        final availableWidth = constraints.maxWidth - gapForCenter;
        final itemWidth = (availableWidth / itemCount).clamp(56.0, 90.0);
        final isNarrow = itemWidth < 68.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                SizedBox(
                  width: itemWidth,
                  child: Center(
                    child: _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                      forceCompact: isNarrow,
                    ),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: Center(
                    child: _buildNavItem(
                      icon: Icons.store_outlined,
                      activeIcon: Icons.store,
                      label: 'Market',
                      index: 1,
                      forceCompact: isNarrow,
                    ),
                  ),
                ),
                SizedBox(width: gapForCenter),
                SizedBox(
                  width: itemWidth,
                  child: Center(
                    child: _buildNavItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long,
                      label: 'Orders',
                      index: 3,
                      forceCompact: isNarrow,
                    ),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: Center(
                    child: _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                      index: 4,
                      forceCompact: isNarrow,
                    ),
                  ),
                ),
              ],
            ),
            // Center Add Button
            Positioned(
              left: constraints.maxWidth / 2 - 28,
              bottom: 12,
              child: _buildCenterAddButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.textWhite,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool forceCompact = false,
  }) {
    final isActive = currentIndex == index;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tightHeight = constraints.maxHeight < 60;
        final compact = forceCompact || tightHeight;
        final iconSize = compact ? AppSpacing.iconSm : AppSpacing.bottomNavIconSize;
        final fontSize = compact ? 11.0 : 12.0;
        final vPadding = compact ? 0.0 : 2.0;
        final gap = compact ? 1.0 : 2.0;

        return GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: vPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.iconActive : AppColors.iconInactive,
                  size: iconSize,
                ),
                SizedBox(height: gap),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.iconActive : AppColors.iconInactive,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
