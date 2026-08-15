import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/admin_orders_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AppNotificationAdapter());
  
  // Open Hive boxes
  await Hive.openBox<AppNotification>('notifications');
  await Hive.openBox<String>('cart');
  await Hive.openBox<String>('favorites');
  await Hive.openBox<String>('user_orders');
  await Hive.openBox<String>('admin_orders');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrdersProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Tortas Yani',
        builder: (context, child) {
          return SessionLifecycleTracker(child: child!);
        },
        home: const SplashScreen(),
      ),
    );
  }
}

class SessionLifecycleTracker extends StatefulWidget {
  final Widget child;
  const SessionLifecycleTracker({super.key, required this.child});

  @override
  State<SessionLifecycleTracker> createState() => _SessionLifecycleTrackerState();
}

class _SessionLifecycleTrackerState extends State<SessionLifecycleTracker> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionService.updateLastActiveTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      SessionService.updateLastActiveTime();
    } else if (state == AppLifecycleState.resumed) {
      _checkSessionTimeout();
    }
  }

  Future<void> _checkSessionTimeout() async {
    final user = await SessionService.getUser();
    final token = user['token'] ?? '';
    if (token.isEmpty) return;

    final timedOut = await SessionService.shouldSessionTimeout();
    if (timedOut) {
      await SessionService.clearUser();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      SessionService.updateLastActiveTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
