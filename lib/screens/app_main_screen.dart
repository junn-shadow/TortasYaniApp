import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/constants.dart';
import 'app_home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = const [
      MyAppHomeScreen(),
      FavoritesScreen(),
      ChatScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.whiteColor,
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFFF07070),
        unselectedItemColor: const Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        onTap: (value) => setState(() => selectedIndex = value),
        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
            label: "Favoritos",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 2 ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded),
            label: "Yani AI",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 3 ? Iconsax.user5 : Iconsax.user),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
