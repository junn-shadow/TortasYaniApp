import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';
import 'auth_service.dart';

class ProductsApiService {
  static String get baseUrl => AuthService.baseUrl;

  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            "id": item['id'].toString(),
            "nombre": item['nombre'] ?? '',
            "precio": (item['precio'] as num).toDouble(),
            "stock": item['stock'] ?? 0,
            "imagen": item['imagen'] ?? '',
            "categoria": item['categoria'] ?? '',
            "descripcion": item['descripcion'] ?? '',
            "badge": item['badge'] ?? '',
            "rating": (item['rating'] as num?)?.toDouble() ?? 5.0,
            "resenas": item['resenas'] ?? 0,
            "ingredientes": item['ingredientes'] ?? [],
            "tamanios": item['tamanios'] ?? [],
          };
        }).toList();
      } else {
        throw Exception('Failed to load products from API: ${response.statusCode}');
      }
    } catch (e) {
      print('=== ERROR FETCHING PRODUCTS ===: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> createProduct(Map<String, dynamic> product) async {
    try {
      final token = await SessionService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': product['nombre'],
          'categoria': product['categoria'],
          'precio': product['precio'],
          'stock': product['stock'],
          'imagen': product['imagen'],
          'descripcion': product['descripcion'] ?? '',
          'badge': product['badge'] ?? '',
          'ingredientes': List<String>.from(product['ingredientes'] ?? []),
          'tamanios': List<String>.from(product['tamanios'] ?? ["S", "M", "L"]),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final item = jsonDecode(response.body);
        return {
          "id": item['id'].toString(),
          "nombre": item['nombre'] ?? '',
          "precio": (item['precio'] as num).toDouble(),
          "stock": item['stock'] ?? 0,
          "imagen": item['imagen'] ?? '',
          "categoria": item['categoria'] ?? '',
          "descripcion": item['descripcion'] ?? '',
          "badge": item['badge'] ?? '',
          "rating": (item['rating'] as num?)?.toDouble() ?? 5.0,
          "resenas": item['resenas'] ?? 0,
          "ingredientes": item['ingredientes'] ?? [],
          "tamanios": item['tamanios'] ?? [],
        };
      }
      return null;
    } catch (e) {
      print('=== ERROR CREATING PRODUCT ===: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      final token = await SessionService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': product['nombre'],
          'categoria': product['categoria'],
          'precio': product['precio'],
          'stock': product['stock'],
          'imagen': product['imagen'],
          'descripcion': product['descripcion'] ?? '',
          'badge': product['badge'] ?? '',
          'ingredientes': List<String>.from(product['ingredientes'] ?? []),
          'tamanios': List<String>.from(product['tamanios'] ?? ["S", "M", "L"]),
        }),
      );

      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);
        return {
          "id": item['id'].toString(),
          "nombre": item['nombre'] ?? '',
          "precio": (item['precio'] as num).toDouble(),
          "stock": item['stock'] ?? 0,
          "imagen": item['imagen'] ?? '',
          "categoria": item['categoria'] ?? '',
          "descripcion": item['descripcion'] ?? '',
          "badge": item['badge'] ?? '',
          "rating": (item['rating'] as num?)?.toDouble() ?? 5.0,
          "resenas": item['resenas'] ?? 0,
          "ingredientes": item['ingredientes'] ?? [],
          "tamanios": item['tamanios'] ?? [],
        };
      }
      return null;
    } catch (e) {
      print('=== ERROR UPDATING PRODUCT ===: $e');
      return null;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    try {
      final token = await SessionService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('=== ERROR DELETING PRODUCT ===: $e');
      return false;
    }
  }
}
