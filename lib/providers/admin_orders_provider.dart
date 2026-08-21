import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class AdminOrdersProvider extends ChangeNotifier {
  static const String _boxName = 'admin_orders';
  static const String _baseUrl = 'https://tortasyaniapiweb-production.up.railway.app/api/orders';
  late Box<String> _box;
  final List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);

  AdminOrdersProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<String>(_boxName);
    _loadFromBox();
    await fetchOrdersFromCloud();
  }

  void _loadFromBox() {
    _orders.clear();
    
    if (_box.isEmpty) {
      _seedMockData();
    } else {
      for (var key in _box.keys) {
        final String? jsonStr = _box.get(key);
        if (jsonStr != null) {
          try {
            _orders.add(jsonDecode(jsonStr) as Map<String, dynamic>);
          } catch (e) {
            debugPrint("Error decoding admin order json: $e");
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> fetchOrdersFromCloud() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _orders.clear();
        await _box.clear();

        for (var item in list) {
          final mapItem = Map<String, dynamic>.from(item);
          final String id = mapItem['id'] ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
          await _box.put(id, jsonEncode(mapItem));
          _orders.add(mapItem);
        }
      }
    } catch (e) {
      debugPrint("Sincronización Cloud Railway (Flutter Android): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _seedMockData() {
    final mockData = [
      {
        "id": "ORD-1082",
        "fecha": "2026-08-21 14:32",
        "cliente": "Carla Mendoza",
        "dniCliente": "74829102",
        "telefono": "987-654-321",
        "direccion": "Av. Larco 456, Miraflores",
        "estado": "Pendiente",
        "estadoPago": "En revisión",
        "metodoPago": "Yape",
        "montoAdelanto": 72.50,
        "saldoPendiente": 72.50,
        "items": [
          {"nombre": "Torta de Chocolate (M)", "cantidad": 1, "precio": 85.0},
          {"nombre": "Cheesecake de Maracuyá (S)", "cantidad": 1, "precio": 60.0}
        ],
        "total": 145.0,
      },
      {
        "id": "ORD-1083",
        "fecha": "2026-08-21 13:10",
        "cliente": "Roberto Gómez",
        "dniCliente": "10928374",
        "telefono": "942-881-209",
        "direccion": "Calle Los Pinos 789, San Isidro",
        "estado": "En Preparación",
        "estadoPago": "Aprobado",
        "metodoPago": "Plin",
        "montoAdelanto": 44.00,
        "saldoPendiente": 44.00,
        "items": [
          {"nombre": "Torta de Zanahoria (L)", "cantidad": 1, "precio": 88.0}
        ],
        "total": 88.0,
      },
      {
        "id": "ORD-1084",
        "fecha": "2026-08-20 18:45",
        "cliente": "Sofía Castro",
        "dniCliente": "45892103",
        "telefono": "915-234-567",
        "direccion": "Jirón Huallaga 120, Centro de Lima",
        "estado": "Pagado",
        "estadoPago": "Aprobado",
        "metodoPago": "Tarjeta",
        "montoAdelanto": 145.0,
        "saldoPendiente": 0.0,
        "items": [
          {"nombre": "Red Velvet (M)", "cantidad": 1, "precio": 90.0},
          {"nombre": "Pie de Limón (M)", "cantidad": 1, "precio": 55.0}
        ],
        "total": 145.0,
      }
    ];

    for (var order in mockData) {
      final String id = order['id'] as String;
      _box.put(id, jsonEncode(order));
      _orders.add(order);
    }
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    final index = _orders.indexWhere((o) => o['id'] == id);
    if (index >= 0) {
      _orders[index]['estado'] = newStatus;
      await _box.put(id, jsonEncode(_orders[index]));
      notifyListeners();

      try {
        await http.put(
          Uri.parse('$_baseUrl/$id/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'estado': newStatus}),
        ).timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint("Error sincronizando cambio de estado con Nube: $e");
      }
    }
  }

  Future<void> addOrder(Map<String, dynamic> order) async {
    final String id = order['id'] ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    order['id'] = id;
    await _box.put(id, jsonEncode(order));
    _orders.insert(0, order);
    notifyListeners();

    try {
      await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order),
      ).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint("Error subiendo nueva orden a la Nube: $e");
    }
  }

  Future<void> deleteOrder(String id) async {
    final index = _orders.indexWhere((o) => o['id'] == id);
    if (index >= 0) {
      _orders.removeAt(index);
      await _box.delete(id);
      notifyListeners();
    }
  }
}
