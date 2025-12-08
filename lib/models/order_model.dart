import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending, // Pending farmer confirmation
  confirmed, // Accepted
  preparing,
  ready,
  outForDelivery,
  active, // legacy in-progress
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String buyerId;
  final String farmerId;
  final String productId;
  final String productName;
  final String farmName;
  final String quantity;
  final double price;
  final String imageUrl;
  final OrderStatus status;
  final DateTime orderDate;
  final String deliveryAddress;
  final String contactNumber;
  final String paymentMethod; // e.g., 'cod'

  Order({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.productId,
    required this.productName,
    required this.farmName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.orderDate,
    this.deliveryAddress = '',
    this.contactNumber = '',
    this.paymentMethod = 'cod',
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.active:
        return 'Active';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'];
    OrderStatus parsedStatus = OrderStatus.values.firstWhere(
      (e) => e.toString() == 'OrderStatus.$statusStr',
      orElse: () => OrderStatus.pending,
    );
    final rawDate = json['orderDate'];
    late DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    return Order(
      id: json['id'],
      buyerId: json['buyerId'] ?? '',
      farmerId: json['farmerId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'],
      farmName: json['farmName'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      status: parsedStatus,
      orderDate: parsedDate,
      deliveryAddress: json['deliveryAddress'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'cod',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'farmerId': farmerId,
      'productId': productId,
      'productName': productName,
      'farmName': farmName,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'status': status.toString().split('.').last,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryAddress': deliveryAddress,
      'contactNumber': contactNumber,
      'paymentMethod': paymentMethod,
    };
  }
}
