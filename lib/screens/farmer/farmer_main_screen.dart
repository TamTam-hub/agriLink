import 'package:flutter/material.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../marketplace/marketplace_screen.dart';
import 'farmer_home_screen.dart';
import 'add_product_screen.dart';
import 'farmer_orders_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerNavController extends InheritedWidget {
  final int currentIndex;
  final void Function(int) setIndex;

  const FarmerNavController({
    super.key,
    required this.currentIndex,
    required this.setIndex,
    required super.child,
  });

  static FarmerNavController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FarmerNavController>();
  }

  @override
  bool updateShouldNotify(FarmerNavController oldWidget) =>
      oldWidget.currentIndex != currentIndex;
}

class FarmerMainScreen extends StatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FarmerHomeScreen(),
    MarketplaceScreen(), // Market screen
    AddProductScreen(), // Add Product screen
    FarmerOrdersScreen(),
    FarmerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return FarmerNavController(
      currentIndex: _currentIndex,
      setIndex: (index) => setState(() { _currentIndex = index; }),
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          isFarmer: true,
        ),
      ),
    );
  }
}
