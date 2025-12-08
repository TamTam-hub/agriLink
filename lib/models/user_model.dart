import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isBuyer;
  final DateTime createdAt;
  final String phone;
  final String location;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isBuyer,
    required this.createdAt,
    this.phone = '',
    this.location = '',
    this.lastLoginAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'isBuyer': isBuyer,
      'createdAt': Timestamp.fromDate(createdAt),
      'phone': phone,
      'location': location,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isBuyer: map['isBuyer'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    bool? isBuyer,
    DateTime? createdAt,
    String? phone,
    String? location,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      isBuyer: isBuyer ?? this.isBuyer,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  String get roleText => isBuyer ? 'Buyer' : 'Farmer';
}
