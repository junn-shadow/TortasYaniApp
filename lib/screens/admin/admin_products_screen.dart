import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:typed_data';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/products_api_service.dart';
import '../../services/cloudinary_upload.dart';
import 'package:image_picker/image_picker.dart';


class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  // Lista dinámica obtenida de la base de datos
  final List<Map<String, dynamic>> _products = [];
  bool _isLoadingData = false;

  // Imágenes por defecto para la simulación
  final List<String> _presetImages = [
    "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234559/torta_de_chocolate_wv8mi7.png",
    "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234868/Torta_de_Zanahoriaa_ury5wh.png",
    "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234917/Tres_Leches_d8lm11.png",
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedImageUrl = "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234559/torta_de_chocolate_wv8mi7.png";
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  String? _editingProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingData = true);
    try {
      final apiProducts = await ProductsApiService.fetchProducts();
      setState(() {
        _products.clear();
        _products.addAll(apiProducts);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al cargar productos del catálogo 🚨"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Abre el Modal para Agregar o Editar Producto
  void _openProductForm([Map<String, dynamic>? product]) {
    if (product != null) {
      _editingProductId = product["id"];
      _nameController.text = product["nombre"];
      _priceController.text = product["precio"].toString();
      _stockController.text = product["stock"].toString();
      _selectedImageUrl = product["imagen"];
    } else {
      _editingProductId = null;
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
      _selectedImageUrl = _presetImages[0];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF9FA), // Fondo rosa pastel suave
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 25,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _editingProductId == null ? "Nueva Torta 🎂" : "Editar Torta 🍰",
                            style: const TextStyle(
                              color: Color(0xFF6A1B29),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Color(0xFF8A6B70)),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFFFE4E6), height: 20),
                      const SizedBox(height: 10),

                      // Campo Nombre
                      _buildTextField(
                        controller: _nameController,
                        label: "Nombre de la Torta",
                        icon: Iconsax.cake,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Ingresa el nombre del producto";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Campo Descripción
                      _buildTextField(
                        controller: _descriptionController,
                        label: "Descripción del producto",
                        icon: Iconsax.edit,
                        validator: (value) {
                          // Descripción opcional, permitir vacío
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Campo Precio y Stock en fila
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: "Precio (S/.)",
                              icon: Iconsax.money_send,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return "Precio inválido";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              controller: _stockController,
                              label: "Stock Disponible",
                              icon: Iconsax.box,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || int.tryParse(value) == null || int.parse(value) < 0) {
                                  return "Stock inválido";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Selector de Imagen (galería)
                      const Text(
                        "Selecciona una Imagen de Catálogo:",
                        style: TextStyle(
                          color: Color(0xFF8A6B70),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            final bytes = await picked.readAsBytes();
                            setModalState(() {
                              _pickedImage = picked;
                              _pickedImageBytes = bytes;
                              _selectedImageUrl = '';
                            });
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD1D6).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFB6C1)),
                          ),
                          child: _pickedImage != null
                               ? ClipRRect(
                                   borderRadius: BorderRadius.circular(16),
                                   child: Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
                                 )
                               : _selectedImageUrl.isNotEmpty
                                   ? ClipRRect(
                                       borderRadius: BorderRadius.circular(16),
                                       child: Image.network(_selectedImageUrl, fit: BoxFit.cover),
                                     )
                                   : const Center(child: Icon(Icons.add_a_photo, color: Color(0xFFF07070), size: 30)),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botón Guardar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF07070),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            _editingProductId == null ? "Agregar Producto" : "Guardar Cambios",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Guarda (Crea o Edita) el producto en la API
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final String name = _nameController.text.trim();
    final double price = double.parse(_priceController.text.trim());
    final int stock = int.parse(_stockController.text.trim());

    setState(() => _isLoadingData = true);

    // Upload image if a new file was selected
    String imageUrl = _selectedImageUrl;
    if (_pickedImage != null) {
      final uploaded = await uploadToCloudinary(_pickedImageBytes!, _pickedImage!.name, '975414196325949', '878336629677518', 'ddfzttgyr');
      if (uploaded != null && uploaded.isNotEmpty) {
        imageUrl = uploaded;
        _selectedImageUrl = uploaded;
      } else {
        // Fallback to default if upload fails
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al subir la imagen'), backgroundColor: Colors.red));
        setState(() => _isLoadingData = false);
        return;
      }
    }

    if (_editingProductId == null) {
      // AGREGAR NUEVO A LA API
      final newProduct = {
        "nombre": name,
        "precio": price,
        "stock": stock,
        "imagen": imageUrl,
        "categoria": "Tortas", // Categoría por defecto
        "descripcion": _descriptionController.text.isNotEmpty ? _descriptionController.text : "Exquisito producto artesanal.",
        "badge": "",
        "ingredientes": ["Harina", "Huevos", "Azúcar"],
        "tamanios": ["S", "M", "L"],
      };

      final created = await ProductsApiService.createProduct(newProduct);
      setState(() => _isLoadingData = false);

      if (created != null && mounted) {
        setState(() {
          _products.insert(0, created);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡$name agregada con éxito! 🎂"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al agregar producto en el servidor 🚨"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // EDITAR EXISTENTE EN LA API
      final index = _products.indexWhere((p) => p["id"] == _editingProductId);
      if (index != -1) {
        final oldProd = _products[index];
        final updatedProduct = {
          "nombre": name,
          "precio": price,
          "stock": stock,
          "imagen": imageUrl,
          "categoria": oldProd["categoria"] ?? "Tortas",
          "descripcion": _descriptionController.text.isNotEmpty ? _descriptionController.text : (oldProd["descripcion"] ?? "Exquisito producto artesanal."),
          "badge": oldProd["badge"] ?? "",
          "ingredientes": oldProd["ingredientes"] ?? ["Harina", "Huevos", "Azúcar"],
          "tamanios": oldProd["tamanios"] ?? ["S", "M", "L"],
        };

        final updated = await ProductsApiService.updateProduct(_editingProductId!, updatedProduct);
        setState(() => _isLoadingData = false);

        if (updated != null && mounted) {
          setState(() {
            _products[index] = updated;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("¡$name editada con éxito! ✏️"),
              backgroundColor: const Color(0xFF056A9F),
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al actualizar producto en el servidor 🚨"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _isLoadingData = false);
      }
    }
  }

  // Elimina un producto de la API con confirmación visual
  void _deleteProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9FA), // Fondo claro
        title: const Text("¿Eliminar Torta?", style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold)),
        content: Text(
          "¿Estás seguro de eliminar '${product["nombre"]}' del catálogo?",
          style: const TextStyle(color: Color(0xFF8A6B70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF8A6B70))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra diálogo
              setState(() => _isLoadingData = true);
              final id = product["id"];
              final success = await ProductsApiService.deleteProduct(id);
              setState(() => _isLoadingData = false);

              if (success && mounted) {
                setState(() {
                  _products.removeWhere((p) => p["id"] == id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("'${product["nombre"]}' eliminada. 🗑️"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error al eliminar el producto del servidor 🚨"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // El Dashboard tiene el color de fondo principal
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductForm(),
        backgroundColor: const Color(0xFFF07070),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: _isLoadingData && _products.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF07070)),
              ),
            )
          : _products.isEmpty
              ? const Center(
                  child: Text(
                    "No hay productos en el catálogo 🎂\nArrastra hacia abajo para recargar",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8A6B70), fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFF07070),
                  backgroundColor: const Color(0xFFFFF6F7),
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 80),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final isOutOfStock = product["stock"] == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFE4E6)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD1D6).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Foto de la torta
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                product["imagen"],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 70,
                                  height: 70,
                                  color: const Color(0xFFFFF0F2),
                                  child: const Center(
                                    child: Text("🎂", style: TextStyle(fontSize: 24)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            // Detalles del producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product["nombre"],
                                    style: const TextStyle(
                                      color: Color(0xFF4A0E17),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "S/ ${product["precio"].toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFFF07070),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Badge de Stock
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isOutOfStock
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isOutOfStock
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      isOutOfStock ? "Agotado" : "${product["stock"]} disponibles",
                                      style: TextStyle(
                                        color: isOutOfStock ? Colors.red : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Botones de acción
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _openProductForm(product),
                                  icon: const Icon(Iconsax.edit_2, color: Color(0xFF8D4B53), size: 20),
                                  tooltip: "Editar",
                                ),
                                IconButton(
                                  onPressed: () => _deleteProduct(product),
                                  icon: const Icon(Iconsax.trash, color: Colors.redAccent, size: 20),
                                  tooltip: "Eliminar",
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fade(duration: 350.ms, delay: (40 * index).ms)
                          .slideX(begin: 0.05, duration: 350.ms, delay: (40 * index).ms);
                    },
                  ),
                ),
    );
  }

  // Widget auxiliar para text fields en modal
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Color(0xFF4A0E17), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A6B70), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFF07070), size: 20),
        filled: true,
        fillColor: const Color(0xFFFFE4E6).withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFC0CB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD1D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF07070), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
