import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_user_screen.dart';
import '../login_screen.dart';
import '../../services/session_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0 = Products, 1 = Orders
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _activeTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color(0xFFFFF6F7), // Fondo rosa pastel muy claro y limpio
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFD1D6), // AppBar rosa pastel
      iconTheme: const IconThemeData(color: Color(0xFF6A1B29)), // Icono de menú hamburguesa oscuro/rosa
      title: const Text(
        'Tortas Yani 🍰', 
        style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
      ),
      elevation: 1,
      shadowColor: const Color(0xFFFFD1D6).withOpacity(0.5),
    ),
    drawer: Drawer(
      backgroundColor: const Color(0xFFFFF9FA), // Fondo del Drawer claro
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD1D6),
                  Color(0xFFFFE4E6),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cake_rounded, color: Color(0xFFF07070), size: 30),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tortas Yani',
                  style: TextStyle(color: Color(0xFF6A1B29), fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Panel de Administración',
                  style: TextStyle(color: Color(0xFF8A6B70), fontSize: 13),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Iconsax.category,
            title: 'Inicio / Métricas',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Iconsax.box,
            title: 'Gestión de Tortas',
            isActive: _activeTab == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _activeTab = 0;
                _tabController.index = 0;
              });
            },
          ),
          _buildDrawerItem(
            icon: Iconsax.receipt_2,
            title: 'Gestión de Pedidos',
            isActive: _activeTab == 1,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _activeTab = 1;
                _tabController.index = 1;
              });
            },
          ),
          _buildDrawerItem(
            icon: Iconsax.user_octagon,
            title: 'Gestión de Usuarios',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserScreen()));
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Divider(color: Color(0xFFFFE4E6)),
          ),
          _buildDrawerItem(
            icon: Iconsax.logout,
            title: 'Cerrar Sesión',
            isActive: false,
            onTap: () async {
              Navigator.pop(context);
              await SessionService.clearUser();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            activeBgColor: Colors.red.withOpacity(0.1),
            activeTextColor: Colors.redAccent,
            inactiveTextColor: Colors.redAccent,
          ),
        ],
      ),
    ),
    body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER SECCIÓN
            _buildHeader(context),
            
            // 2. RESUMEN ESTADÍSTICO DE MÈTRICAS
            _buildMetricsGrid(),
            
            const SizedBox(height: 20),

            // 3. SELECTOR DE PESTAÑAS PERSONALIZADO
            _buildCustomTabBar(),

            const SizedBox(height: 10),

            // 4. CONTENIDO DINÁMICO (VISTAS)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  AdminProductsScreen(),
                  AdminOrdersScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Yani Admin",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B29),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "👑",
                    style: TextStyle(fontSize: 24),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1500.ms, color: Colors.amber.withOpacity(0.5))
                      .shake(hz: 2, curve: Curves.easeInOut, duration: 2000.ms),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Panel de Administración",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A6B70),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Botón de salida elegante
          GestureDetector(
            onTap: () async {
              await SessionService.clearUser();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1D6).withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFB6C1).withOpacity(0.5)),
              ),
              child: const Icon(
                Iconsax.logout,
                color: Color(0xFFF07070),
                size: 22,
              ),
            ),
          ),
        ],
      ).animate().fade(duration: 400.ms).slideY(begin: -0.2),
    );
  }

  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: "Ventas Hoy",
              value: "S/ 1,240",
              subtitle: "+15% vs ayer",
              icon: Iconsax.money_3,
              iconColor: const Color(0xFFF07070),
              gradientColors: [
                const Color(0xFFFFF0F2),
                const Color(0xFFFFD6DC),
              ],
              borderColor: const Color(0xFFFFB6C1).withOpacity(0.4),
              titleColor: const Color(0xFF8A6B70),
              valueColor: const Color(0xFF6A1B29),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: "Pedidos Activos",
              value: "5 Nuevos",
              subtitle: "Pendientes",
              icon: Iconsax.box_add,
              iconColor: const Color(0xFFF07070),
              gradientColors: [
                const Color(0xFFFFF0F2),
                const Color(0xFFFFE4E1),
              ],
              borderColor: const Color(0xFFFFB6C1).withOpacity(0.4),
              titleColor: const Color(0xFF8A6B70),
              valueColor: const Color(0xFF6A1B29),
            ),
          ),
        ],
      ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    Color? borderColor,
    required Color titleColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? const Color(0xFFFFB6C1).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD1D6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: iconColor.withOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFC0CB)),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF07070),
                Color(0xFFFF69B4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF07070).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF8D4B53),
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _activeTab == 0 ? Iconsax.box5 : Iconsax.box,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text("Productos"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _activeTab == 1 ? Iconsax.receipt_21 : Iconsax.receipt_2,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text("Pedidos"),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    Color? activeBgColor,
    Color? activeTextColor,
    Color? inactiveTextColor,
  }) {
    final finalBgColor = isActive 
        ? (activeBgColor ?? const Color(0xFFFFD1D6).withOpacity(0.3)) 
        : Colors.transparent;
    final finalTextColor = isActive 
        ? (activeTextColor ?? const Color(0xFF6A1B29)) 
        : (inactiveTextColor ?? const Color(0xFF8A6B70));
    final finalIconColor = isActive 
        ? const Color(0xFFF07070) 
        : const Color(0xFF8A6B70);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: finalBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? const Color(0xFFFFD1D6).withOpacity(0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: finalIconColor, size: 22),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: finalTextColor,
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

