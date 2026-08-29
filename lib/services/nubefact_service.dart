import 'dart:convert';
import 'package:http/http.dart' as http;

class NubefactService {
  // URL (Ruta) proporcionada por Nubefact
  static const String _url = 'https://api.nubefact.com/api/v1/74dcf8af-0835-4cb9-bff2-e69ec2db847b';
  
  // Token proporcionado por Nubefact
  static const String _token = '4ba047930f0a46a8b82b45cc6ae7a4c3e7c36bdf671040709ec5ac4d8cf8d916';

  /// Genera una Boleta Electrónica de prueba en Nubefact.
  static Future<Map<String, dynamic>?> generarBoleta({
    required String clienteDni,
    required String clienteNombre,
    required String clienteDireccion,
    required double totalPedido,
    required List<Map<String, dynamic>> productos, // Lista de productos
  }) async {
    // Cálculo básico (asumiendo que los precios YA incluyen IGV 18%)
    // Base Imponible = Total / 1.18
    // IGV = Total - Base Imponible
    double baseImponible = totalPedido / 1.18;
    double totalIgv = totalPedido - baseImponible;

    // Convertimos los productos al formato UBL 2.1 que requiere Nubefact
    List<Map<String, dynamic>> items = productos.map((prod) {
      double precioTotalItem = prod['precio_unitario'] * prod['cantidad'];
      double valorUnitario = prod['precio_unitario'] / 1.18;
      double subtotalItem = precioTotalItem / 1.18;
      double igvItem = precioTotalItem - subtotalItem;

      return {
        "unidad_de_medida": "NIU", // Código SUNAT para "Unidad" (bienes)
        "codigo": prod['id'].toString(),
        "descripcion": prod['nombre'],
        "cantidad": prod['cantidad'],
        "valor_unitario": valorUnitario.toStringAsFixed(2),
        "precio_unitario": prod['precio_unitario'].toStringAsFixed(2),
        "descuento": "",
        "subtotal": subtotalItem.toStringAsFixed(2),
        "tipo_de_igv": "1", // Gravado - Operación Onerosa
        "igv": igvItem.toStringAsFixed(2),
        "total": precioTotalItem.toStringAsFixed(2),
        "anticipo_regularizacion": "false",
        "anticipo_documento_serie": "",
        "anticipo_documento_numero": ""
      };
    }).toList();

    // Estructura principal del comprobante
    Map<String, dynamic> body = {
      "operacion": "generar_comprobante",
      "tipo_de_comprobante": "2", // 1 = Factura, 2 = Boleta
      "serie": "B001", // Serie de prueba para boleta
      "numero": "1", // Número correlativo
      "sunat_transaction": "1", // Venta interna
      "cliente_tipo_de_documento": "1", // 1 = DNI, 6 = RUC
      "cliente_numero_de_documento": clienteDni,
      "cliente_denominacion": clienteNombre,
      "cliente_direccion": clienteDireccion,
      "cliente_email": "",
      "cliente_email_1": "",
      "cliente_email_2": "",
      "fecha_de_emision": DateTime.now().toString().substring(0, 10), // YYYY-MM-DD
      "fecha_de_vencimiento": "",
      "moneda": "1", // 1 = Soles
      "tipo_de_cambio": "",
      "porcentaje_de_igv": "18.00",
      "descuento_global": "",
      "total_descuento": "",
      "total_anticipo": "",
      "total_gravada": baseImponible.toStringAsFixed(2),
      "total_inafecta": "",
      "total_exonerada": "",
      "total_igv": totalIgv.toStringAsFixed(2),
      "total_gratuita": "",
      "total_otros_cargos": "",
      "total": totalPedido.toStringAsFixed(2),
      "percepcion_tipo": "",
      "percepcion_base_imponible": "",
      "total_percepcion": "",
      "total_incluido_percepcion": "",
      "detraccion": "false",
      "observaciones": "Pedido realizado desde TortasYaniApp",
      "documento_que_se_modifica_tipo": "",
      "documento_que_se_modifica_serie": "",
      "documento_que_se_modifica_numero": "",
      "tipo_de_nota_de_credito": "",
      "tipo_de_nota_de_debito": "",
      "enviar_automaticamente_a_la_sunat": "true",
      "enviar_automaticamente_al_cliente": "false",
      "codigo_unico": "",
      "condiciones_de_pago": "",
      "medio_de_pago": "",
      "plazo_de_pago": "",
      "medio_de_pago_detalles": "",
      "items": items,
    };

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Token token="$_token"',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['errors'] == null) {
        print("Comprobante generado exitosamente: \${data['enlace_del_pdf']}");
        return data; // Contiene enlace_del_pdf, enlace_del_xml, etc.
      } else {
        print("Error al generar comprobante: \${data['errors']}");
        return null;
      }
    } catch (e) {
      print("Error de conexión: \$e");
      return null;
    }
  }
}
