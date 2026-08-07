import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../utils/catalog.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import '../providers/favorites_provider.dart';
import 'custom_cake_popup.dart';
import '../services/products_api_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/notifications_provider.dart';
import 'notifications_screen.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  int selectedCategory = 0;
  int _currentPromoIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<String> categories = [
    "Todos",
    "Tortas Generales",
    "De Matrimonio",
    "De Quince Años",
    "Exclusivas",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final apiProducts = await ProductsApiService.fetchProducts();
      if (apiProducts.isNotEmpty) {
        setState(() {
          TortasCatalog.tortas = apiProducts;
        });
      }
    } catch (e) {
      debugPrint("Error al cargar productos del catálogo 🚨: $e");
    }
  }

  List<Map<String, dynamic>> get tortasFiltradas {
    List<Map<String, dynamic>> result = TortasCatalog.tortas;
    if (selectedCategory != 0) {
      final categoryName = categories[selectedCategory];
      if (categoryName == "Tortas Generales") {
        result = result
            .where((t) => t["categoria"] == "Tortas" || t["categoria"] == "Cheesecake y Pyes")
            .toList();
      } else if (categoryName == "De Matrimonio") {
        result = result
            .where((t) => t["categoria"] == "Matrimoniales" || t["categoria"] == "Matrimonio")
            .toList();
      } else if (categoryName == "De Quince Años") {
        result = result
            .where((t) => t["categoria"] == "Quinceañeros" || t["categoria"] == "Quince Años")
            .toList();
      } else if (categoryName == "Exclusivas") {
        result = result
            .where((t) => t["categoria"] == "Tortas Especiales" || t["categoria"] == "Exclusivas")
            .toList();
      }
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      result = result
          .where((t) => (t["nombre"] as String).toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5), // Blush rosado
              Color(0xFFFFFDF8), // Crema
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchProducts,
            color: const Color(0xFFF07070),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                headerParts(),
                mySearchBar(),
                promoCard(),
                const SizedBox(height: 25),
                categoriesSection(),
                const SizedBox(height: 25),
                sectionTitle("Nuestras Tortas 🎂"),
                const SizedBox(height: 15),
                tortasFiltradas.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "🎂",
                                style: TextStyle(fontSize: 50),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "No se encontraron tortas para esta búsqueda",
                                style: TextStyle(
                                  color: Color(0xFF8D7A70),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: tortasFiltradas.length,
                        itemBuilder: (context, index) {
                          return tortaCard(tortasFiltradas[index])
                              .animate()
                              .fade(duration: 400.ms, delay: (50 * index).ms)
                              .slideY(begin: 0.1, duration: 400.ms, delay: (50 * index).ms);
                        },
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }

  Widget headerParts() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenida 💗",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8D7A70),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Tortas Yani",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF07070),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // CARRITO
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Stack(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFF07070),
                        child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                      ),
                      if (cart.totalItems > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${cart.totalItems}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFF07070),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            // NOTIFICACIONES
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
              child: Consumer<NotificationsProvider>(
                builder: (context, notificationsProvider, child) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF07070).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xFFFFF3B0),
                          child: Icon(Iconsax.notification_bing, color: Colors.amber, size: 26),
                        ),
                      ),
                      if (notificationsProvider.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF07070),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${notificationsProvider.unreadCount}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.whiteColor,
          hintText: "Buscar tortas...",
          prefixIcon: const Icon(Iconsax.search_normal, color: Color.fromARGB(255, 8, 25, 34)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget promoCard() {
    final List<Map<String, String>> slides = [
      {
        "image": "assets/images/cake1.png",
        "title": "¡Especial de la Casa! 🎂",
        "subtitle": "Tortas personalizadas con el mejor sabor",
      },
      {
        "image": "assets/images/cake2.png",
        "title": "Delicia de Fresa 🍓",
        "subtitle": "Frescura y elegancia en cada bocado",
      },
      {
        "image": "assets/images/cake3.png",
        "title": "Momentos Dorados ✨",
        "subtitle": "Tortas exclusivas para bodas y eventos",
      },
    ];

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: slides.length,
          options: CarouselOptions(
            height: 220,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPromoIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIdx) {
            final slide = slides[index];
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        slide["image"]!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF161F3D),
                            child: const Center(
                              child: Text(
                                "🍰 Yani",
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            slide["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            slide["subtitle"]!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              shadows: const [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (index == 0) {
                                    selectedCategory = categories.indexOf("Exclusivas");
                                  } else if (index == 1) {
                                    selectedCategory = categories.indexOf("Tortas Generales");
                                    _searchController.text = "Fresa";
                                    _searchQuery = "Fresa";
                                  } else if (index == 2) {
                                    selectedCategory = categories.indexOf("De Matrimonio");
                                  }
                                });
                              },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF07070),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Explorar",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward_rounded, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: slides.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPromoIndex == entry.key ? 18.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: _currentPromoIndex == entry.key
                    ? const Color(0xFFF07070)
                    : const Color(0xFF9E9E9E).withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget categoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categorías",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5A4A42),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final bool isSelected = selectedCategory == index;
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF07070) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF07070) : const Color(0xFFE5D5C5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFFF07070).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      else
                        BoxShadow(
                          color: const Color(0xFF5A4A42).withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : const Color(0xFF8D7A70),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ).animate().fade(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05);
            },
          ),
        ),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5A4A42),
      ),
    );
  }

  Widget tortaCard(Map<String, dynamic> torta) {
    return GestureDetector(
      onTap: () => mostrarPopupPersonalizacion(context, torta),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A4A42).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      torta["imagen"],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFFFF0F5),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.4));
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFFF0F5),
                        child: const Center(child: Text("🎂", style: TextStyle(fontSize: 40))),
                      ),
                    ),
                    if (torta["badge"] != "")
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF07070),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            torta["badge"],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favorites, child) {
                          final esFavorito = favorites.isFavorite(torta["nombre"]);
                          return GestureDetector(
                            onTap: () => favorites.toggleFavorite(torta),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                esFavorito ? Icons.favorite : Icons.favorite_border,
                                color: const Color(0xFFF07070),
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    torta["nombre"],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A4A42),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    torta["descripcion"],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF8D7A70),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                "${torta["rating"]}",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5A4A42),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "S/ ${torta["precio"].toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF07070),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => mostrarPopupPersonalizacion(context, torta),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF07070),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF07070).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
