import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OrdersProvider extends ChangeNotifier {
  static const String _boxName = 'user_orders';
  late Box<String> _box;
  final List<Map<String, dynamic>> _orders = [];

  OrdersProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<String>(_boxName);
    _loadFromBox();
  }

  void _loadFromBox() {
    _orders.clear();
    for (var key in _box.keys) {
      final String? jsonStr = _box.get(key);
      if (jsonStr != null) {
        try {
          _orders.add(jsonDecode(jsonStr) as Map<String, dynamic>);
        } catch (e) {
          debugPrint("Error decoding order json: $e");
        }
      }
    }
    // Sort orders by date descending
    _orders.sort((a, b) {
      final dateA = DateTime.tryParse(a['fechaRaw'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b['fechaRaw'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });
    notifyListeners();
  }

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);

  Future<void> addOrder(Map<String, dynamic> order) async {
    final String id = order['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    order['fechaRaw'] = DateTime.now().toIso8601String();
    
    // Save to Hive
    final String jsonStr = jsonEncode(order);
    await _box.put(id, jsonStr);
    
    _orders.insert(0, order);
    notifyListeners();
  }

  Future<void> clearOrders() async {
    await _box.clear();
    _orders.clear();
    notifyListeners();
  }
}
