import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _boxName = 'favorites';
  late Box<String> _box;
  final List<Map<String, dynamic>> _favorites = [];

  FavoritesProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<String>(_boxName);
    _loadFromBox();
  }

  void _loadFromBox() {
    _favorites.clear();
    final String? jsonStr = _box.get('items');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        for (var item in list) {
          _favorites.add(item as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint("Error loading favorites from Hive: $e");
      }
    }
    notifyListeners();
  }

  void _saveToBox() {
    final String jsonStr = jsonEncode(_favorites);
    _box.put('items', jsonStr);
  }

  List<Map<String, dynamic>> get favorites => _favorites;

  int get totalFavorites => _favorites.length;

  bool isFavorite(String nombre) {
    return _favorites.any((t) => t["nombre"] == nombre);
  }

  void toggleFavorite(Map<String, dynamic> torta) {
    final index = _favorites.indexWhere((t) => t["nombre"] == torta["nombre"]);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(torta);
    }
    _saveToBox();
    notifyListeners();
  }
}
