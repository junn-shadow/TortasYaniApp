import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../services/mercado_pago_service.dart';
import 'app_main_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String tipoEntrega;
  final String ubicacion;

  const PaymentScreen({
    super.key,
    required this.tipoEntrega,
    required this.ubicacion,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final total = widget.tipoEntrega == "delivery"
        ? cart.totalPrice + 5
        : cart.totalPrice;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 17, 41),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1035),
        title: const Text(
          "Confirmar pedido 🎂",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // RESUMEN DEL PEDIDO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2340),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total a pagar", style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            widget.tipoEntrega == "delivery"
                                ? "Incluye delivery S/ 5"
                                : "Recojo en local - Sin delivery",
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                      Text(
                        "S/ ${total.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF07070),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.tipoEntrega == "delivery"
                          ? const Color(0xFFF07070).withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.tipoEntrega == "delivery" ? Icons.delivery_dining : Icons.store,
                          color: widget.tipoEntrega == "delivery" ? const Color(0xFFF07070) : Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.tipoEntrega == "delivery" ? "Delivery a domicilio" : "Recojo en local",
                          style: TextStyle(
                            color: widget.tipoEntrega == "delivery" ? const Color(0xFFF07070) : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // INFO WHATSAPP
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFF07070), size: 30),
                  SizedBox(height: 12),
                  Text(
                    "Coordinación de pago",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Para finalizar tu pedido, enviaremos los detalles a nuestro WhatsApp. Una vez recibido, coordinaremos el método de pago y la entrega directamente contigo.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // MERCADO PAGO BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _processMercadoPago(context, cart),
                icon: const Icon(Icons.payment, color: Colors.white, size: 22),
                label: const Text(
                  "Pagar con Mercado Pago (Tarjeta / Yape)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009EE3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _processPay(context, cart),
                icon: _isProcessing 
                    ? const SizedBox() 
                    : const Icon(Icons.chat, color: Colors.white, size: 22),
                label: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Enviar pedido por WhatsApp",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processMercadoPago(BuildContext context, CartProvider cart) async {
    setState(() => _isProcessing = true);
    final total = widget.tipoEntrega == "delivery" ? cart.totalPrice + 5 : cart.totalPrice;
    final orderNumber = "TY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    final itemsPayload = cart.items.map((item) => {
      'title': '${item.nombre} (${item.tamanio})',
      'quantity': item.cantidad,
      'price': item.precio,
    }).toList();

    final success = await MercadoPagoService.startPaymentProcess(
      orderId: orderNumber,
      totalAmount: total,
      items: itemsPayload,
      clientName: 'Cliente Tortas Yani',
      clientEmail: 'cliente@tortasyani.com',
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      cart.clearCart();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(orderNumber: orderNumber),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _processPay(BuildContext context, CartProvider cart) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isProcessing = false);

    final items = List<CartItem>.from(cart.items);
    final total = widget.tipoEntrega == "delivery"
        ? cart.totalPrice + 5
        : cart.totalPrice;
    final orderNumber = "TY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    const whatsappNumber = "51919576034";

    final StringBuffer mensaje = StringBuffer();
    mensaje.writeln("🎂 *NUEVO PEDIDO - Tortas Yani*");
    mensaje.writeln("─────────────────────");
    mensaje.writeln("📋 *Pedido:* $orderNumber");
    mensaje.writeln();
    mensaje.writeln("🛒 *Detalle:*");
    for (final item in items) {
      mensaje.writeln("• ${item.cantidad}x ${item.nombre} (Talla: ${item.tamanio}) - S/ ${item.subtotal.toStringAsFixed(0)}");
    }
    mensaje.writeln();

    if (widget.tipoEntrega == "delivery") {
      mensaje.writeln("🚚 *Tipo:* Delivery");
      mensaje.writeln("🚚 Delivery: S/ 5");
      if (widget.ubicacion.isNotEmpty) {
        mensaje.writeln("📍 *Mi ubicación:* ${widget.ubicacion}");
      }
    } else {
      mensaje.writeln("🏪 *Tipo:* Recojo en local");
      mensaje.writeln("🚚 Delivery: Gratis");
    }

    mensaje.writeln("💰 *Total a pagar: S/ ${total.toStringAsFixed(0)}*");
    mensaje.writeln();
    mensaje.writeln("⏳ Por favor confirmar mi pedido y coordinar el pago. ¡Gracias! 🙏");

    cart.clearCart();

    final url = "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(mensaje.toString())}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(orderNumber: orderNumber),
      ),
          (route) => false,
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  final String orderNumber;

  const PaymentSuccessScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 17, 41),
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
                  color: const Color(0xFF25D366).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF25D366), size: 80),
              ),

              const SizedBox(height: 24),

              const Text(
                "¡Pedido enviado! 🎂",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              const SizedBox(height: 8),

              const Text(
                "Tu pedido fue enviado por WhatsApp",
                style: TextStyle(fontSize: 14, color: Colors.white54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2340),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF07070).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("N° Pedido", style: TextStyle(color: Colors.white54, fontSize: 13)),
                    Text(
                      orderNumber,
                      style: const TextStyle(color: Color(0xFFF07070), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2340),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFF07070), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "El negocio confirmará tu pedido y coordinará el pago por WhatsApp.",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Color(0xFFF07070), size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Tiempo de respuesta: ~30 minutos",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

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
                    elevation: 0,
                  ),
                  child: const Text(
                    "Volver al inicio",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
