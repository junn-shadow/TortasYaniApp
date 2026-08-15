import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import '../services/session_service.dart';
import '../providers/orders_provider.dart';
import '../utils/constants.dart';

String getSmartAvatarUrl(String name, String customFoto) {
  if (customFoto.isNotEmpty && !customFoto.contains('torta_de_vainilla')) {
    return customFoto;
  }

  const maleAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=250&q=80'
  ];

  const femaleAvatars = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=250&q=80'
  ];

  final cleanName = name.trim().isEmpty ? 'Usuario' : name.trim();
  final firstName = cleanName.split(' ')[0].toLowerCase();

  int hash = 0;
  for (int i = 0; i < cleanName.length; i++) {
    hash = (hash << 5) - hash + cleanName.codeUnitAt(i);
  }
  final positiveHash = hash.abs();

  const femaleSuffixes = ['a', 'ía', 'eth', 'is', 'en', 'y'];
  const femaleExceptions = ['carmen', 'isabel', 'luz', 'mercedes', 'pilar', 'rosario', 'raquel', 'ruth', 'beatriz', 'inez', 'ines', 'monica', 'veronica', 'sonia'];
  const maleExceptions = ['luca', 'sasha', 'elias', 'nicolas', 'nicolás', 'matias', 'matías', 'tomas', 'tomás', 'josue', 'josué'];

  final isFemale = (femaleExceptions.contains(firstName) || femaleSuffixes.any((s) => firstName.endsWith(s))) && !maleExceptions.contains(firstName);

  final pool = isFemale ? femaleAvatars : maleAvatars;
  return pool[positiveHash % pool.length];
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nombreCompleto = '';
  String email = '';
  String telefono = '';
  String direccion = '';
  String fotoPerfil = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getUser();
    setState(() {
      nombreCompleto = user['nombreCompleto'] ?? '';
      email = user['email'] ?? '';
      telefono = user['telefono'] ?? '';
      direccion = user['direccion'] ?? '';
      fotoPerfil = user['fotoPerfil'] ?? '';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFF07070)),
        ),
      );
    }

    final ordersProvider = Provider.of<OrdersProvider>(context);
    final userOrders = ordersProvider.orders;

    final avatarUrl = getSmartAvatarUrl(nombreCompleto, fotoPerfil);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF0F5),
                    Color(0xFFFFFDF8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: avatarUrl.startsWith('http')
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )
                                  : Image.memory(
                                      base64Decode(avatarUrl),
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF07070),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        nombreCompleto.isEmpty ? "Usuario" : nombreCompleto,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // BOTÓN EDITAR PERFIL
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                          _loadUser();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF07070).withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Color(0xFFF07070), size: 16),
                              SizedBox(width: 6),
                              Text(
                                "Editar perfil",
                                style: TextStyle(
                                    color: Color(0xFFF07070), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle("Información personal"),

            _infoCard([
              _infoItem(Icons.person_outline, "Nombre",
                  nombreCompleto.isEmpty ? "Sin nombre" : nombreCompleto),
              _infoItem(Icons.email_outlined, "Correo",
                  email.isEmpty ? "Sin correo" : email),
              _infoItem(Icons.phone_outlined, "Teléfono",
                  telefono.isEmpty ? "Sin teléfono" : telefono),
              _infoItem(Icons.location_on_outlined, "Dirección",
                  direccion.isEmpty ? "Sin dirección" : direccion),
            ]),

            const SizedBox(height: 20),

            _sectionTitle("Información del negocio"),

            _infoCard([
              _infoItem(Icons.access_time_outlined, "Horario de atención",
                  "10:00 AM a 08:00 PM (Lunes a Domingo)"),
            ]),

            const SizedBox(height: 20),

            _sectionTitle("Historial de pedidos"),

            if (userOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Aún no tienes pedidos",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...userOrders.map((order) {
                // Get the first item name for quick display
                final items = order['items'] as List<dynamic>? ?? [];
                String firstItemName = items.isNotEmpty ? items.first['nombre'] : "Pedido especial";
                if (items.length > 1) {
                  firstItemName += " y más...";
                }
                
                return _pedidoCard(
                  firstItemName, 
                  "S/ ${order['total']?.toString() ?? '0'}", 
                  order['estado'] ?? "Pendiente", 
                  order['fechaStr'] ?? "Hoy",
                );
              }),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await SessionService.clearUser();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF07070),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF07070),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF07070), size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pedidoCard(
      String nombre, String precio, String estado, String fecha) {
    final bool entregado = estado == "Entregado";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF07070).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text("🎂", style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fecha,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                precio,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF07070),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: entregado
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    fontSize: 11,
                    color: entregado ? Colors.green.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
