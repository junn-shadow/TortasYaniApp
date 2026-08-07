import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CartItem {
  final String nombre;
  final String imagen;
  final double precio;
  final String tamanio;
  final String sabor;
  final int pisos;
  final int porciones;
  final String colorDecoracion;
  final String mensaje;
  final String descripcion;
  int cantidad;

  CartItem({
    required this.nombre,
    required this.imagen,
    required this.precio,
    required this.tamanio,
    required this.sabor,
    required this.pisos,
    required this.porciones,
    required this.colorDecoracion,
    required this.mensaje,
    this.descripcion = '',
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'imagen': imagen,
        'precio': precio,
        'tamanio': tamanio,
        'sabor': sabor,
        'pisos': pisos,
        'porciones': porciones,
        'colorDecoracion': colorDecoracion,
        'mensaje': mensaje,
        'descripcion': descripcion,
        'cantidad': cantidad,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        nombre: json['nombre'] ?? '',
        imagen: json['imagen'] ?? '',
        precio: (json['precio'] ?? 0.0).toDouble(),
        tamanio: json['tamanio'] ?? '',
        sabor: json['sabor'] ?? '',
        pisos: json['pisos'] ?? 0,
        porciones: json['porciones'] ?? 0,
        colorDecoracion: json['colorDecoracion'] ?? '',
        mensaje: json['mensaje'] ?? '',
        descripcion: json['descripcion'] ?? '',
        cantidad: json['cantidad'] ?? 1,
      );
}

class CartProvider extends ChangeNotifier {
  static const String _boxName = 'cart';
  late Box<String> _box;
  final List<CartItem> _items = [];

  CartProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<String>(_boxName);
    _loadFromBox();
  }

  void _loadFromBox() {
    _items.clear();
    final String? jsonStr = _box.get('items');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        for (var item in list) {
          _items.add(CartItem.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint("Error loading cart from Hive: $e");
      }
    }
    notifyListeners();
  }

  void _saveToBox() {
    final String jsonStr = jsonEncode(_items.map((i) => i.toJson()).toList());
    _box.put('items', jsonStr);
  }

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  void addItem(
    Map<String, dynamic> torta, 
    String tamanio, 
    double precioFinal,
    String sabor,
    int pisos,
    int porciones,
    String colorDecoracion,
    String mensaje,
    String descripcion,
  ) {
    final index = _items.indexWhere(
          (item) => item.nombre == torta["nombre"] && 
                    item.tamanio == tamanio &&
                    item.sabor == sabor &&
                    item.pisos == pisos &&
                    item.porciones == porciones &&
                    item.colorDecoracion == colorDecoracion &&
                    item.mensaje == mensaje,
    );

    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(CartItem(
        nombre: torta["nombre"],
        imagen: torta["imagen"],
        precio: precioFinal,
        tamanio: tamanio,
        sabor: sabor,
        pisos: pisos,
        porciones: porciones,
        colorDecoracion: colorDecoracion,
        mensaje: mensaje,
        descripcion: descripcion,
      ));
    }
    _saveToBox();
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    _saveToBox();
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _items[index].cantidad++;
    _saveToBox();
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_items[index].cantidad > 1) {
      _items[index].cantidad--;
    } else {
      _items.removeAt(index);
    }
    _saveToBox();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveToBox();
    notifyListeners();
  }
}
