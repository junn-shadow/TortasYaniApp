import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/admin_orders_provider.dart';
import '../../services/nubefact_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  // Filtros de estado disponibles
  final List<String> _statusFilters = [
    "Pendiente",
    "En Horno",
    "En Camino",
    "Entregado"
  ];

  String _selectedFilter = "Pendiente";

  // Confirma la eliminación de un pedido
  void _confirmDeleteOrder(BuildContext context, AdminOrdersProvider provider, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Eliminar Pedido",
            style: TextStyle(color: Color(0xFF4A0E17), fontWeight: FontWeight.bold),
          ),
          content: Text(
            "¿Estás seguro de que deseas eliminar permanentemente el pedido ${order["id"]}?",
            style: const TextStyle(color: Color(0xFF8A6B70)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancelar", style: TextStyle(color: Color(0xFF8D4B53))),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteOrder(order["id"]);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Pedido ${order["id"]} eliminado."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                side: const BorderSide(color: Colors.redAccent, width: 1.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Avanza el estado de un pedido
  void _nextStatus(AdminOrdersProvider provider, Map<String, dynamic> order) {
    final currentStatus = order["estado"];
    String nextStatus = currentStatus;

    if (currentStatus == "Pendiente") {
      nextStatus = "En Horno";
    } else if (currentStatus == "En Horno") {
      nextStatus = "En Camino";
    } else if (currentStatus == "En Camino") {
      nextStatus = "Entregado";
    }

    if (nextStatus != currentStatus) {
      provider.updateOrderStatus(order["id"], nextStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pedido ${order["id"]} paso a '$nextStatus'"),
          backgroundColor: _getStatusColor(nextStatus),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Colores visuales para los badges
  Color _getStatusColor(String status) {
    switch (status) {
      case "Pendiente":
        return const Color(0xFFD97706); // Ámbar oscuro/dorado
      case "En Horno":
        return const Color(0xFFEA580C); // Naranja oscuro
      case "En Camino":
        return const Color(0xFF0284C7); // Azul cielo oscuro
      case "Entregado":
        return const Color(0xFF16A34A); // Verde oscuro
      default:
        return const Color(0xFF6B7280); // Gris medio
    }
  }
  @override
  Widget build(BuildContext context) {
    final adminOrdersProvider = Provider.of<AdminOrdersProvider>(context);
    final orders = adminOrdersProvider.orders;
    
    // Retorna el total de pedidos en un determinado estado
    int getCountByStatus(String status) {
      return orders.where((o) => o["estado"] == status).length;
    }

    final filteredOrders = orders.where((o) => o["estado"] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent, // El Dashboard tiene el color de fondo principal
      body: Column(
        children: [
          // 1. BARRA DE FILTROS (CHIPS RAPIDOS)
          _buildFilterBar(getCountByStatus),

          // 2. LISTA DE PEDIDOS FILTRADOS
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order, index, adminOrdersProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int Function(String) getCountByStatus) {
    return Container(
      height: 55,
      margin: const EdgeInsets.only(top: 15, bottom: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = _selectedFilter == filter;
          final count = getCountByStatus(filter);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Row(
                  children: [
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$count",
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.05);
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index, AdminOrdersProvider provider) {
    final List<dynamic> items = order["items"] ?? [];
    final estado = order["estado"] ?? "Pendiente";

    return Container(
      key: ValueKey(order["id"]),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del pedido (ID, Fecha y Estado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFF8FAFC),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        order["id"],
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order["fecha"],
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(estado).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getStatusColor(estado).withOpacity(0.3)),
                        ),
                        child: Text(
                          estado.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(estado),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () => _confirmDeleteOrder(context, provider, order),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cliente Info
                  Row(
                    children: [
                      const Icon(Iconsax.user, color: Color(0xFF1E293B), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order["cliente"],
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Iconsax.call, color: Color(0xFF64748B), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        order["telefono"],
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Dirección Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.location, color: Color(0xFF1E293B), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order["direccion"],
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 6),

                  // Lista de items comprados
                  const Text(
                    "Productos:",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item["cantidad"]}x  ${item["nombre"]}",
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "S/ ${(item["precio"] * item["cantidad"]).toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  // Fila de total y botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Cobrado",
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "S/ ${order["total"].toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInvoiceButton(order),
                          const SizedBox(width: 8),
                          _buildActionButton(order, provider),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(duration: 350.ms)
        .slideX(begin: 0.05, duration: 350.ms);
  }

  // Botón para Emitir Boleta con Nubefact
  Widget _buildInvoiceButton(Map<String, dynamic> order) {
    return IconButton(
      onPressed: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Generando comprobante..."),
            duration: Duration(seconds: 2),
          ),
        );

        // Mapear items al formato esperado
        List<Map<String, dynamic>> productos = (order["items"] as List).map((i) => {
          "id": i["id"] ?? "1",
          "nombre": i["nombre"] ?? "Torta",
          "cantidad": i["cantidad"] ?? 1,
          "precio_unitario": (i["precio"] as num).toDouble(),
        }).toList();

        final response = await NubefactService.generarBoleta(
          clienteDni: "00000000", // Valor por defecto si no hay DNI
          clienteNombre: order["cliente"] ?? "Cliente",
          clienteDireccion: order["direccion"] ?? "-",
          totalPedido: (order["total"] as num).toDouble(),
          productos: productos,
        );

        if (response != null && response['enlace_del_pdf'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Comprobante generado con éxito"),
              backgroundColor: Colors.green,
            ),
          );
          final url = Uri.parse(response['enlace_del_pdf']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al generar el comprobante. Revisa tus credenciales."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      icon: const Icon(Icons.receipt_long, color: Color(0xFF64748B)),
      tooltip: "Emitir Boleta",
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Genera el botón adecuado según el estado del pedido
  Widget _buildActionButton(Map<String, dynamic> order, AdminOrdersProvider provider) {
    final estado = order["estado"];

    if (estado == "Entregado") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
            SizedBox(width: 6),
            Text(
              "Completado",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    String buttonText = "";
    IconData buttonIcon = Icons.arrow_forward;
    Color buttonColor = Colors.grey;

    if (estado == "Pendiente") {
      buttonText = "Empezar a Preparar";
      buttonIcon = Iconsax.mask_1;
      buttonColor = const Color(0xFFD97706);
    } else if (estado == "En Horno") {
      buttonText = "Despachar / Enviar";
      buttonIcon = Iconsax.truck_fast;
      buttonColor = const Color(0xFF0284C7);
    } else if (estado == "En Camino") {
      buttonText = "Marcar como Entregado";
      buttonIcon = Icons.check_circle;
      buttonColor = const Color(0xFF16A34A);
    }

    return ElevatedButton(
      onPressed: () => _nextStatus(provider, order),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor.withOpacity(0.15),
        foregroundColor: buttonColor,
        side: BorderSide(color: buttonColor.withOpacity(0.4), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(buttonIcon, color: buttonColor, size: 16),
          const SizedBox(width: 8),
          Text(
            buttonText,
            style: TextStyle(
              color: buttonColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.box_remove, size: 48, color: Color(0xFF64748B)),
          const SizedBox(height: 15),
          Text(
            "Sin pedidos en estado '$_selectedFilter'",
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Los nuevos pedidos aparecerán aquí.",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ).animate().fade(duration: 400.ms).slideY(begin: 0.05),
    );
  }
}
