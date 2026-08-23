import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/notifications_provider.dart';
import '../utils/constants.dart';
import 'map_screen.dart';
import 'app_main_screen.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {

  // VALORES SELECCIONADOS
  String _tipoEntrega = "delivery";
  String _ubicacion = "";
  double _deliveryCost = 0.0;
  DateTime? _fechaEntrega;
  TimeOfDay? _horaEntrega;

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF07070),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (fecha != null) setState(() => _fechaEntrega = fecha);
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF07070),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (hora != null) {
      if (hora.hour < 10 || hora.hour > 20 || (hora.hour == 20 && hora.minute > 0)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("El horario de atención es de 10:00 AM a 08:00 PM (10:00 - 20:00). Por favor selecciona una hora en ese rango."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => _horaEntrega = hora);
    }
  }

  Future<void> _seleccionarUbicacion() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
    if (resultado != null && resultado is Map<String, dynamic>) {
      setState(() {
        _ubicacion = resultado['url'] as String;
        _deliveryCost = resultado['cost'] as double;
      });
    }
  }

  Future<void> _enviarPedido() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);

    if (_fechaEntrega == null || _horaEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor selecciona fecha y hora de entrega"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_tipoEntrega == "delivery" && _ubicacion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor selecciona tu ubicación en el mapa"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final orderNumber = "TY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    const whatsappNumber = "51919576034";
    final fecha = "${_fechaEntrega!.day}/${_fechaEntrega!.month}/${_fechaEntrega!.year}";
    final hora = "${_horaEntrega!.hour.toString().padLeft(2, '0')}:${_horaEntrega!.minute.toString().padLeft(2, '0')}";
    final total = _tipoEntrega == "delivery" ? cart.totalPrice + _deliveryCost : cart.totalPrice;
    final adelanto = total * 0.5;
    final itemsList = cart.items.map((i) => i.toJson()).toList();

    final StringBuffer mensaje = StringBuffer();
    mensaje.writeln("*NUEVO PEDIDO - Tortas Yani*");
    mensaje.writeln("─────────────────────────");
    mensaje.writeln("*N° Pedido:* $orderNumber");
    mensaje.writeln();
    mensaje.writeln("*Productos y Detalles:*");
    for (final item in cart.items) {
      mensaje.writeln("• ${item.cantidad}x ${item.nombre} - S/ ${item.subtotal.toStringAsFixed(0)}");
      mensaje.writeln("  Talla: ${item.tamanio}  |  ${item.sabor}  |  ${item.pisos} pisos  |  ${item.porciones} porc.");
      if (item.colorDecoracion != "Sin color específico" && item.colorDecoracion.isNotEmpty) {
        mensaje.writeln("  Color: ${item.colorDecoracion}");
      }
      if (item.mensaje != "Sin mensaje" && item.mensaje.isNotEmpty) {
        mensaje.writeln("  Mensaje: \"${item.mensaje}\"");
      }
    }
    mensaje.writeln();
    mensaje.writeln("*Entrega:*");
    mensaje.writeln("Fecha: $fecha");
    mensaje.writeln("Hora: $hora");
    mensaje.writeln("Tipo: ${_tipoEntrega == "delivery" ? "Delivery" : "Recojo en local"}");
    if (_tipoEntrega == "delivery" && _ubicacion.isNotEmpty) {
      mensaje.writeln("Ubicación: $_ubicacion");
    }
    mensaje.writeln();
    mensaje.writeln("*Subtotal:* S/ ${cart.totalPrice.toStringAsFixed(2)}");
    if (_tipoEntrega == "delivery") {
      mensaje.writeln("*Delivery:* S/ ${_deliveryCost.toStringAsFixed(2)}");
    }
    mensaje.writeln("*TOTAL:* S/ ${total.toStringAsFixed(2)}");
    mensaje.writeln("*ADELANTO PAGADO (50%):* S/ ${adelanto.toStringAsFixed(2)}");
    mensaje.writeln("*SALDO PENDIENTE:* S/ ${adelanto.toStringAsFixed(2)}");
    mensaje.writeln();
    mensaje.writeln("Por favor confirmar disponibilidad y coordinar el pago. Gracias.");

    // Grabar orden en base de datos local
    final newOrder = {
      "id": orderNumber,
      "estado": "Pendiente",
      "estadoPago": "Pendiente",
      "total": total,
      "montoAdelanto": adelanto,
      "saldoPendiente": adelanto,
      "fechaStr": "$fecha - $hora",
      "tipoEntrega": _tipoEntrega,
      "items": itemsList,
      "chatId": DateTime.now().millisecondsSinceEpoch.toString(), // Historial/Chat ID Anti-negación
      "chatHistory": mensaje.toString(),
    };
    await ordersProvider.addOrder(newOrder);

    // Enviar notificación simulada
    notificationsProvider.addNotification(
      title: "Pedido $orderNumber enviado",
      body: "Tu pedido ha sido registrado y enviado por WhatsApp. ¡Gracias por elegirnos!",
      type: NotificationType.orderStatus,
    );

    cart.clearCart();

    final url = "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(mensaje.toString())}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderNumber: orderNumber)),
      (route) => false,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF07070), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final total = _tipoEntrega == "delivery" ? cart.totalPrice + _deliveryCost : cart.totalPrice;
    final adelanto = total * 0.5;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          "Detalles del pedido",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // RESUMEN DE PRODUCTOS
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Tus productos", Icons.shopping_cart_outlined),
                  ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.cantidad}x ${item.nombre}",
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "S/ ${item.subtotal.toStringAsFixed(0)}",
                          style: const TextStyle(color: Color(0xFFF07070), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            // FECHA Y HORA
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Fecha y hora de entrega", Icons.calendar_today),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _seleccionarFecha,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.date_range, color: Colors.black54, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _fechaEntrega == null
                                      ? "Seleccionar fecha"
                                      : "${_fechaEntrega!.day}/${_fechaEntrega!.month}/${_fechaEntrega!.year}",
                                  style: TextStyle(
                                      color: _fechaEntrega == null ? Colors.black38 : Colors.black87,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _seleccionarHora,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.black54, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _horaEntrega == null
                                      ? "Seleccionar hora"
                                      : _horaEntrega!.format(context),
                                  style: TextStyle(
                                      color: _horaEntrega == null ? Colors.black38 : Colors.black87,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TIPO DE ENTREGA
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Tipo de entrega", Icons.delivery_dining),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tipoEntrega = "delivery"),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoEntrega == "delivery" ? const Color(0xFFF07070).withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _tipoEntrega == "delivery" ? const Color(0xFFF07070) : Colors.black12,
                                width: _tipoEntrega == "delivery" ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.motorcycle, color: _tipoEntrega == "delivery" ? const Color(0xFFF07070) : Colors.black38),
                                const SizedBox(height: 4),
                                Text("Delivery", style: TextStyle(
                                    color: _tipoEntrega == "delivery" ? const Color(0xFFF07070) : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                                Text("+ S/ ${_deliveryCost > 0 ? _deliveryCost.toStringAsFixed(2) : '5.00'}", style: TextStyle(color: _tipoEntrega == "delivery" ? const Color(0xFFF07070).withOpacity(0.8) : Colors.black38, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tipoEntrega = "recojo"),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tipoEntrega == "recojo" ? const Color(0xFFF07070).withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _tipoEntrega == "recojo" ? const Color(0xFFF07070) : Colors.black12,
                                width: _tipoEntrega == "recojo" ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.store, color: _tipoEntrega == "recojo" ? const Color(0xFFF07070) : Colors.black38),
                                const SizedBox(height: 4),
                                Text("Recojo en local", style: TextStyle(
                                    color: _tipoEntrega == "recojo" ? const Color(0xFFF07070) : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                                Text("Gratis", style: TextStyle(color: _tipoEntrega == "recojo" ? const Color(0xFFF07070).withOpacity(0.8) : Colors.black38, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (_tipoEntrega == "delivery") ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _seleccionarUbicacion,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _ubicacion.isEmpty ? Colors.orange.withOpacity(0.5) : Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: _ubicacion.isEmpty ? Colors.orange : const Color(0xFFF07070), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _ubicacion.isEmpty ? "Seleccionar ubicación en el mapa" : _ubicacion,
                                style: TextStyle(
                                    color: _ubicacion.isEmpty ? Colors.orange : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: _ubicacion.isEmpty ? FontWeight.bold : FontWeight.normal),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_ubicacion.isNotEmpty)
                              const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // TOTAL Y BOTÓN FINAL
            _card(
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Subtotal:", style: TextStyle(color: Colors.black54, fontSize: 14)),
                      Text("S/ ${cart.totalPrice.toStringAsFixed(0)}", style: const TextStyle(color: Colors.black87, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Delivery:", style: TextStyle(color: Colors.black54, fontSize: 14)),
                      Text(_tipoEntrega == "delivery" ? "S/ ${_deliveryCost.toStringAsFixed(2)}" : "Gratis", style: const TextStyle(color: Colors.black87, fontSize: 14)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.black12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Adelanto a pagar (50%):", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        "S/ ${adelanto.toStringAsFixed(2)}",
                        style: const TextStyle(color: Color(0xFFF07070), fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SlideAction(
                    outerColor: const Color(0xFFF07070),
                    innerColor: Colors.white,
                    sliderButtonIcon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFF07070)),
                    text: "CONFIRMAR Y PAGAR",
                    textStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    onSubmit: () async {
                      await _enviarPedido();
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;

  const OrderSuccessScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF07070).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF25D366), size: 80),
              ),
              const SizedBox(height: 30),
              const Text(
                "¡Pedido enviado!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                "Tu pedido N° $orderNumber ha sido enviado correctamente por WhatsApp.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AppMainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF07070),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Volver al inicio", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
