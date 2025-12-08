import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String farmerId;
  final String name;
  final String farmName;
  final String location;
  final double price;
  final String priceUnit;
  final String imageUrl;
  final String imagePath; // Supabase storage object path (optional)
  final String category;
  final bool isOrganic;
  final String description;
  final int stockAmount;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.farmName,
    required this.location,
    required this.price,
    required this.priceUnit,
    required this.imageUrl,
    this.imagePath = '',
    required this.category,
    this.isOrganic = false,
    this.description = '',
    required this.stockAmount,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      farmerId: json['farmerId'],
      name: json['name'],
      farmName: json['farmName'],
      location: json['location'],
      price: json['price'].toDouble(),
      priceUnit: json['priceUnit'],
      imageUrl: json['imageUrl'],
      imagePath: json['imagePath'] ?? '',
      category: json['category'],
      isOrganic: json['isOrganic'] ?? false,
      description: json['description'] ?? '',
      stockAmount: json['stockAmount'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'farmName': farmName,
      'location': location,
      'price': price,
      'priceUnit': priceUnit,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'category': category,
      'isOrganic': isOrganic,
      'description': description,
      'stockAmount': stockAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
