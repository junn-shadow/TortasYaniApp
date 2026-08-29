import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MercadoPagoService {
  static const String publicKey = 'APP_USR-e7261003-1449-42c5-93eb-9812e462a049';
  static const String accessToken = 'APP_USR-4971588647309567-082119-420e42538660e53c604a145e36e67945-3630907665';
  static const String _apiUrl = 'https://api.mercadopago.com/checkout/preferences';

  /// Genera una preferencia de pago en Mercado Pago y retorna el init_point
  static Future<String?> startPaymentProcess({
    required String orderId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    required String clientName,
    required String clientEmail,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final body = jsonEncode({
        'items': items.map((item) => {
          'title': item['title'] ?? 'Torta Personalizada',
          'quantity': item['quantity'] ?? 1,
          'currency_id': 'PEN',
          'unit_price': item['price'] ?? totalAmount,
        }).toList(),
        'payer': {
          'name': clientName.isNotEmpty ? clientName : 'Cliente Tortas Yani',
          'email': clientEmail.isNotEmpty ? clientEmail : 'cliente@tortasyani.com',
        },
        'external_reference': orderId,
        'auto_return': 'approved',
        'back_urls': {
          'success': 'https://tortasyani.com/success',
          'failure': 'https://tortasyani.com/failure',
          'pending': 'https://tortasyani.com/pending',
        },
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String? initPoint = data['init_point'] ?? data['sandbox_init_point'];

        if (initPoint != null && initPoint.isNotEmpty) {
          return initPoint;
        }
      } else {
        debugPrint('Error Mercado Pago HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Excepción al iniciar pago con Mercado Pago: $e');
    }
    return null;
  }
}
