import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/spacing.dart';
import '../../constants/currency.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/firebase_firestore_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import '../main_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool orderable;

  const ProductDetailScreen({super.key, required this.product, this.orderable = true});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isLoading = false;
  bool? _isBuyer; // null until role is resolved
  int? _currentStock; // track live stock after immediate decrement

  @override
  void initState() {
    super.initState();
    _loadRole();
    _currentStock = widget.product.stockAmount;
  }

  Future<void> _loadRole() async {
    final user = _authService.currentUser;
    if (user == null) return;
    try {
      final profile = await _firestoreService.getUserProfile(user.id);
      if (!mounted) return;
      setState(() {
        _isBuyer = profile?.isBuyer ?? true;
      });
    } catch (_) {
      // keep default
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    if (quantity > widget.product.stockAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity exceeds available stock')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty || _contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address and contact number')),
      );
      return;
    }

    // Contact number validation: must start with 09 and be exactly 11 digits
    final contact = _contactController.text.trim();
    final digitsOnly = contact.replaceAll(RegExp(r"[^0-9]"), "");
    final isValidPhone = digitsOnly.length == 11 && digitsOnly.startsWith('09');
    if (!isValidPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number must start with 09 and be 11 digits.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to place an order')),
        );
        return;
      }

      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final order = Order(
        id: orderId,
        buyerId: currentUser.id,
        farmerId: widget.product.farmerId,
        productId: widget.product.id,
        productName: widget.product.name,
        farmName: widget.product.farmName,
        quantity: '$quantity ${widget.product.priceUnit}',
        price: quantity * widget.product.price,
        imageUrl: widget.product.imageUrl,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        deliveryAddress: _addressController.text.trim(),
        contactNumber: digitsOnly,
        paymentMethod: 'cod',
      );

      await _firestoreService.addOrder(order);
      // Immediate stock decrement for buyer expectation
      await _firestoreService.decrementProductStock(widget.product.id, quantity);
      if (mounted) {
        setState(() {
          _currentStock = (_currentStock ?? widget.product.stockAmount) - quantity;
          if (_currentStock! < 0) _currentStock = 0;
        });
      }

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Order Placed'),
            content: const Text('Your order was placed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Navigate to Buyer MainScreen with Orders tab selected
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
                    (route) => route.isFirst,
                  );
                },
                child: const Text('View Orders'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          widget.product.name,
          style: AppTextStyles.h4.copyWith(color: AppColors.textWhite),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.backgroundGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppColors.textSecondary,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Product Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            widget.product.farmName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            widget.product.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppCurrency.format(widget.product.price),
                      style: AppTextStyles.price,
                    ),
                    Text(
                      widget.product.priceUnit.startsWith('/')
                          ? widget.product.priceUnit
                          : '/${widget.product.priceUnit}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (widget.product.isOrganic) ...[
                      const SizedBox(height: AppSpacing.sm),
                      StatusBadge.organic(),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Description
            Text(
              'Description',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.product.description,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stock Info
            Row(
              children: [
                const Icon(
                  Icons.inventory,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${_currentStock ?? widget.product.stockAmount} ${widget.product.priceUnit.startsWith('/') ? widget.product.priceUnit.substring(1) : widget.product.priceUnit} available',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quantity + Checkout (only for buyers and orderable/live products)
            if (_isBuyer == true && widget.orderable) ...[
              Text(
                'Quantity',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Delivery Address',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'House #, Street, Barangay, City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Contact Number',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '09XXXXXXXXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Place Order Button (buyers only and orderable)
            if (_isBuyer == true && widget.orderable)
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isLoading ? 'Placing Order...' : 'Place Order',
                  onPressed: _isLoading ? null : _placeOrder,
                ),
              )
            else if (_isBuyer == false)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Only buyers can place orders.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              )
            else if (_isBuyer == true && !widget.orderable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'This sample item is for preview only and cannot be ordered. Please select a live listing.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
