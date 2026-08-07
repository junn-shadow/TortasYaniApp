import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  final User? user; // null = crear
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _rol = 'client';
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nombreController.text = widget.user!.nombre;
      _emailController.text = widget.user!.email;
      _descripcionController.text = widget.user!.descripcion;
      _rol = widget.user!.rol;
      _activo = widget.user!.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<UserProvider>(context, listen: false);
    final id = widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = User(
      id: id,
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      rol: _rol,
      activo: _activo,
      descripcion: _descripcionController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (widget.user == null) {
      await provider.addUser(newUser);
    } else {
      await provider.updateUser(newUser);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1D6),
        title: Text(
          isEdit ? 'Editar usuario' : 'Añadir usuario',
          style: const TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B29)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 1,
        shadowColor: const Color(0xFFFFD1D6).withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(controller: _nombreController, label: 'Nombre completo', icon: Icons.person_rounded),
                const SizedBox(height: 16),
                _buildField(controller: _emailController, label: 'Email', icon: Icons.email_rounded, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField(controller: _descripcionController, label: 'Descripción', icon: Icons.info_outline_rounded, keyboard: TextInputType.multiline, maxLines: 3),
                const SizedBox(height: 16),
                _buildField(controller: _passwordController, label: 'Contraseña', icon: Icons.lock_rounded, keyboard: TextInputType.visiblePassword),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(

                  value: _rol,
                  style: const TextStyle(color: Color(0xFF4A0E17), fontSize: 14),
                  dropdownColor: const Color(0xFFFFF9FA),
                  decoration: InputDecoration(
                    labelText: 'Rol del usuario',
                    labelStyle: const TextStyle(color: Color(0xFF8A6B70), fontSize: 13),
                    prefixIcon: const Icon(Icons.security_rounded, color: Color(0xFFF07070), size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFFFD1D6)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFFFD1D6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF07070), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador', style: TextStyle(color: Color(0xFF4A0E17))),
                    ),
                    DropdownMenuItem(
                      value: 'client',
                      child: Text('Cliente', style: TextStyle(color: Color(0xFF4A0E17))),
                    ),
                  ],
                  onChanged: (v) => setState(() => _rol = v ?? 'client'),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFE4E6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Usuario Activo',
                        style: TextStyle(color: Color(0xFF4A0E17), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Switch(
                        value: _activo,
                        activeColor: const Color(0xFFF07070),
                        activeTrackColor: const Color(0xFFFFD1D6),
                        inactiveThumbColor: const Color(0xFF8A6B70),
                        inactiveTrackColor: const Color(0xFFFFE4E6),
                        onChanged: (v) => setState(() => _activo = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF07070),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFFF07070).withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isEdit ? 'Guardar cambios' : 'Crear usuario',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
      style: const TextStyle(color: Color(0xFF4A0E17), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A6B70), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFF07070), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD1D6)),
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
