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
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tortas Yani',
        home: SplashScreen(),
      ),
    );
  }
}
