import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'services/firebase_firestore_service.dart';
import 'models/order_model.dart' as order_model;
import 'constants/colors.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/farmer/farmer_main_screen.dart';
import 'firebase_options.dart';
import 'utils/responsive.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Remote push integrations removed; using local notifications only.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  // Initialize FirebaseFirestore instance
  FirebaseFirestore.instance;

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jsapqhfqmzqttxdgcyzc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzYXBxaGZxbXpxdHR4ZGdjeXpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyMzcyNTEsImV4cCI6MjA3OTgxMzI1MX0.XIdA4FDEozZ9d1GkLoT0sZvkn8l2yREZR_lYXkoHDZU',
  );

  // Allow running on web as well; previously restricted to mobile only

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AgriLinkApp());
}

class AgriLinkApp extends StatefulWidget {
  const AgriLinkApp({super.key});

  @override
  State<AgriLinkApp> createState() => _AgriLinkAppState();
}

class _AgriLinkAppState extends State<AgriLinkApp> {
  StreamSubscription<fb_auth.User?>? _fbAuthSub;
  StreamSubscription<List<order_model.Order>>? _ordersSub;
  final _orderStatusCache = <String, order_model.OrderStatus>{};
  final _firestoreService = FirebaseFirestoreService();

  @override
  void initState() {
    super.initState();
    // Local notifications service removed; no initialization needed
    _fbAuthSub = fb_auth.FirebaseAuth.instance.authStateChanges().listen((user) async {
      // No external push provider login
      _setupBuyerOrderStatusListener();
    });
    // No external push provider on cold start
    _setupBuyerOrderStatusListener();
  }

  @override
  void dispose() {
    _fbAuthSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }

  void _setupBuyerOrderStatusListener() {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _ordersSub?.cancel();
      return;
    }
    // Assume uid is buyer (or treat all orders where buyerId == uid)
    _ordersSub?.cancel();
    _ordersSub = _firestoreService.ordersByBuyerStream(uid).listen((orders) {
      for (final o in orders) {
        final prev = _orderStatusCache[o.id];
        if (prev == null) {
          // first snapshot, just cache
          _orderStatusCache[o.id] = o.status;
          continue;
        }
        if (prev != o.status) {
          _orderStatusCache[o.id] = o.status;
          // Local notification send removed; UI can reflect changes inline
        }
      }
      // Remove any orders no longer present (optional cleanup)
      final currentIds = orders.map((e) => e.id).toSet();
      _orderStatusCache.removeWhere((key, value) => !currentIds.contains(key));
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'AgriLink',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final widthFactor = (mq.size.width / 390).clamp(0.9, 1.05);
        final userScale = mq.textScaler.scale(1.0);
        final combinedScale = (userScale * widthFactor).clamp(0.9, 1.2);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(combinedScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyLarge: ThemeData.light().textTheme.bodyLarge?.copyWith(fontSize: Responsive.sp(16)),
          bodyMedium: ThemeData.light().textTheme.bodyMedium?.copyWith(fontSize: Responsive.sp(14)),
          bodySmall: ThemeData.light().textTheme.bodySmall?.copyWith(fontSize: Responsive.sp(12)),
          titleLarge: ThemeData.light().textTheme.titleLarge?.copyWith(fontSize: Responsive.sp(20)),
          titleMedium: ThemeData.light().textTheme.titleMedium?.copyWith(fontSize: Responsive.sp(18)),
          titleSmall: ThemeData.light().textTheme.titleSmall?.copyWith(fontSize: Responsive.sp(16)),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/buyer_home': (context) => const MainScreen(),
        '/farmer_home': (context) => const FarmerMainScreen(),
      },
    );
  }
}
