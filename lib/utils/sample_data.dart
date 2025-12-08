import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class SampleData {
  // Sample User
  static UserModel sampleUser = UserModel(
    uid: '1',
    name: 'Jane Smith',
    email: 'jane@market.com',
    isBuyer: true,
    createdAt: DateTime.now(),
    phone: '+1 (555) 123-4567',
    location: 'Springfield Valley, CA',
  );

  // Sample Products
  static List<Product> products = [
    Product(
      id: '1',
      farmerId: 'farmer1',
      name: 'Fresh Organic Tomatoes',
      farmName: 'Green Valley Farm',
      location: 'Springfield Valley, CA',
      price: 3.99,
      priceUnit: '/kg',
      imageUrl: 'https://i0.wp.com/images-prod.healthline.com/hlcmsresource/images/AN_images/tomatoes-1296x728-feature.jpg?w=1155&h=1528',
      category: 'vegetables',
      isOrganic: true,
      description: 'Fresh organic tomatoes grown locally.',
      stockAmount: 150,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '2',
      farmerId: 'farmer2',
      name: 'Mixed Fresh Vegetables',
      farmName: 'Sunrise Organic Farm',
      location: 'Meadow Hills, CA',
      price: 5.49,
      priceUnit: '/kg',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
      category: 'vegetables',
      isOrganic: true,
      description: 'Assortment of fresh organic vegetables.',
      stockAmount: 200,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '3',
      farmerId: 'farmer3',
      name: 'Premium Fresh Fruits',
      farmName: 'Orchard Hills',
      location: 'Hillside County, CA',
      price: 6.99,
      priceUnit: '/kg',
      imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400',
      category: 'fruits',
      isOrganic: false,
      description: 'Premium selection of fresh fruits.',
      stockAmount: 120,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '4',
      farmerId: 'farmer4',
      name: 'Fresh Dairy Milk',
      farmName: 'Happy Cow Dairy',
      location: 'Green Pastures, CA',
      price: 4.50,
      priceUnit: '/liter',
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400',
      category: 'dairy',
      isOrganic: true,
      description: 'Fresh dairy milk from happy cows.',
      stockAmount: 80,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '5',
      farmerId: 'farmer5',
      name: 'Organic Wheat Grain',
      farmName: 'Golden Fields Farm',
      location: 'Prairie Valley, CA',
      price: 2.99,
      priceUnit: '/kg',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400',
      category: 'grains',
      isOrganic: true,
      description: 'Organic wheat grain harvested fresh.',
      stockAmount: 500,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '6',
      farmerId: 'farmer6',
      name: 'Farm Fresh Eggs',
      farmName: 'Free Range Poultry',
      location: 'Countryside, CA',
      price: 5.99,
      priceUnit: '/dozen',
      imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400',
      category: 'dairy',
      isOrganic: true,
      description: 'Farm fresh eggs from free range poultry.',
      stockAmount: 100,
      createdAt: DateTime.now(),
    ),
  ];

  // Sample Orders
  static List<Order> orders = [
    Order(
      id: '1',
      buyerId: 'buyer1',
      farmerId: 'farmer1',
      productId: '1',
      productName: 'Fresh Organic Tomatoes',
      farmName: 'Green Valley Farm',
      quantity: '5 kg',
      price: 19.95,
      imageUrl: 'https://i0.wp.com/images-prod.healthline.com/hlcmsresource/images/AN_images/tomatoes-1296x728-feature.jpg?w=1155&h=15280',
      status: OrderStatus.confirmed,
      orderDate: DateTime(2025, 10, 18),
    ),
    Order(
      id: '2',
      buyerId: 'buyer1',
      farmerId: 'farmer4',
      productId: '4',
      productName: 'Fresh Dairy Milk',
      farmName: 'Happy Cow Dairy',
      quantity: '3 liter',
      price: 13.50,
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400',
      status: OrderStatus.delivered,
      orderDate: DateTime(2025, 10, 15),
    ),
    Order(
      id: '3',
      buyerId: 'buyer1',
      farmerId: 'farmer3',
      productId: '3',
      productName: 'Premium Fresh Fruits',
      farmName: 'Orchard Hills',
      quantity: '2 kg',
      price: 13.98,
      imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400',
      status: OrderStatus.pending,
      orderDate: DateTime(2025, 10, 19),
    ),
  ];

  // Categories
  static List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
  ];

  // Statistics
  static Map<String, dynamic> statistics = {
    'farmers': 2450,
    'sales': '15K+',
    'organic': '85%',
  };
}
