import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

// Helper to map size codes to Spanish labels
String _sizeLabel(String code) {
  switch (code) {
    case "S":
      return "Pequeño";
    case "M":
      return "Mediano";
    case "L":
      return "Grande";
    default:
      return code;
  }
}


class CustomCakePopup extends StatefulWidget {
  final Map<String, dynamic> torta;

  const CustomCakePopup({super.key, required this.torta});

  @override
  State<CustomCakePopup> createState() => _CustomCakePopupState();
}

class _CustomCakePopupState extends State<CustomCakePopup> {
  String _tamanio = "M";
  String _sabor = "Chocolate";
  int _pisos = 1;
  final TextEditingController _porcionesController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String _colorSeleccionadoNombre = "Rosa pastel";
  final List<Map<String, dynamic>> _coloresDisponibles = [
    {"nombre": "Rosa pastel", "color": const Color(0xFFFFB5B5)},
    {"nombre": "Celeste", "color": const Color(0xFFB5D8FF)},
    {"nombre": "Dorado", "color": const Color(0xFFFFD700)},
    {"nombre": "Blanco perla", "color": const Color(0xFFF5F5F5)},
    {"nombre": "Chocolate", "color": const Color(0xFF8B4513)},
    {"nombre": "Lila", "color": const Color(0xFFDDA0DD)},
  ];

  final List<String> _tamanios = ["S", "M", "L"]; // internal codes
  final List<String> _sabores = [
    "Chocolate", "Vainilla", "Fresa", "Maracuyá", "Oreo", "Manjar blanco", "Lúcuma"
  ];

  @override
  void initState() {
    super.initState();
    _porcionesController.text = "10";
  }

  @override
  void dispose() {
    _porcionesController.dispose();
    _mensajeController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  double get _precioFinal {
    double precio = widget.torta['precio'].toDouble();
    if (_tamanio == "L") precio += 20;
    if (_tamanio == "S") precio -= 10;
    
    if (_pisos > 1) {
      precio += (_pisos - 1) * 30;
    }
    return precio;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF8), // Pastel Almond / Cream
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE5D5C5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.torta["imagen"],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70, height: 70, color: const Color(0xFFFFE4E1),
                    child: const Icon(Icons.cake, color: Color(0xFFF07070)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.torta["nombre"],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "S/ ${_precioFinal.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFF07070)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Expanded( // Use expanded for inner scroll
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Tamaño"),
                  Row(
                    children: _tamanios.map((t) {
                      final isSelected = _tamanio == t;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tamanio = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFB5B5) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFFB5B5) : const Color(0xFFE5D5C5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _sizeLabel(t),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF5A4A42),
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  t == "S" ? "(-S/10)" : t == "L" ? "(+S/20)" : "Base",
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  _sectionTitle("Pisos y Porciones"),
                  Row(
                    children: [
                      // Pisos
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5D5C5)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Color(0xFF5A4A42), size: 18),
                              onPressed: () { if (_pisos > 1) setState(() => _pisos--); },
                            ),
                            Text("$_pisos", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                            IconButton(
                              icon: const Icon(Icons.add, color: Color(0xFFF07070), size: 18),
                              onPressed: () { if (_pisos < 5) setState(() => _pisos++); },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "+ S/ 30 por piso extra",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  _sectionTitle("Sabor del relleno"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sabores.map((s) {
                      final isSelected = _sabor == s;
                      return GestureDetector(
                        onTap: () => setState(() => _sabor = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFB5B5) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFB5B5) : const Color(0xFFE5D5C5),
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF5A4A42),
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Color de decoración"),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_colorSeleccionadoNombre, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _coloresDisponibles.length,
                      itemBuilder: (context, index) {
                        final c = _coloresDisponibles[index];
                        final isSelected = _colorSeleccionadoNombre == c["nombre"];
                        return GestureDetector(
                          onTap: () => setState(() => _colorSeleccionadoNombre = c["nombre"]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            width: isSelected ? 40 : 32,
                            height: isSelected ? 40 : 32,
                            decoration: BoxDecoration(
                              color: c["color"],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF5A4A42) : Colors.black12,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(color: (c["color"] as Color).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3)),
                              ] : [],
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.black54, size: 20) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle("Descripción"),
                  TextField(
                    controller: _descripcionController,
                    maxLines: 2,
                    decoration: _inputDecoration("Descripción de la torta (Opcional)", Icons.description_outlined),
                    style: const TextStyle(color: Color(0xFF5A4A42), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle("Mensaje especial"),
                  TextField(
                    controller: _mensajeController,
                    maxLines: 2,
                    decoration: _inputDecoration("Mensaje en la torta (Opcional)", Icons.message_outlined),
                    style: const TextStyle(color: Color(0xFF5A4A42), fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final cart = Provider.of<CartProvider>(context, listen: false);
                cart.addItem(
                  widget.torta,
                  _tamanio,
                  _precioFinal,
                  _sabor,
                  _pisos,
                  int.tryParse(_porcionesController.text) ?? 10,
                  _colorSeleccionadoNombre,
                  _mensajeController.text.isEmpty ? "Sin mensaje" : _mensajeController.text,
                  _descripcionController.text,
                );
                Navigator.pop(context); // close modal
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${widget.torta["nombre"]} agregada 🛒"),
                    backgroundColor: const Color(0xFFF07070),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF07070),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                "Añadir diseño al carrito",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)),
      ),
    );
  }
  
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFFFB5B5), size: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFB5B5), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}

void mostrarPopupPersonalizacion(BuildContext context, Map<String, dynamic> torta) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    builder: (context) {
      return CustomCakePopup(torta: torta);
    },
  );
}
