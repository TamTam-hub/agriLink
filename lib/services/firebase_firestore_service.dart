import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart' as order_model;

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user data to Firestore
  Future<void> saveUserData(UserModel userModel) async {
    try {
      final start = DateTime.now();
      developer.log('[Firestore] saveUserData START uid=${userModel.uid}', name: 'FirebaseFirestoreService');
      await _firestore.collection('users').doc(userModel.uid).set(userModel.toMap());
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      developer.log('[Firestore] saveUserData SUCCESS uid=${userModel.uid} in ${elapsed}ms', name: 'FirebaseFirestoreService');
    } catch (e) {
      developer.log('Error saving user data for UID: ${userModel.uid} -> $e', name: 'FirebaseFirestoreService');
      throw 'Failed to save user data: $e';
    }
  }

  // Farmer preferences: load
  Future<Map<String, dynamic>?> getFarmerPreferences(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return (data['farmerPreferences'] as Map<String, dynamic>?);
    } catch (e) {
      throw 'Failed to load farmer preferences: $e';
    }
  }

  // Farmer preferences: save (merge)
  Future<void> saveFarmerPreferences(String uid, Map<String, dynamic> prefs) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'farmerPreferences': prefs,
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save farmer preferences: $e';
    }
  }

  // Buyer preferences: load
  Future<Map<String, dynamic>?> getBuyerPreferences(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return (data['buyerPreferences'] as Map<String, dynamic>?);
    } catch (e) {
      throw 'Failed to load buyer preferences: $e';
    }
  }

  // Buyer preferences: save (merge)
  Future<void> saveBuyerPreferences(String uid, Map<String, dynamic> prefs) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'buyerPreferences': prefs,
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save buyer preferences: $e';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
        user.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Update last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Failed to update last login: $e';
    }
  }

  // Create new user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to load user profile: $e';
    }
  }

  // Add product to Firestore
  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toJson());
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  // Update product fields (partial update)
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).set(data, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  // Get products by farmer
  Future<List<Product>> getProductsByFarmer(String farmerId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('farmerId', isEqualTo: farmerId)
          .get();
      return querySnapshot.docs.map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw 'Failed to load products: $e';
    }
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw 'Failed to load products: $e';
    }
  }

  // Realtime: stream all products (ordered by createdAt desc)
  Stream<List<Product>> productsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
          .map((d) => Product.fromJson(d.data()))
          .toList());
  }

  // Realtime: stream products by a farmer
  Stream<List<Product>> productsByFarmerStream(String farmerId) {
    return _firestore
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snap) => snap.docs
          .map((d) => Product.fromJson(d.data()))
          .toList());
  }

  // Add order to Firestore
  Future<void> addOrder(order_model.Order order) async {
    try {
      developer.log('[Firestore] ADD_ORDER id=${order.id} farmerId=${order.farmerId} buyerId=${order.buyerId} productId=${order.productId} status=${order.status}', name: 'FirebaseFirestoreService');
      await _firestore.collection('orders').doc(order.id).set(order.toJson());
      developer.log('[Firestore] ADD_ORDER_SUCCESS id=${order.id}', name: 'FirebaseFirestoreService');
    } catch (e) {
      developer.log('[Firestore] ADD_ORDER_FAIL id=${order.id} error=$e', name: 'FirebaseFirestoreService');
      throw 'Failed to add order: $e';
    }
  }

  

  // Get orders by buyer
  Future<List<order_model.Order>> getOrdersByBuyer(String buyerId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: buyerId)
          .get();
      final list = querySnapshot.docs
          .map((doc) => order_model.Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return list;
    } catch (e) {
      throw 'Failed to load orders: $e';
    }
  }

  // Get orders by farmer
  Future<List<order_model.Order>> getOrdersByFarmer(String farmerId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('farmerId', isEqualTo: farmerId)
          .get();
      final list = querySnapshot.docs
          .map((doc) => order_model.Order.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return list;
    } catch (e) {
      throw 'Failed to load orders: $e';
    }
  }

  // Realtime: stream orders by buyer
  Stream<List<order_model.Order>> ordersByBuyerStream(String buyerId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => order_model.Order.fromJson(d.data()))
              .toList();
          list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return list;
        });
  }

  // Realtime: stream orders by farmer
  Stream<List<order_model.Order>> ordersByFarmerStream(String farmerId) {
    return _firestore
        .collection('orders')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snap) {
          developer.log('[Firestore] FARMER_STREAM farmerId=$farmerId docs=${snap.docs.length}', name: 'FirebaseFirestoreService');
          final list = snap.docs
              .map((d) => order_model.Order.fromJson(d.data()))
              .toList();
          list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return list;
        });
  }

  // Realtime: stream ALL orders (debug)
  Stream<List<order_model.Order>> ordersAllStream() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snap) {
          developer.log('[Firestore] ALL_ORDERS docs=${snap.docs.length}', name: 'FirebaseFirestoreService');
          final list = snap.docs
              .map((d) => order_model.Order.fromJson(d.data()))
              .toList();
          list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return list;
        });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, order_model.OrderStatus status, {String? buyerId}) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
      });

      // If the order is being accepted and we have a buyerId, send a notification.
      if (status == order_model.OrderStatus.confirmed && buyerId != null) {
        await _sendOrderAcceptedNotification(buyerId);
      }
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  Future<void> _sendOrderAcceptedNotification(String buyerId) async {
    // Remote push notifications removed. UI will handle local notifications.
    developer.log('Push send skipped (removed). buyerId=$buyerId', name: 'FirebaseFirestoreService');
  }

  // Atomically decrement product stock
  Future<void> decrementProductStock(String productId, int qty) async {
    return _firestore.runTransaction((txn) async {
      final ref = _firestore.collection('products').doc(productId);
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final current = (data['stockAmount'] ?? 0) as int;
      final next = (current - qty).clamp(0, 1 << 31);
      txn.update(ref, {'stockAmount': next});
    });
  }

  // Atomically increment product stock (e.g., on reject/cancel)
  Future<void> incrementProductStock(String productId, int qty) async {
    return _firestore.runTransaction((txn) async {
      final ref = _firestore.collection('products').doc(productId);
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final current = (data['stockAmount'] ?? 0) as int;
      final next = (current + qty).clamp(0, 1 << 31);
      txn.update(ref, {'stockAmount': next});
    });
  }
}
