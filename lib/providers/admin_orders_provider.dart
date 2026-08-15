import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AdminOrdersProvider extends ChangeNotifier {
  static const String _boxName = 'admin_orders';
  late Box<String> _box;
  final List<Map<String, dynamic>> _orders = [];

  AdminOrdersProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<String>(_boxName);
    _loadFromBox();
  }

  void _loadFromBox() {
    _orders.clear();
    
    if (_box.isEmpty) {
      // Initialize with mock data if completely empty
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

  void _seedMockData() {
    final mockData = [
      {
        "id": "TK-1082",
        "fecha": "Hoy, 14:32",
        "cliente": "Carla Mendoza",
        "telefono": "987-654-321",
        "direccion": "Av. Larco 456, Miraflores",
        "estado": "Pendiente",
        "items": [
          {"nombre": "Torta de Chocolate (M)", "cantidad": 1, "precio": 85.0},
          {"nombre": "Cheesecake de Maracuyá (S)", "cantidad": 1, "precio": 60.0}
        ],
        "total": 145.0,
      },
      {
        "id": "TK-1083",
        "fecha": "Hoy, 13:10",
        "cliente": "Roberto Gómez",
        "telefono": "942-881-209",
        "direccion": "Calle Los Pinos 789, San Isidro",
        "estado": "En Horno",
        "items": [
          {"nombre": "Torta de Zanahoria (L)", "cantidad": 1, "precio": 87.75}
        ],
        "total": 87.75,
      },
      {
        "id": "TK-1084",
        "fecha": "Hoy, 12:45",
        "cliente": "Sofía Castro",
        "telefono": "915-234-567",
        "direccion": "Jirón Huallaga 120, Centro de Lima",
        "estado": "En Camino",
        "items": [
          {"nombre": "Red Velvet (M)", "cantidad": 1, "precio": 90.0},
          {"nombre": "Pie de Limón (M)", "cantidad": 1, "precio": 55.0}
        ],
        "total": 145.0,
      },
      {
        "id": "TK-1085",
        "fecha": "Ayer, 18:20",
        "cliente": "Daniela Rivas",
        "telefono": "956-789-012",
        "direccion": "Av. Primavera 1030, Surco",
        "estado": "Entregado",
        "items": [
          {"nombre": "Tres Leches (L)", "cantidad": 2, "precio": 94.5}
        ],
        "total": 189.0,
      },
      {
        "id": "TK-1086",
        "fecha": "Hoy, 15:05",
        "cliente": "Miguel Ángel",
        "telefono": "933-221-144",
        "direccion": "Av. Universitaria 3450, San Miguel",
        "estado": "Pendiente",
        "items": [
          {"nombre": "Torta Matrimonial (XL)", "cantidad": 1, "precio": 437.5}
        ],
        "total": 437.5,
      }
    ];

    for (var order in mockData) {
      final String id = order['id'] as String;
      _box.put(id, jsonEncode(order));
      _orders.add(order);
    }
  }

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);

  Future<void> updateOrderStatus(String id, String newStatus) async {
    final index = _orders.indexWhere((o) => o['id'] == id);
    if (index >= 0) {
      _orders[index]['estado'] = newStatus;
      await _box.put(id, jsonEncode(_orders[index]));
      notifyListeners();
    }
  }

  Future<void> addOrder(Map<String, dynamic> order) async {
    final String id = order['id'];
    await _box.put(id, jsonEncode(order));
    _orders.insert(0, order);
    notifyListeners();
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
